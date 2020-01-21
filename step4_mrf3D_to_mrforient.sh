#!/bin/sh

#Shahrzad Moinian | 13 March 2018
#part of the image processing scripts for the paper "Human grey matter characterisation based on MR fingerprinting residual signals"

#This script sets the original orientation of MRF reps (as in step 2) to the 3D MRF images (created in step 3)
#first arg: a STRING containing qform params of one of MRF reps of step2 (may be obtained using: fslorient -getqform)
#second arg: a STRING containing sform params of one of MRF reps of step2 (may be obtained using: fslorient -getsform )
#third arg: output folder name
#the rest of the args: results of step3


if [ "$#" -ne 1003 ]
then
	echo "Usage: $0"
	echo "1st arg: a STRING containing qform params of one of MRF reps of step2, using fslorient -getqform"
	echo "2nd arg: a STRING containing sform params of one of MRF reps of step2, using fslorient -getsform"
	echo "3rd arg: output folder of the results"
	echo "the rest of args: the images from step3"
	exit 1;
fi


qformparams=$1
sformparams=$2
outfold=$3

idx=1

for i in "$@"
do
	if test ${idx} -gt 3
	then
		infile=$(basename "$i")		#with the file extension
		infile="${infile%.*.*}"		#without the file extension
		cp $i ${outfold}/${infile}__mrforient.nii.gz
		fslorient -setqform $qformparams ${outfold}/${infile}__mrforient.nii.gz
		fslorient -setsform $sformparams ${outfold}/${infile}__mrforient.nii.gz
		fslorient -setsformcode 1 ${outfold}/${infile}__mrforient.nii.gz
		fslorient -setqformcode 1 ${outfold}/${infile}__mrforient.nii.gz

		echo "${outfold}/${infile}__mrforient.nii.gz reoriented!"
		
	fi
	let "idx=idx+1"
done
