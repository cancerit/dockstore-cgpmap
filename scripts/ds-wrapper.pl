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
            'b' => q{}
            ,);

GetOptions( 'h|help' => \$opts{'h'},
            'm|man' => \$opts{'m'},
            'r|reference=s' => \$opts{'r'},
            's|sample=s' => \$opts{'s'},
            'c|cram' => \$opts{'c'},
            'sc|scramble:s' => \$opts{'sc'},
            'b|bwa:s' => \$opts{'b'},
) or pod2usage(2);

pod2usage(-verbose => 1, -exitval => 0) if(defined $opts{'h'});
pod2usage(-verbose => 2, -exitval => 0) if(defined $opts{'m'});

delete $opts{'h'};
delete $opts{'m'};

printf "Options loaded: \n%s\n",Dumper(\%opts);

## unpack the reference area:
my $ref_area = $ENV{HOME}.'/reference_files';
make_path($ref_area);
my $untar = sprintf 'tar --strip-components 1 -C %s -zxvf %s', $ref_area, $opts{'r'};
system($untar) && die $!;

my $run_file = $ENV{HOME}.'/run.params';
open my $FH,'>',$run_file or die "Failed to write to $run_file: $!";
printf $FH "REF_BASE='%s'\n", $ref_area;
printf $FH "SAMPLE_NAME='%s'\n", $opts{'s'};
printf $FH "OUTPUT_DIR='%s'\n", $ENV{HOME};
printf $FH "CRAM='%s'\n", $opts{'c'};
printf $FH "SCRAMBLE='%s'\n", $opts{'sc'};
printf $FH "BWA_PARAM='%s'\n", $opts{'b'};
printf $FH "INPUT='%s'\n", join ' ', @ARGV;
close $FH;

# REF_BASE='/datastore/ref/reference_files'
# SAMPLE_NAME='COLO-829'
# INPUT=$HOME
# OUTPUT_DIR=$BOX_MNT_PNT/$SAMPLE_NAME/mapping
# CRAM=0
# SCRAMBLE=''
# BWA_PARAM='-Y'

__END__


=head1 NAME

dh-wrapper.pl - Generate the param file and execute mapping.sh (for dockstore)

=head1 SYNOPSIS

dh-wrapper.pl [options] [file(s)...]

  Required parameters:
    -reference   -r   Path to reference tar
    -sample      -s   Sample name to be applied to output file.

  Optional parameters:
    -cram        -c   Output cram, see '-sc'
    -scramble    -sc  Single quoted string of parameters to pass to Scramble when '-c' used
                      - '-I,-O' are used internally and should not be provided
    -bwa         -b     Single quoted string of additional parameters to pass to BWA
                         - '-t,-p,-R' are used internally and should not be provided

  Other:
    -help        -h   Brief help message.
    -man         -m   Full documentation.

File list can be full file names or wildcard, e.g.

=over 4

=item mutiple BAM inputs

 dh-wrapper.pl [options] input/*.bam

=item multiple paired fastq inputs

 dh-wrapper.pl [options] input/*_[12].fq[.gz]

=item multiple interleaved paired fastq inputs

 dh-wrapper.pl [options] input/*.fq[.gz]

=item mixture of BAM and CRAM

 dh-wrapper.pl [options] input/*.bam input/*.cram

=back

=head1 DESCRIPTION

stuff

=head1 OPTION DETAILS

=over 4

=item B<-reference>

Path to mapping tar.gz reference files

=item B<-sample>

Name to be applied to output files.  Special characters will not be magically fixed.

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
