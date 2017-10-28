#!/usr/bin/env cwl-runner
class: Workflow

cwlVersion: v1.0
requirements:
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  clusters:
    type: Directory
    label: A directory of directories
    doc: |
      Each sub-directory should contain a single protein (aa.fa) and a single
      nucleotide sequence (nt.fa) file. The name of the sub-directory will be
      preserved.

outputs:
    results:
      type: File[]
      outputSource: alignment/results
    names:
      type: string[]
      outputSource: extract_clusters/names

steps:
  extract_clusters:
    in:
      clusters: clusters
    out: [ proteins, nucleotides, names ]
    run:
      class: ExpressionTool
      requirements: { InlineJavascriptRequirement: {}}
      inputs:
        clusters: Directory
      outputs:
        proteins: File[]
        nucleotides: File[]
        names: string[]
      expression: |
        ${ var proteins = [];
           var nucleotides = [];
           var names = [];
           inputs.clusters.listing.forEach(function (item) {
             if (item.class == "Directory") {
               names.push(item.basename);
               item.listing.forEach(function (item2) {
                 if (item2.basename.startsWith("nt")) {
                   nucleotides.push(item2);
                 } else if (item2.basename.startsWith("aa")) {
                   proteins.push(item2);
                 };
               });
             };
           });
           return { "proteins": proteins,
                    "nucleotides": nucleotides,
                    "names": names };
         }
  
  alignment:
    run: per_cluster_workflow.cwl
    in:
      proteins_to_align: extract_clusters/proteins
      nucleotides: extract_clusters/nucleotides
    out: [ results ]
    scatter: [ proteins_to_align, nucleotides ]
    scatterMethod: dotproduct

