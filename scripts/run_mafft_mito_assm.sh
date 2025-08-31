#!/bin/bash
#PBS -l select=3:ncpus=24:mpiprocs=24:mem=120gb
#PBS -N "MAFFT_alignment_mitogenomes_assemblies"
#PBS -q normal
#PBS -P CBBI1470
#PBS -l walltime=48:00:00
#PBS -m abe
#PBS -M georgekitundu2@gmail.com

#Author: GEORGE KITUNDU
#Date: Jul 23, 2025

# Exit immediately if a command exits with a non-zero status.
set -e

module load chpc/BIOMODULES
module load mafft/7.453

# --- Configuration ---
# The directory containing your renamed fasta files
INPUT_DIR="/mnt/lustre/users/maloo/mbinda-George/analysis/mitogenome_fasta_headers_renamed" 

# Output directory for the MAFFT alignment result
# This will be created within the current working directory
OUTPUT_ALIGNMENT_DIR="/mnt/lustre/users/maloo/mbinda-George/analysis/mafft_mitogenome_alignment_results"

# Name of the combined input FASTA file for MAFFT
COMBINED_INPUT_FASTA="combined_rotated_mitogenomes.fa"

# Name of the final aligned FASTA file
ALIGNED_OUTPUT_FASTA="combined_rotated_mitogenomes_aligned.fasta"

# Path to the MAFFT executable (assumes 'mafft' is in PATH or loaded via module)
MAFFT_PATH="mafft"

# Number of CPU threads for MAFFT to use
# Adjust based on your available resources. MAFFT can be very demanding.
MAFFT_THREADS=20

# --- Script Start ---
echo "Starting MAFFT Multiple Sequence Alignment. 🧬"
echo "Input directory: $INPUT_DIR"
echo "Output directory: ${OUTPUT_ALIGNMENT_DIR}"
echo "MAFFT threads: ${MAFFT_THREADS}"
echo "---------------------------------------------------"

# Create the output directory if it doesn't exist
mkdir -p "${OUTPUT_ALIGNMENT_DIR}"

# # 1. Combine all input FASTA files into a single file for MAFFT
# echo "Combining all input FASTA files into ${COMBINED_INPUT_FASTA}..."
# # Use find to get all fasta files and concatenate them
# find "${INPUT_DIR}" -type f -name "*.fa" -exec cat {} + > "${OUTPUT_ALIGNMENT_DIR}/${COMBINED_INPUT_FASTA}"
# # Check if the combined file was created and is not empty
# if [ ! -s "${OUTPUT_ALIGNMENT_DIR}/${COMBINED_INPUT_FASTA}" ]; then
#     echo "Error: Combined input FASTA file is empty or not created. Check input directory and file names." >&2
#     exit 1
# fi
# echo "Combined FASTA file created: ${OUTPUT_ALIGNMENT_DIR}/${COMBINED_INPUT_FASTA}"

# 2. Run MAFFT for Multiple Sequence Alignment
echo "Running MAFFT alignment..."
# --auto: Automatically selects the appropriate strategy based on data size and characteristics
# --thread: Specifies the number of threads
# Input is the combined FASTA, output is the aligned FASTA
"${MAFFT_PATH}" \
--auto --thread "${MAFFT_THREADS}" \
    "${OUTPUT_ALIGNMENT_DIR}/$COMBINED_INPUT_FASTA" > "${OUTPUT_ALIGNMENT_DIR}/$ALIGNED_OUTPUT_FASTA"

# Check MAFFT's exit status
if [ $? -eq 0 ]; then
    echo "MAFFT alignment completed successfully. ✅"
    echo "Final alignment saved to: ${OUTPUT_ALIGNMENT_DIR}/${ALIGNED_OUTPUT_FASTA}"
else
    echo "Error: MAFFT alignment failed. ❌ Please check MAFFT installation, input files, and resources." >&2
    exit 1
fi

echo "---------------------------------------------------"
echo "Multiple Sequence Alignment process finished. 🎉"
