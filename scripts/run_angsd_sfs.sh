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

#/home/jrick/bin/angsd/angsd -doAbbababa2 1 -bam bamlist.all -sizeFile popfile.all -doCounts 1 -out latesWGS_july2020_022621.angsd -anc /project/latesgenomics/reference_genomes/Lates_calcarifer/lcalcarifer_genome_v3_chromosomal.fa -useLast 1 -minQ 20 -minMapQ 30 -p 32 -blockSize 100000 -maxdepth 1000

for chr in `cat chrom`; do 
    echo $chr;
    /home/jrick/bin/angsd/angsd -bam $bam -doSaf 1 -out ${spp1}.$chr -anc /project/latesgenomics/reference_genomes/Lates_calcarifer/lcalcarifer_genome_v3_chromosomal.fa -GL 1 -minMapQ 1 -minQ 20 -p 16 -doMajorMinor 5 -skipTriallelic 1 -r $chr
done

#/project/evolgen/bin/realSFS ${spp1}.saf.idx -P 16 -nSites 100000000 > ${spp1}.unfolded.1dsfs.sfs

#/project/evolgen/bin/realSFS ${spp1}.saf.idx ${spp2}.saf.idx -P 16 -nSites 10000000 > ${spp1}.${spp2}.unfolded.2dsfs.sfs

date


