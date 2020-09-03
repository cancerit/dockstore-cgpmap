#!/usr/bin/env perl

use strict;
use Getopt::Long;
use File::Path qw(make_path);
use Pod::Usage qw(pod2usage);
use Data::Dumper;
use autodie qw(:all);
use warnings FATAL => 'all';

pod2usage(-verbose => 1, -exitval => 1) if(@ARGV == 0);

# set defaults
my %opts = ('csi' => 0,
            'c' => 0,
            'q' => 0,
            'sc' => q{},
            'b' => q{},
            'o' => $ENV{HOME},
            't' => undef,
            'g' => undef,
            'f' => 0.05,
            'dupmode' => 't',
            'bwamem2' => 0,
            'nomarkdup' => 0,
            'legacy' => 0,
            'seqslice' => undef,
            );

GetOptions( 'h|help' => \$opts{'h'},
            'm|man' => \$opts{'m'},
            'r|reference=s' => \$opts{'r'},
            'i|bwa_idx=s' => \$opts{'i'},
            's|sample=s' => \$opts{'s'},
            'c|cram' => \$opts{'c'},
            'csi' => \$opts{'csi'},
            'b|bwa:s' => \$opts{'b'},
            'g|groupinfo:s' => \$opts{'g'},
            't|threads:i' => \$opts{'t'},
            'o|outdir:s' => \$opts{'o'},
            'q|qc' => \$opts{'q'},
            'f|qcf:f' => \$opts{'f'},
            'bm2|bwamem2' => \$opts{'bwamem2'},
            'n|nomarkdup' => \$opts{'nomarkdup'},
            'd|dupmode:s' => \$opts{'dupmode'},
            'legacy' => \$opts{'legacy'},
            'ss|seqslice:i' => \$opts{'seqslice'},
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
print $FH "export PCAP_THREADED_FORCE_SYNC=1\n";
print $FH "export PCAP_THREADED_LOADBACKOFF=1\n";
print $FH "export PCAP_THREADED_REM_LOGS=1\n";
# General params
printf $FH "REF_BASE='%s'\n", $ref_area;
printf $FH "SAMPLE_NAME='%s'\n", $opts{'s'};
printf $FH "OUTPUT_DIR='%s'\n", $opts{'o'};
printf $FH "CRAM='%d'\n", $opts{'c'};
printf $FH "CSI='%d'\n", $opts{'csi'};
printf $FH "BWA_PARAM='%s'\n", $opts{'b'} if(length $opts{'b'} > 0);
printf $FH "GROUPINFO='%s'\n", $opts{'g'} if(defined $opts{'g'});
printf $FH "CPU=%d\n", $opts{'t'} if(defined $opts{'t'});
printf $FH "CLEAN_REF=%d\n", $ref_unpack;
printf $FH "INPUT='%s'\n", join ' ', @ARGV;
printf $FH "MMQC=%d\n", $opts{'q'};
printf $FH "MMQCFRAC=%s\n", $opts{'f'} if(defined $opts{'f'});
printf $FH "DUPMODE=%s\n", $opts{'dupmode'};
printf $FH "BWAMEM2=%d\n", $opts{'bwamem2'} if(defined $opts{'bwamem2'});
printf $FH "NOMARKDUP=%d\n", $opts{'nomarkdup'} if(defined $opts{'nomarkdup'});
printf $FH "LEGACY=%d\n", $opts{'legacy'} if(defined $opts{'legacy'});
printf $FH "SEQSLICE=%d\n", $opts{'seqslice'} if(defined $opts{'seqslice'});

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
    -threads     -t    Number of threads to use. [1]
    -bwamem2     -bm2  Use bwa-mem2 instead of bwa (experimental).
    -nomarkdup   -n    Don't mark duplicates [flag]
    -seqslice    -ss   seqs_per_slice for CRAM compression [samtools default: 10000]
    -cram        -c    Output cram, see '-sc'
    -bwa         -b    Single quoted string of additional parameters to pass to BWA
                       - '-t,-p,-R' are used internally and should not be provided
    -groupinfo   -g    Readgroup metadata file for FASTQ inputs, values are not validated (yaml).
    -threads     -t    Set the number of cpu/cores available [default all].
    -outdir      -o    Set the output folder [$HOME]
    -qc          -q    Apply mismatch QC to reads following duplicate marking
    -qcf         -f    Mismatch fraction to set as max before failing a read [0.05]
    -dupmode     -d    See "samtools markdup -m" [t]
    -legacy            Equivalent to PCAP-core<=5.0.5
                        - bamtofastq instead of samtools collate (for BAM/CRAM input)
                        - dupmode ignored as uses bammarkduplicates2
                        - Avoid use with bwamem2 (memory explosion)

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

=item B<-csi>

Generate csi index instead of bai when output is BAM.

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

=item B<-qc>

Apply mismatch QC to read with a mismatch fraction higher than that specified in B<-qcf>.

=item B<-qcf>

When B<-qc> is set reads with a mismatch rate greater than this value to QC_FAIL (512/0x200).

An auxilary tag is also set so these can be identified.

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
