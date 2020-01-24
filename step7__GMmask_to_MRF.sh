#!/bin/sh

#Shahrzad Moinian | 12 Mar 2018
#part of the image processing scripts for the paper "Human grey matter characterisation based on MR fingerprinting residual signals"

#This script creates a gray matter (GM) mask to be used for extracting GM tissue in the pipeline

if [ "$#" -ne 5 ]
then
	echo "Usage: $0"
	echo "1st arg: The GM_brain_mask.nii.gz (created using SPM12 segmentation on the original MP2RAGE T1-w images)"
	echo "2nd arg: One of the Z-corrected MRF images resulted from step 5"
	echo "3rd arg: The transformation matrix from MP2RAGE to MRF (see step 5)"
	echo "4th arg: The desired slice number, corresponding to the MRF slice position on the MP2RAGE image."
	echo "5th arg: output folder of the results"
	exit 1;
fi

GMbrainmask=$1
zcorrMRF=$2
mp2tomrfmat=$3
slcNum=$4
outfold=$5

#step1: threshold the GM_brain_mask (created using SPM12 segmentation on the original MP2RAGE T1-w images) and binarize:
fslmaths $GMbrainmask -thr 0.9 -bin ${outfold}/GM_brain_mask_bin.nii.gz

#step2:
flirt -in ${outfold}/GM_brain_mask_bin.nii.gz -ref $zcorrMRF -applyxfm -init $mp2tomrfmat -out ${outfold}/GM_brain_mask_bin__to__mrf.nii.gz

#step3: 
fslmaths ${outfold}/GM_brain_mask_bin__to__mrf.nii.gz -thr 0.9 -bin ${outfold}/GM_brain_mask_bin__to__mrf__bin

#step4:
fslroi ${outfold}/GM_brain_mask_bin__to__mrf__bin.nii.gz ${outfold}/GM_brain_mask_bin__to__mrf__bin_Slc${slcNum} 0 -1 0 -1 ${slcNum} 1




