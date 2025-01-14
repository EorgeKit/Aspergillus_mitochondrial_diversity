#!/bin/bash
#PBS -l select=3:ncpus=24:mpiprocs=24:mem=120gb
#PBS -N indexing_announced_contigs
#PBS -q normal
#PBS -P CBBI1470
#PBS -l walltime=8:00:00
#PBS -m abe
#PBS -M alleankyalo@gmail.com

#Author: GEORGE KITUNDU
#Date: sept 18, 2024

eval "$(conda shell.bash hook)"
conda activate bwt2

##data variables
ref_contigs=/mnt/lustre/users/maloo/mbinda-George/data/
results_dir=/mnt/lustre/users/maloo/mbinda-George/analysis/mapping_2_genome

##indexing announced reference contigs
for ref_file in $ref_contigs/announced-contigs/*
do
#make the index directory incase bowtie doesnt make on its own
mkdir -p $results_dir/index-announced/$(basename -s .fa $ref_file)
#give the index dir a variable
index_dir=$results_dir/index-announced/$(basename -s .fa $ref_file)

#confirm you are running the right files
echo "This is sample $(basename -s .fa $ref_file)"
echo "This is ref FASTA file: $(basename $ref_file)"
echo
echo "Indexing $(basename $ref_file)"
echo

#run bowtie indexing
bowtie2-build  $ref_file $index_dir/$(basename -s .fa $ref_file) \
--verbose --threads 70

#confirm you are done with indexing
echo
echo "Done indexing $(basename $ref_file)"
done

# ##indexing mitogenome refs
# #make the index directory incase bowtie doesnt make on its own
# mkdir -p $results_dir/index-mito
# #give the index dir a variable
# index_dir=$results_dir/index-mito

# bowtie2-build  $ref_contigs/mitogenomes_refs/mito_refs.fasta \
# $index_dir/$(basename -s .fasta $ref_contigs/mito_refs.fasta) \
# --verbose --threads 70