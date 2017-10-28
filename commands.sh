clustalo -i data/cluster00001/aa.fa --guidetree-out=data/cluster00001/aa.ph > data/cluster00001/aa.aln
pal2nal.pl -output paml data/cluster00001/aa.aln data/cluster00001/nt.fa > data/cluster00001/alignment.phy
cd data/cluster00001
echo | codeml ../paml0-3.ctl
