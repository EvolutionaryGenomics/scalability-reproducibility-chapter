#!/usr/bin/env nextflow

/* 
 * Run using the following command: 
 * 
 *   nextflow run workflow.nf -with-docker evolutionarygenomics/scalability
 * 
 * 
 * The following parameters can be provided as command line options  
 * replacing the prefix `params.` with `--` e.g.:   
 * 
 *   nextflow run workflow.nf --ctl_file /some/path/to/your/paml0-3.ctl 
 * 
 */
params.ctl_file = "$baseDir/../data/paml0-3.ctl"
params.cluster = "$baseDir/../data/cluster00*"

paml_ctl_file = file(params.ctl_file)
cluster_dir_ch = Channel.fromPath(params.cluster,type: "dir")

process clustalOmega {
    
    stageInMode "copy"

    input:
    file cluster from cluster_dir_ch

    output:
    file "$cluster" into clustal_outputs 
    
    script:
    """
    clustalo -i $cluster/aa.fa --guidetree-out=$cluster/aa.ph > $cluster/aa.aln
    """
}

process pal2nal {
    
    input:
    file cluster from clustal_outputs

    output:
    file "$cluster" into pal2nal_outputs    
 
    script:
    """
    pal2nal.pl -output paml $cluster/aa.aln $cluster/nt.fa > $cluster/alignment.phy
    """
}

process codeML {

    stageInMode "copy"
    publishDir 'paml_results', mode: 'copy'

    input:
    file cluster from pal2nal_outputs
    file ctl from paml_ctl_file

    output:
    file "$cluster"  into codeML_outputs
 
    script:
    """
    cd $cluster
    echo | codeml ../$ctl
    """
}

