#!/bin/sh

#SBATCH --account=latesgenomics
#SBATCH --time=3-00:10:00
#SBATCH --ntasks-per-node=16
#SBATCH --mail-type=END
#SBATCH --array=1-23
#SBATCH --mem=120G

date

module load gcc ldhelmet samtools bcftools

readarray -t chrom_list < data/chrom
chrom=${chrom_list[$SLURM_ARRAY_TASK_ID]}
iter=$1

vcf_dir=/project/latesgenomics/jrick/admixture/july2020/msmc/msmc/vcf

mkdir /lscratch/$SLURM_JOB_ID
cp ind_list.txt /lscratch/${SLURM_JOB_ID}/ind_list.txt
cp chrom /lscratch/${SLURM_JOB_ID}/chrom
cp ${chrom}.all.fa /lscratch/$SLURM_JOB_ID/
#cp ${chrom}.run1.conf /lscratch/$SLURM_JOB_ID/${chrom}.run${iter}.conf
#cp ${chrom}.run1.lik /lscratch/$SLURM_JOB_ID/${chrom}.run${iter}.lik
#cp ${chrom}.run1.pade /lscratch/$SLURM_JOB_ID/${chrom}.run${iter}.pade

cd /lscratch/$SLURM_JOB_ID/

if [ "$iter" == "1" ]; then
#bgzip $vcf && 
#tabix -p ${vcf}.gz

for ind in `cat ind_list.txt`
	do echo "creating fasta for $ind"
	vcf="${vcf_dir}/latesWGS_2.bamlist.${ind}.${chrom}.minDP5.whatshap.samtools.vcf.gz"
	base=$(basename ${vcf} .vcf.gz)
	echo "basename is $base"
	#bgzip -c $vcf > ${base}.vcf.gz
	cp ${vcf}* .
	#tabix ${base}.vcf.gz

	samtools faidx reference_genomes/Lates_calcarifer/lcalcarifer_genome_v3_chromosomal.fa $chrom | bcftools consensus ${base}.vcf.gz -s $ind -H 1 -M "-" | sed "s/^>/>${ind}_hapA_/g" >> ${chrom}.all.fa
	samtools faidx reference_genomes/Lates_calcarifer/lcalcarifer_genome_v3_chromosomal.fa $chrom | bcftools consensus ${base}.vcf.gz -s $ind -H 2 -M "-" | sed "s/^>/>${ind}_hapB_/g" >> ${chrom}.all.fa

done

echo "beginning creation of haplotype config file for $chrom, using vcf $vcf"
ldhelmet find_confs --num_threads 16 -w 100 -o ${chrom}.run${iter}.conf ${chrom}.all.fa

echo "done with haplotype configuration; starting table generation"
ldhelmet table_gen --num_threads 16 -c ${chrom}.run${iter}.conf -t 0.01 -r 0.0 0.1 10.0 1.0 100.0 -o ${chrom}.run${iter}.lik

echo "done with table generation, starting calculation of pade coefficients"
ldhelmet pade --num_threads 16 -c ${chrom}.run${iter}.conf -t 0.01 -x 11 -o ${chrom}.run${iter}.pade

else

cp /project/latesgenomics/jrick/admixture/july2020/ldhelmet/ldhelmet_apr23/${chrom}.run1.conf /lscratch/$SLURM_JOB_ID/${chrom}.run${iter}.conf
cp /project/latesgenomics/jrick/admixture/july2020/ldhelmet/ldhelmet_apr23/${chrom}.run1.lik /lscratch/$SLURM_JOB_ID/${chrom}.run${iter}.lik
cp /project/latesgenomics/jrick/admixture/july2020/ldhelmet/ldhelmet_apr23/${chrom}.run1.pade /lscratch/$SLURM_JOB_ID/${chrom}.run${iter}.pade

fi

blocks=(50 50 30 20)

echo "done calculating pade coefficients; starting rjmcmc procedure"
ldhelmet rjmcmc --num_threads 16 -w 100 -l ${chrom}.run${iter}.lik -p ${chrom}.run${iter}.pade -b ${blocks[$iter]} -s ${chrom}.all.fa --burn_in 100000 -n 1000000 -o ${chrom}.run${iter}.post

echo "done with rjcmcm procedure! results were written to ${chrom}.run${iter}.post. now, transferring output back to project account"
cp ${chrom}* ldhelmet/ldhelmet_apr23/
cd ../
tar -zcvf ${SLURM_JOB_ID}_${chrom}_results.tar.gz $SLURM_JOB_ID
mv ${SLURM_JOB_ID}_${chrom}_results.tar.gz ldhelmet/ldhelmet_apr23/
rm -rf ${SLURM_JOB_ID}/
