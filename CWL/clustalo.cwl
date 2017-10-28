#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

hints:  # Three different ways to specify the runtime environment
  DockerRequirement:
    dockerPull: biocontainers/clustal-omega
    # 1. Via DockerHub or other Docker registry
    # could have used dockerImageId to be very specific
  SoftwareRequirement:
    packages:
      - package: clustalo  # 2. By common name (useful with bioconda)
        specs: [ "https://identifiers.org/rrid/RRID:SCR_001591" ]
          # 3. And by identifier

inputs:
  multi_sequence: File

outputs:
  alignment:
    type: stdout
    label: Multiple sequence alignment
  guide_tree:
    type: File
    outputBinding:
      glob: $(inputs.multi_sequence.nameroot).ph

baseCommand: clustalo
arguments:
  - -i
  - $(inputs.multi_sequence.path)
  - --guidetree-out
  - $(inputs.multi_sequence.nameroot).ph
  - --threads
  - $(runtime.cores)
