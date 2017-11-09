#!/usr/bin/env cwl-runner
class: Workflow

cwlVersion: v1.0

inputs:
    proteins_to_align:
      type: File
      label: proteins
    nucleotides: File

outputs:
    alignment1:
      type: File
      outputSource: clustal/alignment
      label: proteins alignment
    guide_tree:
      type: File
      outputSource: clustal/guide_tree
      label: guide tree
    alignment2:
      type: File
      outputSource: pal2nal/alignment
      label: nucleotides alignment
    results:
      type: File
      outputSource: codeml/results
      label: dN/dS results


steps:
  clustal:
    run: clustalo.cwl
    in:
        multi_sequence: proteins_to_align
    out: [alignment, guide_tree]

  pal2nal:
    run: pal2nal.cwl
    in:
      protein_alignment: clustal/alignment
      nucleotides: nucleotides
    out: [alignment]

  codeml:
    run: codeml.cwl
    in:
       sequences: pal2nal/alignment
       tree: clustal/guide_tree
    out: [results]
