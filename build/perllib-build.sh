#!/bin/bash

set -eux

apt-get -yq update
# install all perl libs, identify by grep of cgp_box_stack build "grep 'Successfully installed' build_stack.log"
# much faster, items needing later versions will still upgrade
# still install those that get an upgrade though as dependancies will be resolved

## command to parse a build output before applying package based install
## some will need editign still
#grep '^Successfully installed ' build.log | perl -ne 's/ [(].+$/\n/;s/^.+ //;s/[-][^-]+$//;printf qq{apt-get -yq install lib%s-perl\n},lc $_;'

## commented items are up-to-date
apt-get -yq install libextutils-cbuilder-perl
apt-get -yq install libmodule-build-perl
apt-get -yq install libextutils-config-perl
apt-get -yq install libextutils-installpaths-perl
apt-get -yq install libextutils-helpers-perl
apt-get -yq install libmodule-build-tiny-perl
apt-get -yq install libfile-sharedir-install-perl
apt-get -yq install libclass-inspector-perl
apt-get -yq install libfile-sharedir-perl
#apt-get -yq install libsub-exporter-progressive-perl
apt-get -yq install libconst-fast-perl
apt-get -yq install libfile-which-perl
#apt-get -yq install libhtml-tagset-perl
#apt-get -yq install libhtml-parser-perl
#apt-get -yq install libencode-locale-perl
#apt-get -yq install liblwp-mediatypes-perl
#apt-get -yq install libhttp-date-perl
#apt-get -yq install libio-html-perl
#apt-get -yq install liburi-perl
#apt-get -yq install libhttp-message-perl
apt-get -yq install libhttp-cookies-perl
apt-get -yq install libhttp-negotiate-perl
apt-get -yq install libhttp-daemon-perl
apt-get -yq install libfile-listing-perl
apt-get -yq install libwww-robotrules-perl
apt-get -yq install libnet-http-perl
apt-get -yq install libwww-perl
apt-get -yq install libtest-deep-perl
apt-get -yq install libdevel-stacktrace-perl
apt-get -yq install libclass-data-inheritable-perl
apt-get -yq install libexception-class-perl
apt-get -yq install libsub-uplevel-perl
apt-get -yq install libtest-exception-perl
apt-get -yq install libtest-simple-perl
apt-get -yq install libcapture-tiny-perl
apt-get -yq install libtext-diff-perl
apt-get -yq install libtest-differences-perl
apt-get -yq install libtest-warn-perl
apt-get -yq install libtest-most-perl
apt-get -yq install libio-string-perl
apt-get -yq install libdata-stag-perl
apt-get -yq install libbio-perl-perl
apt-get -yq install libtest-leaktrace-perl
apt-get -yq install libappconfig-perl
apt-get -yq install libtemplate-perl
apt-get -yq install liblog-message-perl
apt-get -yq install liblog-message-simple-perl
apt-get -yq install libterm-ui-perl
apt-get -yq install libdevel-cover-perl
#apt-get -yq install libio-stringy-perl
apt-get -yq install libconfig-inifiles-perl
#apt-get -yq install libtry-tiny-perl
#apt-get -yq install libdevel-symdump-perl
apt-get -yq install libpod-coverage-perl
#apt-get -yq install libparams-util-perl
apt-get -yq install libtest-nowarnings-perl
#apt-get -yq install libclone-perl
apt-get -yq install libhook-lexwrap-perl
apt-get -yq install libtest-subcalls-perl
#apt-get -yq install libexporter-tiny-perl
apt-get -yq install libxsloader-perl
#apt-get -yq install liblist-moreutils-perl
apt-get -yq install libfile-remove-perl
apt-get -yq install libtest-object-perl
#apt-get -yq install libtask-weaken-perl
apt-get -yq install libppi-perl
apt-get -yq install libcss-tiny-perl
apt-get -yq install libppi-html-perl
apt-get -yq install libversion-perl
apt-get -yq install libdata-uuid-perl
apt-get -yq install libipc-system-simple-perl
apt-get -yq install libproc-processtable-perl
#apt-get -yq install libxml-sax-base-perl
#apt-get -yq install libxml-namespacesupport-perl
#apt-get -yq install libxml-sax-perl
#apt-get -yq install libxml-parser-perl
#apt-get -yq install libxml-sax-expat-perl
#apt-get -yq install libxml-simple-perl
apt-get -yq install libcanary-stability-perl
apt-get -yq install libcommon-sense-perl
apt-get -yq install libtypes-serialiser-perl
apt-get -yq install libjson-xs-perl
apt-get -yq install libproc-pid-file-perl
apt-get -yq install libtest-fatal-perl
apt-get -yq install libjson-perl
### security upgrades and cleanup
unattended-upgrades
apt -yq autoremove
apt-get clean
