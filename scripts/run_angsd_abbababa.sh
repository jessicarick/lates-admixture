#! /bin/sh

#SBATCH --account=latesgenomics
#SBATCH --time=2-00:00:00
#SBATCH --job-name=angsd
#SBATCH --ntasks-per-node=32
#SBATCH --mem=0

date

module load gcc
module load gsl
module load samtools

angsd -doAbbababa2 1 -bam bamlist.wgs -sizeFile popfile.wgs -doCounts 1 -out latesWGS_july2020_060221.angsd -anc reference_genomes/Lates_calcarifer/lcalcarifer_genome_v3_chromosomal.fa -useLast 1 -minQ 20 -minMapQ 30 -p 32 -blockSize 100000 -maxdepth 1000 

date
