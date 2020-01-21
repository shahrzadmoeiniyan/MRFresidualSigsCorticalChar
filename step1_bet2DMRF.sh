#!/bin/sh

#Shahrzad Moinian | 6 June 2018
#part of the image processing scripts for the paper "Human grey matter characterisation based on MR fingerprinting residual signals"

#This script applies FSL BET on MRF reps
#first, MRF brain mask should be created using BET on one of MRF rep images with -f 0.45

#first arg: one of the MRF rep images to create BET mask out of it
#second arg: output folder for the BET mask
#third arg: output folder of the results
#the rest of the args: raw Nifti files


if [ "$#" -ne 1003 ] 
then
	echo "Usage: $0"
	echo "1st arg: one of the MRF rep images to create BET mask out of it"
	echo "2nd arg: output folder for the BET mask"
	echo "3rd arg: output folder of the results"
	echo "the rest of the args: raw NIFTI MRF images."
	exit 1;
fi

mrfref=$1
maskOutfold=$2
outfold=$3

bet $mrfref ${maskOutfold}/MRF_BET_brain -f 0.45 -g 0 -m


idx=1

for i in "$@"
do
	if test ${idx} -gt 3
	then
		infile=$(basename "$i")		#with the file extension
		infile="${infile%.*}"		#without the .file extension
		fslmaths $i -mul ${maskOutfold}/MRF_BET_brain_mask.nii.gz ${outfold}/${infile}_brain

		echo "${infile}_brain brain extracted!"
		
	fi
	let "idx=idx+1"
done
