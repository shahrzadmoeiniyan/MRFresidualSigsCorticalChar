#!/bin/sh

#Shahrzad Moinian | 6 June 2018
#part of the image processing scripts for the paper "Human grey matter characterisation based on MR fingerprinting residual signals"

#This script converts 1000 DICOM MRF images to NIFTI
#first arg: output folder name


if [ "$#" -ne 2 ]
then
	echo "Usage: $0"
	echo "1st arg: Output folder of NIFTIs."
	echo "2nd arg: Input folder of DICOMs"
	exit 1;
fi

outfold=$1
infold=$2
	
dcm2niix -v n -s y -z 3 -f %t_%d_s%s_a -o ${outfold} ${infold}

