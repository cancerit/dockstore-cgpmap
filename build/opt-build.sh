#!/bin/bash

set -xe

if [[ -z "${TMPDIR}" ]]; then
  TMPDIR=/tmp
fi

set -u

## for cgpBigWig
VER_BIODBHTS="2.7"
VER_LIBBW="0.1.7"
VER_CGPBIGWIG="0.4.0"

# for PCAP
VER_BWA="v0.7.15"
VER_HTSLIB="1.3.2"
VER_SAMTOOLS="1.3.1"
VER_PCAP="4.0.0"

if [ "$#" -lt "1" ] ; then
  echo "Please provide an installation path such as /opt/ICGC"
  exit 1
fi


# get path to this script
SCRIPT_PATH=`dirname $0`;
SCRIPT_PATH=`(cd $SCRIPT_PATH && pwd)`

# get the location to install to
INST_PATH=$1
mkdir -p $1
INST_PATH=`(cd $1 && pwd)`
echo $INST_PATH

# get current directory
INIT_DIR=`pwd`

CPU=`grep -c ^processor /proc/cpuinfo`
if [ $? -eq 0 ]; then
  if [ "$CPU" -gt "6" ]; then
    CPU=6
  fi
else
  CPU=1
fi
echo "Max compilation CPUs set to $CPU"


SETUP_DIR=$INIT_DIR/install_tmp
mkdir -p $SETUP_DIR/distro # don't delete the actual distro directory until the very end
mkdir -p $INST_PATH/bin
cd $SETUP_DIR

# make sure tools installed can see the install loc of libraries
set +u
export LD_LIBRARY_PATH=`echo $INST_PATH/lib:$LD_LIBRARY_PATH | perl -pe 's/:\$//;'`
export PATH=`echo $INST_PATH/bin:$PATH | perl -pe 's/:\$//;'`
export MANPATH=`echo $INST_PATH/man:$INST_PATH/share/man:$MANPATH | perl -pe 's/:\$//;'`
export PERL5LIB=`echo $INST_PATH/lib/perl5:$PERL5LIB | perl -pe 's/:\$//;'`
set -u

## INSTALL CPANMINUS
set -eux
curl -sSL https://cpanmin.us/ > $SETUP_DIR/cpanm
perl $SETUP_DIR/cpanm --no-interactive --notest --mirror http://cpan.metacpan.org -l $INST_PATH App::cpanminus
rm -f $SETUP_DIR/cpanm

##### DEPS for cgpBigWig #####

## HTSLIB (tar.bz2)
if [ ! -e $SETUP_DIR/htslib.success ]; then
  curl -sSL --retry 10 https://github.com/samtools/htslib/releases/download/${VER_HTSLIB}/htslib-${VER_HTSLIB}.tar.bz2 > distro.tar.bz2
  rm -rf distro/*
  tar --strip-components 1 -C distro -jxf distro.tar.bz2
  cd distro
  ./configure --enable-plugins --enable-libcurl --prefix=$INST_PATH
  make clean
  make -j$CPU
  make install
  cd $SETUP_DIR
  rm -rf distro.* distro/*
  touch $SETUP_DIR/htslib.success
fi

## LIB-BW (tar.gz)
if [ ! -e $SETUP_DIR/libBigWig.success ]; then
  curl -sSL --retry 10 https://github.com/dpryan79/libBigWig/archive/${VER_LIBBW}.tar.gz > distro.tar.gz
  rm -rf distro/*
  tar --strip-components 1 -C distro -xzf distro.tar.gz
  make -C distro clean
  make -C distro -j$CPU install prefix=$INST_PATH
  rm -rf distro.* distro/*
  touch $SETUP_DIR/libBigWig.success
fi

##### cgpBigWig installation
if [ ! -e $SETUP_DIR/cgpBigWig.success ]; then
  curl -sSL --retry 10 https://github.com/cancerit/cgpBigWig/archive/${VER_CGPBIGWIG}.tar.gz > distro.tar.gz
  rm -rf distro/*
  tar --strip-components 1 -C distro -xzf distro.tar.gz
  make -C distro/c clean
  make -C distro/c -j$CPU prefix=$INST_PATH HTSLIB=$INST_PATH/lib
  cp distro/bin/bam2bedgraph $INST_PATH/bin/.
  cp distro/bin/bwjoin $INST_PATH/bin/.
  cp distro/bin/bam2bw $INST_PATH/bin/.
  cp distro/bin/bwcat $INST_PATH/bin/.
  cp distro/bin/bam2bwbases $INST_PATH/bin/.
  cp distro/bin/bg2bw $INST_PATH/bin/.
  cp distro/bin/detectExtremeDepth $INST_PATH/bin/.
  rm -rf distro.* distro/*
  touch $SETUP_DIR/cgpBigWig.success
fi

##### DEPS for PCAP - layered on top #####

## build BWA (tar.gz)
if [ ! -e $SETUP_DIR/bwa.success ]; then
  curl -sSL --retry 10 https://github.com/lh3/bwa/archive/${VER_BWA}.tar.gz > distro.tar.gz
  rm -rf distro/*
  tar --strip-components 1 -C distro -zxf distro.tar.gz
  make -C distro -j$CPU
  cp distro/bwa $INST_PATH/bin/.
  rm -rf distro.* distro/*
  touch $SETUP_DIR/bwa.success
fi

## SAMTOOLS (tar.bz2)
if [ ! -e $SETUP_DIR/samtools.success ]; then
  curl -sSL --retry 10 https://github.com/samtools/samtools/releases/download/${VER_SAMTOOLS}/samtools-${VER_SAMTOOLS}.tar.bz2 > distro.tar.bz2
  rm -rf distro/*
  tar --strip-components 1 -C distro -xjf distro.tar.bz2
  cd distro
  ./configure --enable-plugins --enable-libcurl --with-htslib=$INST_PATH --prefix=$INST_PATH
  make clean
  make -j$CPU all
  make install
  cd $SETUP_DIR
  rm -rf distro.* distro/*
  touch $SETUP_DIR/samtools.success
fi

## Bio::DB::HTS (tar.gz)
if [ ! -e $SETUP_DIR/Bio-DB-HTS.success ]; then
  ## add perl deps
  cpanm --no-interactive --notest --mirror http://cpan.metacpan.org -l $INST_PATH Module::Build
  cpanm --no-interactive --notest --mirror http://cpan.metacpan.org -l $INST_PATH Bio::Root::Version

  curl -sSL --retry 10 https://github.com/Ensembl/Bio-DB-HTS/archive/${VER_BIODBHTS}.tar.gz > distro.tar.gz
  rm -rf distro/*
  tar --strip-components 1 -C distro -zxf distro.tar.gz
  cd distro
  perl Build.PL --install_base=$INST_PATH --htslib=$INST_PATH
  ./Build install
  cd $SETUP_DIR
  rm -rf distro.* distro/*
  touch $SETUP_DIR/Bio-DB-HTS.success
fi

## biobambam2
if [ ! -e $SETUP_DIR/biobambam2.success ]; then
  # co-located external script as it's complex
  cd distro
  rm -rf *
  bash $SCRIPT_PATH/biobambam2-build.sh
  cp biobambam/bin/* $INST_PATH/bin/.
  rsync -rl biobambam/bin $INST_PATH/.
  rsync -rl biobambam/include $INST_PATH/,
  rsync -rl biobambam/lib $INST_PATH/.
  rsync -rl biobambam/share $INST_PATH/.
  cd $SETUP_DIR
  rm -rf distro.* distro/*
  touch $SETUP_DIR/biobambam2.success
fi

##### PCAP-core installation

if [ ! -e $SETUP_DIR/PCAP.success ]; then
  cpanm --no-interactive --notest --mirror http://cpan.metacpan.org -l $INST_PATH Const::Fast
  cpanm --no-interactive --notest --mirror http://cpan.metacpan.org -l $INST_PATH File::Which
  curl -sSL --retry 10 https://github.com/cancerit/PCAP-core/archive/${VER_PCAP}.tar.gz > distro.tar.gz
  rm -rf distro/*
  tar --strip-components 1 -C distro -xzf distro.tar.gz
  cd distro
  if [ ! -e $SETUP_DIR/pcap_c.success ]; then
    make -C c clean
    make -C c -j$CPU prefix=$INST_PATH HTSLIB=$INST_PATH/lib
    cp bin/bam_stats $INST_PATH/bin/.
    cp bin/reheadSQ $INST_PATH/bin/.
    cp bin/diff_bams $INST_PATH/bin/.
    touch $SETUP_DIR/pcap_c.success
  fi
  cpanm --no-interactive --notest --mirror http://cpan.metacpan.org --notest -l $INST_PATH --installdeps .
  cpanm -v --no-interactive --mirror http://cpan.metacpan.org -l $INST_PATH .
  cd $SETUP_DIR
  rm -rf distro.* distro/*
  touch $SETUP_DIR/PCAP.success
fi

set +x

echo "
################################################################

  To use the non-central tools you need to set the following
    export LD_LIBRARY_PATH=$INST_PATH/lib:\$LD_LIBRARY_PATH
    export PATH=$INST_PATH/bin:\$PATH
    export MANPATH=$INST_PATH/man:$INST_PATH/share/man:\$MANPATH
    export PERL5LIB=$INST_PATH/lib/perl5:\$PERL5LIB

################################################################
"
