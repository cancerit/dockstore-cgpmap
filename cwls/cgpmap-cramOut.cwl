#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "cgpmap"

label: "CGP BWA-mem mapping flow"

cwlVersion: v1.0

doc:
  $include: includes/doc.yml

requirements:
  - $mixin: mixins/requirements.yml

hints:
  - $mixin: mixins/hints.yml

inputs:
  reference:
    type: File
    doc: "The core reference (fa, fai, dict) as tar.gz"
    inputBinding:
      prefix: -reference
      position: 1
      separate: true

  bwa_idx:
    type: File
    doc: "The BWA indexes in tar.gz"
    inputBinding:
      prefix: -bwa_idx
      position: 2
      separate: true

  sample:
    type: string
    doc: "Sample name to be included in output CRAM header, also used to name final file"
    inputBinding:
      prefix: -sample
      position: 3
      separate: true

  seqslice:
    type: int?
    doc: "seqs_per_slice for CRAM compression [samtools default: 10000]"
    default: 10000
    inputBinding:
      prefix: -seqslice
      position: 4
      separate: true

  bwa:
    type: string?
    default: ' -Y -K 100000000'
    doc: "Mapping and output parameters to pass to BWA-mem, see BWA docs, default ' -Y -K 100000000'"
    inputBinding:
      prefix: -bwa
      position: 5
      separate: true
      shellQuote: true

  groupinfo:
    type: File?
    doc: "Readgroup metadata file for FASTQ inputs"
    inputBinding:
      prefix: -groupinfo
      position: 6
      separate: true

  mmqc:
    type: boolean
    doc: "Apply mismatch QC to reads following duplicate marking."
    inputBinding:
      prefix: -qc
      position: 7

  mmqcfrac:
    type: float?
    default: 0.05
    doc: "Mismatch fraction to set as max before failing a read [0.05]"
    inputBinding:
      prefix: -qcf
      position: 8
      separate: true

  threads:
    type: int?
    doc: "Number of CPUs to use where possible - 0/null/not defined to query host for max"
    inputBinding:
      prefix: -threads
      position: 9
      separate: true

  bwamem2:
    type: boolean
    doc: "Use bwa-mem2 binary"
    inputBinding:
      prefix: -bwamem2
      position: 10

  bwakit:
    type: boolean
    doc: "Use bwakit post-processing"
    inputBinding:
      prefix: -bwakit
      position: 11

  nomarkdup:
    type: boolean
    doc: "Do not mark duplicates"
    inputBinding:
      prefix: -nomarkdup
      position: 12

  dupmode:
    type: string?
    doc: "Duplicate mode as defined by 'samtools markdup' (t)emplate or (s)equence"
    default: 't'
    inputBinding:
      prefix: -dupmode
      position: 13
      separate: true

  legacy:
    type: boolean
    doc: "Use legacy merge/dupmark from biobambam2 tools, slower, more memory"
    inputBinding:
      prefix: -legacy
      position: 14

  seq_in:
    type:
    - 'null'
    - type: array
      items: File
    doc: "Can be BAM, CRAM, fastq (paired or interleaved), BAM/CRAM can be mixed together but not FASTQ."
    inputBinding:
      position: 15

outputs:
  out_cram:
    type: File
    outputBinding:
      glob: $(inputs.sample).cram
    secondaryFiles:
      - .crai
      - .bas
      - .md5
      - .met
      - .maptime

baseCommand: ["/opt/wtsi-cgp/bin/ds-cgpmap.pl", "-cram"]

$schemas: [ http://schema.org/version/9.0/schemaorg-current-http.rdf ]

$namespaces:
  s: http://schema.org/

s:codeRepository: https://github.com/cancerit/dockstore-cgpmap
s:license: https://spdx.org/licenses/AGPL-3.0-only

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0002-5634-1539
    s:email: mailto:cgphelp@sanger.ac.uk
    s:name: Keiran Raine
