#!/bin/bash

eval "$(conda shell.bash hook)"
conda activate rotate # Activate the conda environment with the rotate package

#Variables
ASSM_DIR="/mnt/lustre/users/maloo/mbinda-George/analysis/mitogenome_fasta_headers_renamed"
MATCHING_SEQ="tatttaaagatttagttactatctttattttctttatagta" #conserved sequence of Aspergillus flavus cytochrome B from genbank accession MT335777.1
MISMATCH_VALUE=5

for dir in $ASSM_DIR/*/;
 do 
 echo "This is dir: $dir";  
 for file in $dir/*fasta; 
 do echo "This is file :$file"; 
 echo;  
 
 rotate \
 -s $MATCHING_SEQ \
 -m $MISMATCH_VALUE $file \
 > $dir/$(basename -s .fasta $file)_rotated.fa; 
 
 done; 
done