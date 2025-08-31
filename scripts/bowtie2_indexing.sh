#!/bin/bash
#PBS -l select=2:ncpus=24:mpiprocs=24:mem=120gb
#PBS -N indx_mitochondrion_refs
#PBS -q normal
#PBS -P CBBI1470
#PBS -l walltime=8:00:00
#PBS -m abe
#PBS -M georgekitundu2@gmail.com

#Author: GEORGE KITUNDU
#Date: April 23, 2024

eval "$(conda shell.bash hook)"
conda activate bwt2

##data variables
ref_mito_seqs=/mnt/lustre/users/maloo/mbinda-George/data/mitogenomes_refs/combined_mito_ref.fasta

results_dir=/mnt/lustre/users/maloo/mbinda-George/analysis/mapping_2_genome

##indexing announced reference contigs

#make the index directory incase bowtie doesnt make on its own
mkdir -p $results_dir/index-mito

#give the index dir a variable
index_dir=$results_dir/index-mito

#confirm you are running the right files
echo "This is reference accession $(basename -s .fasta $ref_mito_seqs)"
echo "This is ref FASTA file:  $ref_mito_seqs"
echo
echo "Indexing $(basename $ref_mito_seqs)"
echo

#run bowtie indexing
bowtie2-build  \
$ref_mito_seqs \
$index_dir/$(basename -s .fa $ref_mito_seqs) \
--verbose \
--threads 46

#confirm you are done with indexing
echo
echo "Done indexing accession $(basename $ref_mito_seqs)"
# done

# ##indexing mitogenome refs
# #make the index directory incase bowtie doesnt make on its own
# mkdir -p $results_dir/index-mito
# #give the index dir a variable
# index_dir=$results_dir/index-mito

# bowtie2-build  $ref_contigs/mitogenomes_refs/mito_refs.fasta \
# $index_dir/$(basename -s .fasta $ref_contigs/mito_refs.fasta) \
# --verbose --threads 70