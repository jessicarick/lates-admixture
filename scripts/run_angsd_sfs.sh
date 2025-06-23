#! /bin/sh

#SBATCH --account=latesgenomics
#SBATCH --time=2-00:00:00
#SBATCH --job-name=angsd
#SBATCH --ntasks-per-node=16
#SBATCH --mem=0

date

module load gcc
module load gsl
module load samtools

spp1=$1
bam=$2

for chr in `cat chrom`; do 
  echo $chr
  /home/jrick/bin/angsd/angsd -bam $bam -doSaf 1 -out ${spp1}.$chr -anc /project/latesgenomics/reference_genomes/Lates_calcarifer/lcalcarifer_genome_v3_chromosomal.fa -GL 1 -minMapQ 1 -minQ 20 -p 16 -doMajorMinor 5 -skipTriallelic 1 -r $chr
done

date
