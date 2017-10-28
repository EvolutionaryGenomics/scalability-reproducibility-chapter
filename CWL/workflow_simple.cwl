#!/usr/bin/env cwl-runner
class: Workflow

cwlVersion: v1.0
requirements:
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}

inputs:
  proteins:
    type: File[]
    label: List of protein sequence files
  nucleotides:
    type: File[]
    label: Matching list of nucleotide sequence files

outputs:
    results:
      type: File[]
      outputSource: alignment/results

steps:
  alignment:
    run: per_cluster_workflow.cwl
    in:
      proteins_to_align: proteins
      nucleotides: nucleotides
    out: [ results ]
    scatter: [ proteins_to_align, nucleotides ]
    scatterMethod: dotproduct

