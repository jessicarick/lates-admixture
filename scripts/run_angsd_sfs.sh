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
#spp2=$2
bam=$2

# create per-chromosome saf and then sfs
for chr in `cat chrom`; do 
    echo $chr;
    angsd -bam $bam -doSaf 1 -out ${spp1}.$chr -anc reference_genomes/Lates_calcarifer/lcalcarifer_genome_v3_chromosomal.fa -GL 1 -minMapQ 1 -minQ 20 -p 16 -doMajorMinor 5 -skipTriallelic 1 -r $chr
    realSFS ${spp1}.${chr}.saf.idx -P 16 > ${spp1}.${chr}.unfolded.1dsfs.sfs
done

#realSFS ${spp1}.saf.idx ${spp2}.saf.idx -P 16 -nSites 10000000 > ${spp1}.${spp2}.unfolded.2dsfs.sfs

date


