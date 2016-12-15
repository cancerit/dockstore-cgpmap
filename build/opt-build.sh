#!/bin/bash

set -uxe

rm -rf /tmp/downloads

mkdir -p /tmp/downloads $OPT/bin $OPT/etc $OPT/lib $OPT/share $OPT/site /tmp/hts_cache

cd /tmp/downloads

# cgpBigWig
curl -sSL -o distro.zip --retry 10 https://github.com/cancerit/cgpBigWig/archive/0.3.0.zip
mkdir /tmp/downloads/distro
bsdtar -C /tmp/downloads/distro --strip-components 1 -xf distro.zip
cd /tmp/downloads/distro
./setup.sh $OPT
cd /tmp/downloads
rm -rf distro.zip /tmp/downloads/distro /tmp/hts_cache

# PCAP-core
curl -sSL -o distro.zip --retry 10 https://github.com/ICGC-TCGA-PanCancer/PCAP-core/archive/v3.4.0.zip
mkdir /tmp/downloads/distro
bsdtar -C /tmp/downloads/distro --strip-components 1 -xf distro.zip
cd /tmp/downloads/distro
./setup.sh $OPT
cd /tmp/downloads
rm -rf distro.zip /tmp/downloads/distro /tmp/hts_cache

rm -rf /tmp/downloads
