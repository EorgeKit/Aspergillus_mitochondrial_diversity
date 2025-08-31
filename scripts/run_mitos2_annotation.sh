#!/bin/bash
#PBS -l select=3:ncpus=24:mpiprocs=24:mem=120gb
#PBS -N run_mitos2_annotation
#PBS -q normal
#PBS -P CBBI1470
#PBS -l walltime=48:00:00
#PBS -m abe
#PBS -M georgekitundu2@gmail.com

eval "$(conda shell.bash hook)"
conda activate mitos2  # Activate the conda environment with MITOS2 installed

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
GETORGANELLE_OUTPUT_DIR="/mnt/lustre/users/maloo/mbinda-George/analysis/getorganelle_assemblies"
MITOS_OUTPUT_DIR="/mnt/lustre/users/maloo/mbinda-George/analysis/mitos2_results"
# Path to MITOS2 reference directory (adjust as needed)
MITOS_REF_DIR="/path/to/mitos/ref"

mkdir -p "${MITOS_OUTPUT_DIR}"

# Loop through each assembly directory
for assembly_dir in "${GETORGANELLE_OUTPUT_DIR}"/*_mitogenome_assembly; do
    sample_id=$(basename "${assembly_dir}" | sed 's/_mitogenome_assembly//')
    
    # Look for a FASTA file in the top level of the assembly directory
    fasta_file=$(find "${assembly_dir}" -maxdepth 1 -type f -name "*.fasta" | head -n 1)
    if [ -z "${fasta_file}" ]; then
        echo "No FASTA file found for sample ${sample_id} in ${assembly_dir}. Skipping."
        continue
    fi

    sample_mitos_out="${MITOS_OUTPUT_DIR}/${sample_id}_mitos2_out"
    mkdir -p "${sample_mitos_out}"

    echo "Running MITOS2 on sample ${sample_id} using ${fasta_file} ..."
    
    # Run MITOS2 annotation:
    # Adjust the command line options as needed.
    runmitos \
        -i "${fasta_file}" \
        -o "${sample_mitos_out}" \
        --ref_dir "${MITOS_REF_DIR}" \
        --cpu 8 \
        --datatype mito \
        --genetic_code 4 \
        --verbose

    echo "MITOS2 annotation completed for ${sample_id}."
done

echo "All MITOS2 annotations complete."