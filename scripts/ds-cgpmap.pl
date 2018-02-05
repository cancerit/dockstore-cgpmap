#!/usr/bin/perl

use strict;
use Getopt::Long;
use File::Path qw(make_path);
use Pod::Usage qw(pod2usage);
use Data::Dumper;
use autodie qw(:all);
use warnings FATAL => 'all';

pod2usage(-verbose => 1, -exitval => 1) if(@ARGV == 0);

# set defaults
my %opts = ('c'=>0,
            'sc' => q{},
            'b' => q{},
            'o' => $ENV{HOME},
            't' => undef,
            'g' => undef,
            );

GetOptions( 'h|help' => \$opts{'h'},
            'm|man' => \$opts{'m'},
            'r|reference=s' => \$opts{'r'},
            'i|bwa_idx=s' => \$opts{'i'},
            's|sample=s' => \$opts{'s'},
            'c|cram' => \$opts{'c'},
            'sc|scramble:s' => \$opts{'sc'},
            'b|bwa:s' => \$opts{'b'},
            'g|groupinfo:s' => \$opts{'g'},
            't|threads:i' => \$opts{'t'},
            'o|outdir:s' => \$opts{'o'},
) or pod2usage(2);

pod2usage(-verbose => 1, -exitval => 0) if(defined $opts{'h'});
pod2usage(-verbose => 2, -exitval => 0) if(defined $opts{'m'});

delete $opts{'h'};
delete $opts{'m'};

printf "Options loaded: \n%s\n",Dumper(\%opts);

# figure out if ref already unpacked:
my $ref_area = $opts{'o'}.'/reference_files';
my $ref_unpack = 1;
if($opts{'r'} eq $opts{'i'} && -d $opts{'r'}) {
  $ref_area = $opts{'r'};
  $ref_unpack = 0;
}

# make the param file
make_path($opts{'o'}) unless(-e $opts{'o'});
my $run_file = $opts{'o'}.'/run.params';
open my $FH,'>',$run_file or die "Failed to write to $run_file: $!";
# Force explicit checking of file flush
printf $FH "export PCAP_THREADED_NO_SCRIPT=1\n";
printf $FH "export PCAP_THREADED_FORCE_SYNC=1\n";
# General params
printf $FH "REF_BASE='%s'\n", $ref_area;
printf $FH "SAMPLE_NAME='%s'\n", $opts{'s'};
printf $FH "OUTPUT_DIR='%s'\n", $opts{'o'};
printf $FH "CRAM='%s'\n", $opts{'c'};
printf $FH "SCRAMBLE='%s'\n", $opts{'sc'} if(length $opts{'sc'} > 0);
printf $FH "BWA_PARAM='%s'\n", $opts{'b'} if(length $opts{'b'} > 0);
printf $FH "GROUPINFO='%s'\n", $opts{'g'} if(defined $opts{'g'});
printf $FH "CPU=%d\n", $opts{'t'} if(defined $opts{'t'});
printf $FH "CLEAN_REF=1\n" if($ref_unpack);
printf $FH "INPUT='%s'\n", join ' ', @ARGV;
close $FH;

if($ref_unpack) {
  ## unpack the reference area:
  make_path($ref_area);
  my $untar = sprintf 'tar --strip-components 1 -C %s -zxvf %s', $ref_area, $opts{'r'};
  system($untar) && die $!;
  $untar = sprintf 'tar --strip-components 1 -C %s -zxvf %s', $ref_area, $opts{'i'};
  system($untar) && die $!;
}

exec('mapping.sh', $run_file); # I will never return to the perl code

__END__


=head1 NAME

ds-cgpmap.pl - Generate the param file and execute mapping.sh (for dockstore)

=head1 SYNOPSIS

ds-cgpmap.pl [options] [file(s)...]

  Required parameters:
    -reference   -r   Path to core reference tar.gz
                       - if already unpacked provide base directory
                       - see `-m` for full details
    -bwa_idx     -i   Path to bwa index tar.gz
                       - if already unpacked provide base directory
                       - see `-m` for full details
    -sample      -s   Sample name to be applied to output file.

  Optional parameters:
    -cram        -c   Output cram, see '-sc'
    -scramble    -sc  Single quoted string of parameters to pass to Scramble when '-c' used
                      - '-I,-O' are used internally and should not be provided
    -bwa         -b     Single quoted string of additional parameters to pass to BWA
                         - '-t,-p,-R' are used internally and should not be provided
    -groupinfo   -g   Readgroup metadata file for FASTQ inputs, values are not validated (yaml).
    -threads     -t   Set the number of cpu/cores available [default all].
    -outdir      -o   Set the output folder [$HOME]

  Other:
    -help        -h   Brief help message.
    -man         -m   Full documentation.

File list can be full file names or wildcard, e.g.

=over 4

=item mutiple BAM inputs

 ds-cgpmap.pl [options] input/*.bam

=item multiple paired fastq inputs

 ds-cgpmap.pl [options] input/*_[12].fq[.gz]

=item multiple interleaved paired fastq inputs

 ds-cgpmap.pl [options] input/*.fq[.gz]

=item mixture of BAM and CRAM

 ds-cgpmap.pl [options] input/*.bam input/*.cram

=back

=head1 DESCRIPTION

stuff

=head1 OPTION DETAILS

=over 4

=item B<-reference> B<-bwa_idx>

B<-reference> should point to a core_ref_XXXX.tar.gz

B<-bwa_idx> should point to a bwa_idx_XXXX.tar.gz

See ftp://ftp.sanger.ac.uk/pub/cancer/dockstore/

If both are equal and directories will assume already unpacked as

  mkdir ref_base
  tar -C ref_base --strip-components 1 -zxvf core_ref_XXXX.tar.gz
  tar -C ref_base --strip-components 1 -zxvf bwa_idx_XXXX.tar.gz

B<-reference>

=item B<-sample>

Name to be applied to output files.  Special characters will not be magically fixed.


=item B<-cram>

Final output file will be a CRAM file instead of BAM.  To tune the the compression methods see then
B<-scramble> option.

=item B<-scramble>

Single quoted string of parameters to pass to Scramble when '-c' used.  Please see the Scramble
documentation for details.

Please note: '-I,-O' are used internally and should not be provided.

=item B<-bwa>

Single quoted string of additional parameters to pass to BWA.  Please see the 'bwa mem'
documentation for details.

Please note: '-t,-p,-R' are used internally and should not be provided.

=item B<-groupinfo>

Readgroup information metadata file, please see the PCAP wiki for format:

https://github.com/cancerit/PCAP-core/wiki/File-Formats-groupinfo.yaml

=item B<-threads>

Sets the number of cores to be used during processing.  Default to use all at appropriate
points in analysis.

Recommend increments of 6 once 6 is exceeded.

=item B<-outdir>

Set the output directory.  Defaults to $HOME.

NOTE: Should B<NOT> be set when working with dockstore wrapper.

=back

=head2 INPUT FILE TYPES

There are several types of file that the script is able to process.

=over 4

=item f[ast]q

A standard uncompressed fastq file.  Requires a pair of inputs with standard suffix of '_1' and '_2'
immediately prior to '.f[ast]q' or an interleaved f[ast]q file where read 1 and 2 are adjacent
in the file.


=item f[ast]q.gz

As *.f[ast]q but compressed with gzip.

=item bam

Single lane BAM files, RG line is transfered to aligned files.  Also accepts multi lane BAM.

=item cram

Single lane BAM files, RG line is transfered to aligned files.  Also accepts multi lane CRAM.

=back

=cut
