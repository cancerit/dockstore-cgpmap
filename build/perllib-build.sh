#!/bin/bash

set -eux

apt-get -yq update
# install all perl libs, identify by grep of cgp_box_stack build "grep 'Successfully installed' build_stack.log"
# much faster, items needing later versions will still upgrade
# still install those that get an upgrade though as dependancies will be resolved
apt-get -yq install libwww-perl
apt-get -yq install libextutils-cbuilder-perl # gets upgraded
apt-get -yq install libmodule-build-perl # gets upgraded
apt-get -yq install libextutils-helpers-perl
apt-get -yq install libextutils-config-perl
apt-get -yq install libextutils-installpaths-perl
apt-get -yq install libmodule-build-tiny-perl
apt-get -yq install libfile-sharedir-install-perl # gets upgraded
apt-get -yq install libclass-inspector-perl
apt-get -yq install libfile-sharedir-perl
apt-get -yq install libsub-exporter-progressive-perl
apt-get -yq install libconst-fast-perl
apt-get -yq install libfile-which-perl # gets upgraded
apt-get -yq install libio-string-perl
apt-get -yq install libdata-stag-perl
apt-get -yq install libtest-deep-perl
apt-get -yq install libtext-diff-perl
apt-get -yq install libcapture-tiny-perl # possible may need more recent version, should upgrade via makefiles in CGP code if needed
apt-get -yq install libtest-differences-perl
apt-get -yq install libtest-simple-perl # gets upgraded
apt-get -yq install libdevel-stacktrace-perl
apt-get -yq install libclass-data-inheritable-perl
apt-get -yq install libexception-class-perl
apt-get -yq install libsub-uplevel-perl
apt-get -yq install libtest-exception-perl
apt-get -yq install libtest-warn-perl
apt-get -yq install libtest-most-perl
apt-get -yq install libbio-perl-perl
apt-get -yq install libtry-tiny-perl
apt-get -yq install libappconfig-perl
apt-get -yq install libtest-leaktrace-perl
apt-get -yq install libtemplate-perl
apt-get -yq install libio-stringy-perl
apt-get -yq install libconfig-inifiles-perl
apt-get -yq install libdata-uuid-perl
apt-get -yq install liblog-message-perl
apt-get -yq install liblog-message-simple-perl
apt-get -yq install libterm-ui-perl
apt-get -yq install libversion-perl # gets upgraded
apt-get -yq install libxml-namespacesupport-perl
apt-get -yq install libxml-sax-base-perl
apt-get -yq install libxml-sax-perl
apt-get -yq install libxml-sax-expat-perl
apt-get -yq install libxml-simple-perl
apt-get -yq install libjson-perl
apt-get -yq install libdevel-cover-perl
apt-get -yq install libtest-fatal-perl
apt-get -yq install libdevel-symdump-perl
apt-get -yq install libpod-coverage-perl
apt-get -yq install libproc-pid-file-perl
apt-get -yq install libcanary-stability-perl
apt-get -yq install libcommon-sense-perl
apt-get -yq install libtypes-serialiser-perl
apt-get -yq install libjson-xs-perl
apt-get -yq install libproc-processtable-perl
apt-get -yq install libfile-remove-perl
apt-get -yq install libtest-object-perl
apt-get -yq install libexporter-tiny-perl
apt-get -yq install libxsloader-perl # gets upgraded
apt-get -yq install liblist-moreutils-perl
apt-get -yq install libtask-weaken-perl
apt-get -yq install libtest-nowarnings-perl
apt-get -yq install libparams-util-perl
apt-get -yq install libhook-lexwrap-perl
apt-get -yq install libtest-subcalls-perl
apt-get -yq install libclone-perl
apt-get -yq install libppi-perl
apt-get -yq install libcss-tiny-perl
apt-get -yq install libppi-html-perl
apt-get -yq install libmodule-runtime-perl
apt-get -yq install libdist-checkconflicts-perl
apt-get -yq install libsub-identify-perl
apt-get -yq install libpackage-stash-xs-perl
apt-get -yq install libmodule-implementation-perl
apt-get -yq install libpackage-stash-perl
apt-get -yq install libvariable-magic-perl
apt-get -yq install libb-hooks-endofscope-perl
apt-get -yq install libnamespace-clean-perl
apt-get -yq install libnamespace-autoclean-perl
apt-get -yq install libmro-compat-perl
apt-get -yq install libeval-closure-perl
apt-get -yq install librole-tiny-perl
apt-get -yq install libscalar-list-utils-perl # gets upgraded
apt-get -yq install libdatetime-locale-perl
apt-get -yq install libclass-singleton-perl
apt-get -yq install libdatetime-timezone-perl
apt-get -yq install libdatetime-perl
apt-get -yq install libautodie-perl # gets upgraded
apt-get -yq install libsort-key-perl
apt-get -yq install liblog-log4perl-perl
apt-get -yq install libfile-type-perl
apt-get -yq install libnumber-format-perl
apt-get -yq install libipc-run-perl
apt-get -yq install libstatistics-basic-perl
apt-get -yq install libmath-combinatorics-perl
apt-get -yq install libparse-yapp-perl
apt-get -yq install libxml-writer-perl
apt-get -yq install libgraph-readwrite-perl
apt-get -yq install libarchive-extract-perl
apt-get -yq install libgraph-perl
### security upgrades and cleanup
unattended-upgrades
apt -yq autoremove
apt-get clean
