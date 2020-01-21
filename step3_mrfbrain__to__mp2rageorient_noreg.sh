#!/bin/sh

#Shahrzad Moinian | 13 March 2018
#part of the image processing scripts for the paper "Human grey matter characterisation based on MR fingerprinting residual signals"


#This script sets the MRFrep dimensions, resolutions and orientations the same as those of mp2rage_T1w. This basically turns the 2D MRFs to 3D images so that the coregistration process (between MRF and MP2Rage images) can be proceeded more accurately:


#first arg:
#NOTE: mp2rage_zerod_FOV.nii.gz is an image of the same dimention, resolution and orientation as the mp2rageT1map image. This image is used as the -ref image in flirt, when a transformation matrix is going to be applied using -applyxfm. In such a case, flirt actually acts as a resampling operation and doesn’t take any intensity values of the -ref into account (only takes dimension, resolution and orientation).

#second arg:
#Note: the noReg.mat is an identity transform matrix and used just to set the dimensions, resolutions and orientations of mp2rage to mrf
#third arg: output folder of the results
#the rest of args: the images from step2

if [ "$#" -ne 1003 ]
then
	echo "Usage: $0"
	echo "1st arg: mp2rage_zerod_FOV.nii.gz"
	echo "2nd arg: noReg.mat"
	echo "3rd arg: output folder of the results"
	echo "the rest of args: the images from step2"
	exit 1;
fi


refImg=$1
regmat=$2
outfold=$3

idx=1

for i in "$@"
do
	if test ${idx} -gt 3
	then
		infile=$(basename "$i")		#with the file extension
		infile="${infile%.*.*}"		#without the file extension
		flirt -in $i -ref $refImg -applyxfm -init $regmat -out ${outfold}/${infile}__to__mp2rageorient_noreg

		echo "${outfold}/${infile}__to__mp2rageorient_noreg created!"
		
	fi
	let "idx=idx+1"
done
