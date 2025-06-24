#!/bin/sh

#SBATCH --account=latesgenomics
#SBATCH --time=1-00:00:00
#SBATCH --ntasks-per-node=4
#SBATCH --job-name=trimmomatic

module load gcc trimmomatic

ind=$1

date
echo "running trimmomatic on paired files $(ls ${ind}_s*.fastq.gz)"

trimmomatic PE -threads 4 -phred33 -trimlog ${ind}.trimlog -validatePairs ${ind}_s*.fastq.gz -baseout ${ind}.trimmomatic ILLUMINACLIP:TruSeq3-PE-2.fa:2:30:10:1:true

echo "done with trimmomatic for $ind"
date
