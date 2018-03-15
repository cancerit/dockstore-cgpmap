# dockstore-cgpmap

`dockstore-cgpmap` provides a complete multi threaded BWA mem mapping workflow.  This has been
packaged specifically for use with the [Dockstore.org](https://dockstore.org/) framework.

[![Gitter Badge][gitter-svg]][gitter-badge]

[![Quay Badge][quay-status]][quay-repo]

| Master                                        | Develop                                         |
| --------------------------------------------- | ----------------------------------------------- |
| [![Master Badge][travis-master]][travis-base] | [![Develop Badge][travis-develop]][travis-base] |

<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Supported input formats](#supported-input-formats)
- [Options for customisation:](#options-for-customisation)
- [Usable Cores](#usable-cores)
- [Other uses](#other-uses)
	- [Native docker](#native-docker)
	- [Singularity](#singularity)
- [Verifying your deployment](#verifying-your-deployment)
- [Development environment](#development-environment)
- [Release process](#release-process)
- [LICENCE](#licence)

<!-- /TOC -->

## Supported input formats

* Multiple BAM
* Multiple CRAM
* Multiple fastq[.gz] (paired or interleaved)
  * Please see [PCAP-core/bin/bwa_mem.pl][bwa-mem.pl] for formatting of file names.

## Options for customisation:

* BWA specific mapping parameters (defaults are based on attempts at a global standard).
* Optionally output CRAM (scramble parameters can be modified)

## Usable Cores

When running outside of a docker container you can set the number of CPUs via:

* `export CPU=N`
* `-threads|-t` option of `ds-cgpmap.pl`

If not set detects available cores on system.

## Other uses

### Native docker

All of the tools installed as part of [PCAP-core][pcap-core] are available for direct use.

```
export CGPMAP_VER=X.X.X
docker pull quay.io/wtsicgp/dockstore-cgpmap:$CGPMAP_VER
# interactive session
docker --rm -ti [--volume ...] quay.io/wtsicgp/dockstore-cgpmap:$CGPMAP_VER bash
```

### Singularity

The resulting docker container has been tested with Singularity.  The command to exec is:

```
ds-cgpmap.pl -h
```

Expected use would be along the lines of:

```
export CGPMAP_VER=X.X.X
singularity pull docker://quay.io/wtsicgp/dockstore-cgpmap:$CGPMAP_VER

singularity exec\
 --workdir /.../workspace  \
 --home /.../workspace:/home  \
 --bind /.../ref/human:/var/spool/ref:ro  \
 --bind /.../example_data/cgpmap/insilico_21:/var/spool/data:ro  \
 dockstore-cgpmap-${CGPMAP_VER}.simg  \
 ds-cgpmap.pl  \
 -r /var/spool/ref/core_ref_GRCh37d5.tar.gz  \
 -i /var/spool/ref/bwa_idx_GRCh37d5.tar.gz  \
 -s SOMENAME  \
 -t 6 \
 /var/spool/data/\*.bam
```

For a system automatically attaching _all local mount points_ (not default singularity behaviour)
you need not specify any `exec` params (workdir, home, bind) but you should specify the `-outdir`
option for `ds-cgpmap.pl` to prevent data being written to your home directory.

By default results are written to the home directory of the container so ensure you bind
a large volume and set the `-home` variable.  As indicated above the location can be overridden
via the options of `ds-cgpmap.pl`

## Verifying your deployment

The `examples/` tree contains test json files populated with data that can be used to verify the
tool.  More details can be found [here](examples/README.md).

The `expected/` tree contains the expected output for each tool.  More details can be found [here](expected/README.md).

## Development environment

This project uses git pre-commit hooks.  Please enable them to prevent inappropriate large files
being included.  Any pull request found not to have adhered to this will be rejected and the branch
will need to be manually cleaned to keep the repo size down.

Activate the hooks with

```
git config core.hooksPath git-hooks
```

## Release process

This project is maintained using HubFlow.

1. Make appropriate changes
1. Bump version in `Dockerfile` and `cwls/mixins/requirements.yml`
1. Push changes
1. Check state on Travis
1. Generate the release (add notes to GitHub)
1. Confirm that image has been built on [quay.io][quay-builds]
1. Update the [dockstore][dockstore-cgpmap] entry, see [their docs][dockstore-get-started].

## LICENCE

```
Copyright (c) 2016-2018 Genome Research Ltd.

Author: CASM/Cancer IT <cgphelp@sanger.ac.uk>

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

<!-- links -->
[bwa-mem.pl]: https://github.com/cancerit/PCAP-core/blob/master/bin/bwa_mem.pl
[cgpmap-expected]: ftp://ftp.sanger.ac.uk/pub/cancer/dockstore/expected
[pcap-core]: https://github.com/cancerit/PCAP-core

<!-- Travis -->
[travis-base]: https://travis-ci.org/cancerit/dockstore-cgpmap
[travis-master]: https://travis-ci.org/cancerit/dockstore-cgpmap.svg?branch=master
[travis-develop]: https://travis-ci.org/cancerit/dockstore-cgpmap.svg?branch=develop

<!-- Gitter -->
[gitter-svg]: https://badges.gitter.im/dockstore-cgp/Lobby.svg
[gitter-badge]: https://gitter.im/dockstore-cgp/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge

<!-- Quay.io -->
[quay-status]: https://quay.io/repository/wtsicgp/dockstore-cgpmap/status
[quay-repo]: https://quay.io/repository/wtsicgp/dockstore-cgpmap
[quay-builds]: https://quay.io/repository/wtsicgp/dockstore-cgpmap?tab=builds

<!-- dockstore -->
[dockstore-cgpmap]: https://dockstore.org/containers/quay.io/wtsicgp/dockstore-cgpmap
[dockstore-get-started]: https://dockstore.org/docs/getting-started-with-dockstore
