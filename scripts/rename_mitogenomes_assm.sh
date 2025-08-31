#!/bin/bash


# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# The base directory where your 'X_mitogenome_assembly' folders are located.
# YOU MUST RUN THIS SCRIPT FROM THIS DIRECTORY:
# /mnt/lustre/users/maloo/mbinda-George/analysis/getorganelle_assemblies_all_reads
INPUT_BASE_DIR="/mnt/lustre/users/maloo/mbinda-George/analysis/getorganelle_assemblies_all_reads" 

# The base directory where all new files with renamed headers will be stored.
# This directory will mirror the input structure.
OUTPUT_BASE_DIR="/mnt/lustre/users/maloo/mbinda-George/analysis/mitogenome_fasta_headers_renamed"

# --- Script Start ---
echo "Starting FASTA header renaming process. 🏷️"
echo "Input base directory: $(pwd)"
echo "New files with renamed headers will be stored in: ${OUTPUT_BASE_DIR}"
echo "---------------------------------------------------"

# Create the main output directory if it doesn't exist
mkdir -p "${OUTPUT_BASE_DIR}"

# Find all relevant fasta files and process them
# We're looking for files ending with '.fasta' within the INPUT_BASE_DIR and its subdirectories.
find "${INPUT_BASE_DIR}" -type f -name "fungus_mt*.fasta" | while read -r fasta_path; do
    # Extract the sample/isolate name from the parent directory's name
    # e.g., for '10B_mitogenome_assembly/fungus_mt...', this extracts '10B'
    sample_name=$(basename "$(dirname "$fasta_path")" | cut -d'_' -f1)

    # Construct the new header (e.g., >10B_mtDNA)
    new_header=">${sample_name}_mtDNA"

    # Determine the relative path of the fasta file from the INPUT_BASE_DIR
    # This is needed to replicate the directory structure in the output
    relative_path="${fasta_path#${INPUT_BASE_DIR}/}" # Removes the INPUT_BASE_DIR/ prefix

    # Define the full path for the new file in the output directory
    output_filepath="${OUTPUT_BASE_DIR}/${relative_path}"

    # Create the necessary parent directories for the output file
    mkdir -p "$(dirname "${output_filepath}")"

    echo "Processing '${fasta_path}': Renaming header to '${new_header}'"
    echo "  Output file: '${output_filepath}'"

    # Use sed to replace the first line (FASTA header)
    # 1s: apply substitution only to the first line
    # ^>: match the start of the line followed by '>'
    # .*: match any characters after '>'
    # >${sample_name}_mtDNA: replace with the new header
    sed "1s/^>.*$/${new_header}/" "${fasta_path}" > "${output_filepath}"
done

echo "---------------------------------------------------"
echo "FASTA header renaming complete. All new files are in '${OUTPUT_BASE_DIR}'. 🎉"
echo "Original files remain unchanged. 👍"
