TARGETS = list(map(lambda n: "../data/cluster%05d/results0-3.txt" % n, range(1, 73)))

rule all:
  input:
    expand("{cwd}/{target}", cwd=os.getcwd(), target=TARGETS)

rule clustal:
  input:
    "{cluster}/aa.fa"
  output:
    guidetree = "{cluster}/aa.ph",
    align = "{cluster}/aa.aln"
  shell:
    "clustalo -i {input} --guidetree-out={output.guidetree} > {output.align}"

rule pal2nal:
  input:
    "{cluster}/aa.aln"
  output:
    "{cluster}/alignment.phy"
  shell:
    "pal2nal.pl -output paml {input} {wildcards.cluster}/nt.fa > {output}"

rule codeml:
  input: "{cluster}/alignment.phy"
  output: "{cluster}/results0-3.txt"
  shell:
    "cd {wildcards.cluster}; echo | codeml ../paml0-3.ctl"
