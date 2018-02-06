# CHANGES

## NEXT

* Drop pre/post exec functions in `mapping.sh`
* Add ability to pair a groups file with fastq inputs to add info to readgroups
in final BAM/CRAM files (PCAP-core).
* BWA 0.7.17 - bug fixes for future alpine building.
* Biobambam2 2.0.83 - via pre-compiled versions, build script is alpine ready.
* HTSlib + Samtools 1.7
* PCAP-core 4.1.0
  * mismatchQc options added
* cgpBigWig 0.5.0
* Examples moved to more useful naming, now have:
  * `examples/bamOutput` and `examples/cramOutput` each containing:
    * `bam_input.json`
    * `fastq_gz_input.json` - with yaml groupinfo file example.
* 2 different CWL descriptors one for BAM output., another for cram
  * Ensure you use the correct `json` examples.
* Now using secondaryFiles for outputs to reduce repetitive entries in cwl and json.
  * Bugfix to dockstore tool needed for output provisioning, likely 1.3.4 at time of writing.

## 2.0.1

* Test data in `examples/sample_configs.local.json` moved to a non-expiring location.

## 2.0.0

* PCAP-core forked to cancerit and all legacy PCAWG code removed.
* Update to cgpBigWig/libBigWig to handle bug detected in ASCAT.
* First layer of streamlined install process to reduce build time of dependant images.
* Biobambam2 now building from source (previously picked up precompiled 'etch').

## 1.0.8

Fix in PCAP-core to handle passing of sample name when input BAM has no SM tag in header.

## 1.0.7

HTSlib upgades in toolset for consistency.

## 1.0.6

Bump PCAP-core version to fix fastq input handling

## 1.0.5

Adds travis-ci

## 1.0.4

Bad versions in 1.0.3

## 1.0.3

Base PCAP-core upgraded to improve mapping through-put and CPU use.

## 1.0.2

Added build badges

## 1.0.1

Fix CWL to get description to display on Dockstore.org

## 1.0.0

Initial release.  Fully functional.
