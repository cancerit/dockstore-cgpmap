#!/bin/bash

set -uxe

if [[ -z "${TMPDIR}" ]]; then
  TMPDIR=/tmp
fi

rm -rf $TMPDIR/downloads

mkdir -p $TMPDIR/downloads $OPT/bin $OPT/etc $OPT/lib $OPT/share $OPT/site /tmp/hts_cache

cd $TMPDIR/downloads

# cgpBigWig
curl -sSL -o distro.zip --retry 10 https://github.com/cancerit/cgpBigWig/archive/0.3.1.zip
mkdir $TMPDIR/downloads/distro
bsdtar -C $TMPDIR/downloads/distro --strip-components 1 -xf distro.zip
cd $TMPDIR/downloads/distro
./setup.sh $OPT
cd $TMPDIR/downloads
rm -rf distro.zip $TMPDIR/downloads/distro /tmp/hts_cache

# PCAP-core
curl -sSL -o distro.zip --retry 10 https://github.com/ICGC-TCGA-PanCancer/PCAP-core/archive/v3.5.0.zip
mkdir $TMPDIR/downloads/distro
bsdtar -C $TMPDIR/downloads/distro --strip-components 1 -xf distro.zip
cd $TMPDIR/downloads/distro
./setup.sh $OPT
cd $TMPDIR/downloads
rm -rf distro.zip $TMPDIR/downloads/distro /tmp/hts_cache

rm -rf $TMPDIR/downloads
