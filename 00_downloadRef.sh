#!/bin/bash
#SBATCH -c 4                               	# 1 core
#SBATCH --mem 1G
#SBATCH -t 0-5:00                         	# Runtime of 5 hours, in D-HH:MM format
#SBATCH -p short                           	# Run in short partition
#SBATCH -o ./logs/00_%j.out                 	# File to which STDOUT + STDERR will be written, including job ID in filename
#SBATCH -e ./logs/00_%j.err

# Load required modules
module load gcc/9.2.0 samtools/1.15.1
module load gatk/4.1.9.0

# make and orgnaize dirs
mkdir -p /n/data1/dfci/pedonc/kadoch/share/reference_genomes/GRCh38/GATK
REF_DIR=/n/data1/dfci/pedonc/kadoch/share/reference_genomes/GRCh38/GATK

# download reference files
wget -P ${REF_DIR} https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz
gunzip ${REF_DIR}/hg38.fa.gz

# index ref - .fai file before running haplotype caller
samtools faidx ${REF_DIR}/hg38.fa

# ref dict - .dict file before running haplotype caller
gatk CreateSequenceDictionary R=${REF_DIR}/hg38.fa O=${REF_DIR}/hg38.dict

# download known sites files for BQSR from GATK resource bundle
wget -P ${REF_DIR} https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf
wget -P ${REF_DIR} https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf.idx

# download panel of normals for mutect
wget -P ${REF_DIR} https://storage.googleapis.com/gatk-best-practices/somatic-hg38/1000g_pon.hg38.vcf.gz
gunzip ${REF_DIR}/1000g_pon.hg38.vcf.gz
