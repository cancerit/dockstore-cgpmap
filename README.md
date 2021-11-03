# dockstore-cgpmap

`dockstore-cgpmap` provides a complete multi threaded BWA mem mapping workflow.  This has been
packaged specifically for use with the [Dockstore.org](https://dockstore.org/) framework.

[![Gitter Badge][gitter-svg]][gitter-badge]

[![Quay Badge][quay-status]][quay-repo]

| Master                                        | Develop                                         |
| --------------------------------------------- | ----------------------------------------------- |
| [![Master Badge][travis-master]][travis-base] | [![Develop Badge][travis-develop]][travis-base] |

* [Supported input formats](#supported-input-formats)
* [Options for customisation:](#options-for-customisation)
* [Usable Cores](#usable-cores)
* [Run instructions](#run-instructions)
* [Development](#development)
	* [Verifying your deployment](#verifying-your-deployment)
	* [Development environment](#development-environment)
	* [Release process](#release-process)
* [LICENCE](#licence)

## Supported input formats

* Multiple BAM
* Multiple CRAM
* Multiple fastq[.gz] (paired or interleaved)
  * Please see [PCAP-core/bin/bwa_mem.pl][bwa-mem.pl] for formatting of file names.

## Options for customisation:

* BWA specific mapping parameters (defaults are based on attempts at a global standard)
* Optionally output CRAM (scramble parameters can be modified)
* Optionally run with BWA-MEM2
* Optionally run with bwa-kit post-processing (for calling on alternative contigs)

## Run instructions

The full documentation covering input files, optional parameters, and methods of running dockstore-cgpmap can be found in the [github wiki][github-wiki].

## Development

### Development environment

This project uses git pre-commit hooks.  Please enable them to prevent inappropriate large files
being included.  Any pull request found not to have adhered to this will be rejected and the branch
will need to be manually cleaned to keep the repo size down.

Activate the hooks with

```
git config core.hooksPath git-hooks
```

### Release process

This project is maintained using HubFlow.

1. Make appropriate changes
2. Bump version in `Dockerfile` and `cwls/mixins/requirements.yml`
3. Push changes
4. Check state on Travis
5. Generate the release (add notes to GitHub)
6. Confirm that image has been built on [quay.io][quay-builds]
7. Update the [dockstore][dockstore-cgpmap] entry, see [their docs][dockstore-get-started].

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
[github-wiki]: https://github.com/cancerit/dockstore-cgpmap/wiki

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
