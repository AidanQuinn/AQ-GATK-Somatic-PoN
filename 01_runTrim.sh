#!/bin/bash
#SBATCH -c 4                               	# 1 core
#SBATCH --mem 1G
#SBATCH -t 0-5:00                         	# Runtime of 5 hours, in D-HH:MM format
#SBATCH -p short                           	# Run in short partition
#SBATCH -o ./logs/01_%j.out                 	# File to which STDOUT + STDERR will be written, including job ID in filename
#SBATCH -e ./logs/01_%j.err
#SBATCH --array=1-33

# Load the required modules
module load trimgalore/0.6.6

# Load the useful variables
FASTQS_FILE="/n/scratch/users/s/stq314/2402_ccRCC_WGS/scripts/fastq_files.txt"
SAMPLES_FILE="/n/scratch/users/s/stq314/2402_ccRCC_WGS/scripts/samples.txt"
WORKING_DIR="/n/scratch/users/s/stq314/2402_ccRCC_WGS"
FASTQ_DIR="/n/scratch/users/s/stq314/2402_ccRCC_WGS/usftp21.novogene.com/01.RawData"
UBAM_DIR="/n/scratch/users/s/stq314/2402_ccRCC_WGS/uBAM"
BAM_DIR="/n/scratch/users/s/stq314/2402_ccRCC_WGS/BAM"
BWA_REF="/n/data1/dfci/pedonc/kadoch/share/reference_genomes/GRCh38/GATK/hg38.fa"

####################################################################################
# Set the working directory
cd "${WORKING_DIR}"

####################################################################################
# Read the Nth from the sample file and assign it to the variable
FASTQ=$(sed "${SLURM_ARRAY_TASK_ID}q;d" "$FASTQS_FILE")

# Collect RG info from the filename
IFS="_"
read -ra FASTQ_ARRAY <<< "$FASTQ"
LANE=$(echo "${FASTQ_ARRAY[3]}" | tr -d [:alpha:])

IFS="/"
read -ra FASTQ_ARRAY2 <<< "$FASTQ"
SAMPLE="${FASTQ_ARRAY2[0]}"

unset IFS

####################################################################################
# Perform TrimGalore!
mkdir -p ${FASTQ_DIR}/trimmed

trim_galore --paired \
	-j 4 \
	-o ${FASTQ_DIR}/trimmed \
	--basename ${SAMPLE}_L${LANE} \
	${FASTQ_DIR}/${FASTQ}_1.fq.gz \
	${FASTQ_DIR}/${FASTQ}_2.fq.gz
