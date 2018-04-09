#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

hints:  # Four different ways to specify the runtime environment
  DockerRequirement: # 1. Remote Docker container
    dockerPull: quay.io/biocontainers/paml:4.9--1
    # # 2. Since paml is packaged for Debian we could have used the directive
    # # below if there wasn't paml container available from biocontainers.pro
    # dockerImageId: debian-paml
    # dockerFile: |
    #   FROM debian:sid
    #   RUN apt-get update && \
    #     DEBIAN_FRONTEND=noninteractive apt-get install -yq \
    #     --no-install-recommends paml
  SoftwareRequirement:
    packages:
      - package: paml  # 3. By common name
        specs: [ "https://identifiers.org/rrid/RRID:SCR_014932" ]
          # 4. And by identifier
  InitialWorkDirRequirement:
    listing:
      # Here we generate the configuration file dynamically, thus freeing the
      # user from particular file name or directory layout requirements
      # If needed, any number of the settings below could be exposed to users
      # of this CWL description as configurable inputs
      - entryname: paml0-3.ctl
        entry: |
          seqfile  = $(inputs.sequences.path)
          treefile = $(inputs.tree.path)
          outfile = results0-3.txt   * main result file name
          noisy = 9        * 0,1,2,3,9: how much rubbish on the screen
          verbose = 1      * 1:detailed output
          runmode = 0      * 0:user defined tree
          seqtype = 1      * 1:codons
          CodonFreq = 2    * 0:equal, 1:F1X4, 2:F3X4, 3:F61
          model = 0        * 0:one omega ratio for all branches
                           * 1:separate omega for each branch
                           * 2:user specified dN/dS ratios for branches
          NSsites = 0 3 
          icode = 0        * 0:universal code
          fix_kappa = 0    * 1:kappa fixed, 0:kappa to be estimated
          kappa = 4        * initial or fixed kappa
          fix_omega = 0    * 1:omega fixed, 0:omega to be estimated
          omega = 5        * initial omega
                           * RateAncestor = 1
          ncatG = 3        * num. of categories in the dG or AdG models of rates
          getSE = 0        * 0: don't want them, 1: want S.E.s of estimates

inputs:
  sequences: File
  tree: File

outputs:
  results:
    type: File
    outputBinding: { glob: results0-3.txt }

baseCommand: [ codeml, paml0-3.ctl ]
