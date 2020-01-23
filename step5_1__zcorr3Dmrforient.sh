#!/bin/sh

#Shahrzad Moinian | 13 March 2018
#part of the image processing scripts for the paper "Human grey matter characterisation based on MR fingerprinting residual signals"


#This script corrects the z translation of 3D mrf-mrforiented images of step4
#Prerequisite: You first need to do:
#flirt -in ./needed_for_processingSteps/<brain-extracted inversion 1 image of mp2rage>.nii.gz -ref ./step4_mrforiented/<one of the mrf repetition images>.nii.gz -out ./intermediate_products/mp2rage_to_mrforient -omat ./intermediate_products/mp2rage_to_mrforient.mat -cost mutualinfo -2D
#you will then need to zcorr the mp2rage_to_mrforient.mat and apply it:
#flirt -in ./needed_for_processingSteps/<brain-extracted inversion 1 image of mp2rage>.nii.gz -ref ./step4_mrforiented/<one of the mrf repetition images>.nii.gz -out ./intermediate_products/zcorr_mp2rage_to_mrforient -applyxfm -init ./intermediate_products/zcorr_mp2rage_to_mrforient.mat

#first arg: zcorr_mp2rage_to_mrforient.nii.gz
#second arg: zcorr_noReg.mat
#third arg: output folder of the results
#the rest of args: results of step4

if [ "$#" -ne 1003 ]
then
	echo "Usage: $0"
	echo "1st arg: zcorr_mp2rage_to_mrforient.nii.gz"
	echo "2nd arg: zcorr_noReg.mat (see step5_00)"
	echo "3rd arg: output folder of the results"
	echo "the rest of args: results of step4"
	exit 1;
fi

refImg=$1
transmat=$2
outfold=$3

idx=1

for i in "$@"
do
	if test ${idx} -gt 3
	then
		infile=$(basename "$i")		#with the file extension
		infile="${infile%.*.*}"		#without the file extension
		flirt -in $i -ref $refImg -init $transmat -applyxfm -out ${outfold}/zcorr_${infile}

		echo "${outfold}/zcorr_${infile} zcorrected!"
		
	fi
	let "idx=idx+1"
done
