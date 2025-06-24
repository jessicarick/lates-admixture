#!/bin/sh

BASEDIR=/project/WagnerLab/jrick/msmc_Sept2017

### Variables:
#Had to put loop in script because it wouldn't carry the values over
#for i in `cat INDS`; \
#do echo $i;\
#IND=`echo ${i[@]}`; \
#for s in `cat SCAFFOLDS`; \
#do echo $s;\
#SCAFS=`echo ${s[@]}`; \
#done; done

IND=CEW16_022
SCAFS=LG1

P_PAR=1*2+25*1+1*2+1*3
NR_IND=1
POP_OR_IND=$IND
RUN_NAME=091817_test

module load msmc2

### Report settings/parameters:
date
echo "Script: msmc_3_runMSMC_onepop.sh"
echo "Run name: $RUN_NAME"
#echo "SNP calling method: $METHOD"
echo "Period setting: $P_PAR"
echo "Nr of individuals (1 or 2+): $NR_IND"
echo "Population or individuals ID: $POP_OR_IND"
echo "Individual: $IND"
echo "Scaffolds: $SCAFS"


if [ $NR_IND == 1 ]
	then
	echo "Running MSMC for one individual"
	MSMC_INPUT=${BASEDIR}/input/msmc_input.${POP_OR_IND}.${SCAFS}.txt
	MSMC_OUTPUT=${BASEDIR}/output/msmc_output.${POP_OR_IND}.${RUN_NAME}

	if [ -f $MSMC_INPUT ]
		then
			echo "MSMC_INPUT: $MSMC_INPUT"
			echo "MSMC_OUTPUT: $MSMC_OUTPUT"
		else
			echo "MSMC_INPUT does not exist! Exiting now"
			exit 1
	fi

	msmc2 -t 16 -p $P_PAR -o $MSMC_OUTPUT -I 0,1 $MSMC_INPUT
	#mv $MSMC_OUTPUT*loop.txt $BASEDIR/output/$METHOD/log_and_loop/
	#mv $MSMC_OUTPUT*log $BASEDIR/output/$METHOD/log_and_loop/
else
	echo "ERROR: NR_IND should be 1 (for one individual) or 2 (for 2+ individuals)"
fi

echo "DONE_WITH_SCRIPT"
date
