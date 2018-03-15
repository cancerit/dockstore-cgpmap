# Example parameters

An example tree exists for each of the possible output types (see cwls tree)

Within the folder for output type there are example of different input type and in some cases
other parameters we would test as routine.

For each `examples/cgpmap/<output>/<params>.json` file there is a corresponding folder named
`expected/cgpmap/<output>/<params>/` containing the expected file listing for the result archive.

e.g.

* JSON: `examples/cgpmap/bamBaiOut/bam_in.json` generates a set of files: `bam_in.bam*`
* These are stored in: `expected/cgpmap/bamBaiOut/bam_in/`

See [`expected/README.md`](../expected/README.md) for content of that area.
