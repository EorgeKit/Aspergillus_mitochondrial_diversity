#!/bin/bash

#PBS -l select=1:ncpus=24:mpiprocs=24:mem=120gb
#PBS -N getorganelle_assembly_all_reads
#PBS -q normal
#PBS -P CBBI1470
#PBS -l walltime=48:00:00
#PBS -m abe
#PBS -M georgekitundu2@gmail.com

#Author: GEORGE KITUNDU
#Date: Jul 24, 2025

eval "$(conda shell.bash hook)"
conda activate getorg 

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Base directory where your mapped paired-end FASTQ files are located
# This should be the MAPPED_FASTQ_OUTPUT_DIR from the previous script
MAPPED_FASTQ_BASE_DIR="/mnt/lustre/users/maloo/mbinda-George/data/raw_data"

# Output directory for GetOrganelle assemblies
GETORGANELLE_OUTPUT_DIR="/mnt/lustre/users/maloo/mbinda-George/analysis/getorganelle_assemblies_all_reads"

# Path to the GetOrganelle executable (assumes 'get_organelle_from_reads.py' is in PATH or loaded via module)
GETORGANELLE_PATH="get_organelle_from_reads.py"

# Number of CPU threads for GetOrganelle to use per sample
GETORGANELLE_THREADS=70 # Adjust based on your available resources

# --- Script Start ---
echo "Starting GetOrganelle assembly for fungal mitochondrial genomes."
echo "Input mapped FASTQ directory: ${MAPPED_FASTQ_BASE_DIR}"
echo "Output assemblies directory: ${GETORGANELLE_OUTPUT_DIR}"
echo "GetOrganelle threads per sample: ${GETORGANELLE_THREADS}"
echo "---------------------------------------------------"

# Create the main output directory for GetOrganelle assemblies
mkdir -p "${GETORGANELLE_OUTPUT_DIR}"


# Find all sample subdirectories within the mapped FASTQ base directory
# Example: /mnt/lustre/.../mapped_reads_fastq/10B/
find "${MAPPED_FASTQ_BASE_DIR}" -mindepth 1 -maxdepth 1 -type d | while read sample_fastq_dir; do

    # Extract sample ID (e.g., "10B" from ".../10B/")
    sample_id=$(basename "${sample_fastq_dir}")

    # Construct paths to the R1 and R2 FASTQ files
    # This assumes previous script output: sample_id.mapped.R1.fastq.gz
    r1_fastq="${sample_fastq_dir}/${sample_id}_1.fastq.gz"
    r2_fastq="${sample_fastq_dir}/${sample_id}_2.fastq.gz"

    echo ""
    echo "--- Processing sample: ${sample_id} ---"
    echo "  Input R1: ${r1_fastq}"
    echo "  Input R2: ${r2_fastq}"

    # Check if both R1 and R2 FASTQ files exist
    if [ ! -f "${r1_fastq}" ] || [ ! -f "${r2_fastq}" ]; then
        echo "  Error: Paired-end FASTQ files not found for ${sample_id}. Skipping this sample." >&2
        continue # Skip to the next sample
    fi

    # Define the output directory for this specific sample's GetOrganelle assembly
    sample_assembly_output_dir="${GETORGANELLE_OUTPUT_DIR}/${sample_id}_mitogenome_assembly"
    mkdir -p "${sample_assembly_output_dir}"

    echo "  Starting GetOrganelle assembly for ${sample_id}..."
    echo "  Assembly output will be in: ${sample_assembly_output_dir}"

    # Run GetOrganelle assembler
    # -F fungus: Specify fungus as the target organelle type
    # -i: Input FASTQ files (comma-separated, R1 and R2)
    # -o: Output directory for this sample's assembly
    # -r: Path to the reference sequences for baiting
    # -t: Number of threads
    # --verbose: Optional, for more detailed output
    "${GETORGANELLE_PATH}" \
        -F fungus_mt \
        -1 "${r1_fastq}" \
        -2 "${r2_fastq}" \
        -o "${sample_assembly_output_dir}" \
        -t "${GETORGANELLE_THREADS}" \
        --reduce-reads-for-coverage inf --max-reads inf \
        --verbose --continue 


    echo "  -> GetOrganelle assembly completed for ${sample_id}."

done

echo ""
echo "All GetOrganelle assembly processes complete."
echo "Assembled mitochondrial genomes are located in subdirectories within '${GETORGANELLE_OUTPUT_DIR}'."
