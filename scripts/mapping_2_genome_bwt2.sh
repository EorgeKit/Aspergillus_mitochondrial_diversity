#!/bin/bash
#PBS -l select=3:ncpus=24:mpiprocs=24:mem=120gb
#PBS -N aligning_raw_reads_to_mitochondrial_references_resume
#PBS -q normal
#PBS -P CBBI1470
#PBS -l walltime=48:00:00
#PBS -m abe
#PBS -M georgekitundu2@gmail.com

#Author: GEORGE KITUNDU
#Date: sept 21, 2024

eval "$(conda shell.bash hook)"
conda activate bwt2

##data variables
mito_ref="/mnt/lustre/users/maloo/mbinda-George/data/mitogenomes_refs/combined_mito_ref.fasta"
data_dir=/mnt/lustre/users/maloo/mbinda-George/data/raw_data
results_dir=/mnt/lustre/users/maloo/mbinda-George/analysis/mapping_2_genome
index_dir=/mnt/lustre/users/maloo/mbinda-George/analysis/mapping_2_genome/index-mito

# ##Aligning to announced contigs
# for sample in $ref_contigs/announced-contigs/*
# do
# echo "This is sample $(basename -s .fa $sample)"
# echo
# echo "Aligning sample '$(basename $sample)' to  announced contigs"
# echo

# mkdir -p $results_dir/alignment-announced-contigs/$(basename -s .fa $sample)
# mkdir -p $results_dir/alignment-announced-contigs/$(basename -s .fa $sample)/un-aligned-concordantly
# mkdir -p $results_dir/alignment-announced-contigs/$(basename -s .fa $sample)/aligned-concordantly

# bowtie2   --very-sensitive  --end-to-end -p 70 \
# -x $index_dir/$(basename -s .fa $sample)/$(basename -s .fa $sample) \
# -1 $data_dir/$(basename -s .fa $sample)_1.fastq.gz \
# -2 $data_dir/$(basename -s .fa $sample)_2.fastq.gz \
# -S $results_dir/alignment-announced-contigs/$(basename -s .fa $sample)/$(basename -s .fa $sample).sam \
# --un-conc-gz  $results_dir/alignment-announced-contigs/$(basename -s .fa $sample)/un-aligned-concordantly \
# --al-conc-gz $results_dir/alignment-announced-contigs/$(basename -s .fa $sample)/aligned-concordantly

# echo
# echo "Finished aligning $(basename $sample) to announced contigs"
# echo
# done

##ALigning to mitochondrial genomes

for sample in $(ls $data_dir/*.fastq.gz | cut -d '_' -f 2 | sort -u); 
do
    echo "This is sample $(basename $sample)"
    echo
    echo "Aligning sample '$(basename $sample)' to  mitochondrial references"
    echo


    mkdir -p $results_dir/alignment-mitochondrial-genomes/$(basename $sample)
    mkdir -p $results_dir/alignment-mitochondrial-genomes/$(basename $sample)/un-aligned-concordantly/$mito_ref_idx
    mkdir -p $results_dir/alignment-mitochondrial-genomes/$(basename $sample)/aligned-concordantly/$mito_ref_idx

    echo
    
    bowtie2   --local -p 70 \
    -x $index_dir/$(basename $mito_ref) \
    -1 $data_dir/$(basename $sample)_1.fastq.gz \
    -2 $data_dir/$(basename $sample)_2.fastq.gz \
    -S $results_dir/alignment-mitochondrial-genomes/$(basename $sample)/$mito_ref_idx/$(basename $sample)_$mito_ref_idx.sam \
    --un-conc-gz $results_dir/alignment-mitochondrial-genomes/$(basename $sample)/un-aligned-concordantly/$mito_ref_idx \
    --al-conc-gz $results_dir/alignment-mitochondrial-genomes/$(basename $sample)/aligned-concordantly/$mito_ref_idx

    echo
    echo "Finished aligning $(basename $sample)"
    echo
done

