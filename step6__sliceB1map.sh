#!/bin/sh

#Shahrzad Moinian | 18 May 2018
#part of the image processing scripts for the paper "Human grey matter characterisation based on MR fingerprinting residual signals"

#This script co_registers SA2RAGE_B1map with MRF and then extracts the desired slice number (based on the MRF image slice position).
#NOTE1: IT IS SUGGESTED IN THE LITERATURE TO USE THE SECOND IMAGES OF SA2RAGE AND MP2RAGE (i.e. the ones with higher intensities but smaller contrast) FOR REGISTRATION
#NOTE2: DO NOT use the brain extracted images of MP2RAGE, because we are not using brain extracted images of SA2RAGE

if [ "$#" -ne 5 ]
then
	echo "Usage: $0"
	echo "1st arg: second image of SA2RAGE (i.e. the one with higher intensities but smaller contrast)."
	echo "2nd arg: NON-BETed second image of MP2RAGE: mp2rage_INV2-ND.nii.gz"
	echo "3rd arg: B1map image of SA2rage."
	echo "4th arg: desired slice number (obtained in step 5)"
	echo "5th arg: output folder of results: usually the intermediate_products folder"
	exit 1;
fi

sa2rageImg=$1
mp2rageImg=$2
b1mapImg=$3
SlcPos=$4
outfold=$5


#find transformation from the original mp2rage_inv2 to the mp2rage_INV2_to_MRF.nii image. Then concatenate this matrix with the one from B1sa2rage to mp2rage
#NOTE: intermediate_products/mp2rage_INV2_to_MRF.nii.gz should be created (using the transformation matrix obtained in step 5) before running this script
flirt -in $mp2rageImg -ref ./intermediate_products/mp2rage_INV2_to_MRF.nii.gz -omat ${outfold}/mp2rageINV2_to_MRF.mat


flirt -in $sa2rageImg -ref $mp2rageImg -interp sinc -out ${outfold}/B1s6_to_mp2Inv2 -omat ${outfold}/B1s6_to_mp2Inv2.mat
convert_xfm -omat ${outfold}/B1s6_to_MRF.mat -concat ${outfold}/mp2rageINV2_to_MRF.mat ${outfold}/B1s6_to_mp2Inv2.mat

flirt -in $b1mapImg -ref ./intermediate_products/mp2rage_INV2_to_MRF.nii.gz -out ${outfold}/B1map_to_MRF -applyxfm -init ${outfold}/B1s6_to_MRF.mat

fslmaths ${outfold}/B1map_to_MRF.nii.gz -div 1000 ${outfold}/B1rationmap_to_MRF    #this line is specific to the SA2RAGE sequence output images

fslroi ${outfold}/B1rationmap_to_MRF.nii.gz ${outfold}/B1rationmap_to_MRF_Slc${SlcPos} 0 -1 0 -1 ${SlcPos} 1

