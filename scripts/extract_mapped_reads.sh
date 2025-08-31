#!/bin/bash
#PBS -l select=2:ncpus=24:mpiprocs=24:mem=120gb
#PBS -N extract_mapped_reads
#PBS -q normal
#PBS -P CBBI1470
#PBS -l walltime=48:00:00
#PBS -m abe
#PBS -M georgekitundu2@gmail.com

#Author: GEORGE KITUNDU
#Date: Jul 18, 2025

module load chpc/BIOMODULES 
module load samtools/1.9

#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e
# Enable verbose output (optional, remove if too chatty)
set -x

# --- Configuration ---
# Base directory containing your sample subdirectories, each with a SAM file
# e.g., /mnt/lustre/users/maloo/mbinda-George/analysis/mapping_2_genome/alignment-mitochondrial-genomes
ALIGNMENT_BASE_DIR="/mnt/lustre/users/maloo/mbinda-George/analysis/mapping_2_genome/alignment-mitochondrial-genomes"

# Output directory for the final mapped FASTQ files
# A subdirectory for each sample will be created here.
MAPPED_FASTQ_OUTPUT_DIR="/mnt/lustre/users/maloo/mbinda-George/analysis/mapped_reads_fastq"

# Path to the Samtools executable (assumes 'samtools' is in PATH or loaded via module)
SAMTOOLS_PATH="samtools"

# --- Script Start ---
echo "Starting concise mapped read extraction to FASTQ..."
echo "Input alignment base directory: ${ALIGNMENT_BASE_DIR}"
echo "Output mapped FASTQ directory: ${MAPPED_FASTQ_OUTPUT_DIR}"
echo "---------------------------------------------------"

# Create the main output directory for FASTQ files
mkdir -p "${MAPPED_FASTQ_OUTPUT_DIR}"

# Find all SAM files matching the pattern and loop through them
# This assumes SAM files are directly in SAMPLE_ID/SAM_FILE_NAME
# Based on your 'ls 10B/' output, it's '10B_.sam' directly under '10B/'
find "${ALIGNMENT_BASE_DIR}" -type f -name "*.sam" | while read input_sam_file; do

    # Extract sample ID from the directory name (e.g., "10B" from ".../10B/10B_.sam")
    sample_id=$(basename "$(dirname "${input_sam_file}")")

    # Define the output directory for this specific sample's FASTQ files
    sample_fastq_output_dir="${MAPPED_FASTQ_OUTPUT_DIR}/${sample_id}"
    mkdir -p "${sample_fastq_output_dir}"

    # Define output FASTQ file paths
    output_fastq_r1="${sample_fastq_output_dir}/${sample_id}.mapped.R1.fastq.gz"
    output_fastq_r2="${sample_fastq_output_dir}/${sample_id}.mapped.R2.fastq.gz"
    output_fastq_singleton="${sample_fastq_output_dir}/${sample_id}.mapped.singleton.fastq.gz" # For reads whose mate was unmapped/filtered

    echo "Processing ${input_sam_file} for sample ${sample_id}..."
    echo "  Output R1: ${output_fastq_r1}"
    echo "  Output R2: ${output_fastq_r2}"
    echo "  Output Singletons: ${output_fastq_singleton}"

    # Use samtools view to filter for mapped reads (-F 4) and pipe to samtools fastq
    # -F 4: Exclude unmapped reads
    # -b: Output BAM (needed for samtools fastq input, though it can take SAM directly, BAM is faster)
    # -h: Include header (needed for valid BAM)
    # Then pipe to samtools fastq
    "${SAMTOOLS_PATH}" view -b -h -F 4 "${input_sam_file}" | \
    "${SAMTOOLS_PATH}" fastq \
        -1 "${output_fastq_r1}" \
        -2 "${output_fastq_r2}" \
        -s "${output_fastq_singleton}" \
        -N \
        -c '!' \
        -

    echo "  -> Mapped FASTQ files created for ${sample_id}."

done

echo "All mapped read extraction to FASTQ complete."
echo "Mapped FASTQ files are located in '${MAPPED_FASTQ_OUTPUT_DIR}'."