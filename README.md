# dockstore-cgpmap

`dockstore-cgpmap` provides a complete multi threaded BWA mem mapping workflow.  This has been
packaged specifically for use with the [Dockstore.org](https://dockstore.org/) framework.

[![Join the chat at https://gitter.im/dockstore-cgpmap/general](https://badges.gitter.im/dockstore-cgpmap/general.svg)](https://gitter.im/dockstore-cgpmap/general?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Docker Repository on Quay](https://quay.io/repository/wtsicgp/dockstore-cgpmap/status "Docker Repository on Quay")](https://quay.io/repository/wtsicgp/dockstore-cgpmap)

[![Build Status](https://travis-ci.org/cancerit/dockstore-cgpmap.svg?branch=master)](https://travis-ci.org/cancerit/dockstore-cgpmap) : master  
[![Build Status](https://travis-ci.org/cancerit/dockstore-cgpmap.svg?branch=develop)](https://travis-ci.org/cancerit/dockstore-cgpmap) : develop

## Supports input in following formats:

* Multiple BAM
* Multiple CRAM
* Multiple fastq[.gz] (paired or interleaved)
  * Please see [PCAP-core/bin/bwa_mem.pl](https://github.com/cancerit/PCAP-core/blob/master/bin/bwa_mem.pl)
for formatting of file names.

## Options for customisation:

* BWA specific mapping parameters (defaults are based on attempts at a global standard).
* Optionally output CRAM (scramble parameters can be modified)

## Environment variables

When running outside of a docker container you can set the number of CPUs via:

* `export CPU=N` - If not set detects available cores on system.

## Test data

The `examples/sample_configs.local.json` contains test data that can be used to verify the tool.

You can find expected outputs on the Sanger Institute FTP site: [dockstore-cgpmap-expected.tar.gz](ftp://ftp.sanger.ac.uk/pub/cancer/dockstore/expected/dockstore-cgpmap-expected.tar.gz)

This project includes the C program `diff_bams` that can be used to compare the generated BAM file
to the one in the archive:

```bash
$ export CGPMAP_TAG=0.2.0
$ docker run -ti --rm \
  -v /tmp/new:/var/spool/new \
  -v /tmp/old:/var/spool/old \
  quay.io/wtsicgp/dockstore-cgpmap:$CGPMAP_TAG \
    diff_bams -a /var/spool/old/mapped.bam \
              -b /var/spool/new/mapped.bam
```

Expected output:

```
Reference sequence count passed
Reference sequence order passed
Matching records: 1000001
```

## Release process

This project is maintained using HubFlow.

1. Make appropriate changes
1. Bump version in `Dockerfile` and `Dockstore.cwl`
1. Push changes
1. Check state on Travis - not possible due to build time
1. Generate the release (add notes to GitHub)
1. Confirm that image has been built on [quay.io](https://quay.io/repository/wtsicgp/dockstore-cgpmap?tab=builds)
1. Update the [dockstore](https://dockstore.org/containers/quay.io/wtsicgp/dockstore-cgpmap) entry, see [their docs](https://dockstore.org/docs/getting-started-with-dockstore).

## LICENCE

```
Copyright (c) 2016-2018 Genome Research Ltd.

Author: Cancer Genome Project <cgpit@sanger.ac.uk>

This file is part of dockstore-cgpmap.

dockstore-cgpmap is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation; either version 3 of the License, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

1. The usage of a range of years within a copyright statement contained within
this distribution should be interpreted as being equivalent to a list of years
including the first and last year specified and all consecutive years between
them. For example, a copyright statement that reads ‘Copyright (c) 2005, 2007-
2009, 2011-2012’ should be interpreted as being identical to a statement that
reads ‘Copyright (c) 2005, 2007, 2008, 2009, 2011, 2012’ and a copyright
statement that reads ‘Copyright (c) 2005-2012’ should be interpreted as being
identical to a statement that reads ‘Copyright (c) 2005, 2006, 2007, 2008,
2009, 2010, 2011, 2012’."
```
