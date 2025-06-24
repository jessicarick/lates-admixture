#!/bin/bash

#SBATCH --job-name lates_filter
#SBATCH --account=wagnerlab
#SBATCH --mail-type=all
#SBATCH --mail-user=jrick@uwyo.edu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=0
#SBATCH --time=0-6:00:00
#SBATCH --array=0-31

module load gcc
module load perl
module load  bowtie2/2.3.4.1-py27
module load zlib

date

## Script originally by Alex Buerkle (I think?). Modified by Liz Mandeville to work on Mt. Moran, March 2017. 

## Modified again by Liz, June 2017, to take command line arguments so input file names don't have to be hard-coded and "base" name is incorporated in output file names. 
## Note, the line where "$base" is defined can be altered to match file names for any project. 

## modified by Jessi, January 2018, for use with the LatesGBS data
## modified by Jessi, June 2022, for use with the Lates WGS data post-trimming using trimmomatic

##### Usage: ./filter.sh file.fastq

fastq_list=(/project/wagnerlab/data/lates_wgs_data/*trimmomatic_*P.fastq)
fq=${fastq_list[$SLURM_ARRAY_TASK_ID]}

temp_dir=/gscratch/jrick/fastq_filter

echo "This is your shell script reporting for duty! Time to filter!!"
echo "Filtering ${fq}"

base=`basename $fq .fastq`
echo $base

/project/wagnerlab/gbs_resources/scripts/tap_contam_analysis_JAR --db /project/wagnerlab/gbs_resources/contaminants/illumina_oligos --pct 20 $fq > ${temp_dir}/SB.${base}.readstofilter.ill.txt

echo "Illumina filtering done for $base"
echo "starting PhiX fitlering for $base"

/project/wagnerlab/gbs_resources/scripts/tap_contam_analysis_JAR --db /project/WagnerLab/gbs_resources/contaminants/phix174 --pct 80 $fq > ${temp_dir}/SB.${base}.readstofilter.phix.txt

echo "PhiX filtering done for $base"
echo "starting ecoli filtering for $base"

/project/wagnerlab/gbs_resources/scripts/tap_contam_analysis_JAR --db /project/wagnerlab/gbs_resources/contaminants/ecoli-k-12 --pct 80 fq > ${temp_dir}/SB.${base}.readstofilter.ecoli.txt

#echo "ecoli filtering done for $base"
echo "now creating clean copy of fastq"

cat $fq | /project/wagnerlab/gbs_resources/scripts/fqu_cull -r ${temp_dir}/SB.${base}.readstofilter.ill.txt ${temp_dir}/SB.${base}.readstofilter.phix.txt ${temp_dir}/SB.${base}.readstofilter.ecoli.txt > ${base}.clean.fastq

echo "Clean copy of fastq done"

echo "Filtering all done!" | mail -s "done filtering $base" jrick@uwyo.edu
