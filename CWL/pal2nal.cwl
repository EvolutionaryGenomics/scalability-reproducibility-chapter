#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

hints:  # Three different ways to specify the runtime environment
  DockerRequirement:
    dockerImageId: pal2nal
    # 1. Via docker container
  SoftwareRequirement:
    packages:
      - package: pal2nal  # 2. By common name
        specs: [ "https://doi.org/10.1093/nar/gkl315" ]
          # 3. And by identifier

inputs:
  protein_alignment:
    type: File
    label: Multiple sequence alignment
  nucleotides:
    type: File
    label: nucleotide sequence

outputs:
  alignment:
    type: stdout
    label: Multiple sequence alignment

baseCommand: pal2nal.pl
arguments:
  - valueFrom: paml
    prefix: -output
  - $(inputs.protein_alignment.path)
  - $(inputs.nucleotides.path)
