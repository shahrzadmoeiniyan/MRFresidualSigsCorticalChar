#!/bin/sh

#Shahrzad Moinian | 12 Mar 2018
#part of the image processing scripts for the paper "Human grey matter characterisation based on MR fingerprinting residual signals"


#This script calculates a non-linear transformation from the MNI standard space to the MRF space (1st:MP2RAGE to MRF, 2nd:MP2rageToMRF space to the MNI standard space).The output (MNI_to_mp2rageINV2ToMRF_nonlinear_transf) can be then used to applywarp on all the atlas masks to transform them to the MRF space.

if [ "$#" -ne 8 ]
then
	echo "Usage: $0"
	echo "1st arg: BETed standard image, e.g. $FSLDIR/MNI152_T1_1mm_brain.nii.gz"
	echo "2nd arg: non-BETed standard image, e.g. $FSLDIR/MNI152_T1_1mm.nii.gz"
	echo "3rd arg: mp2rage_inv2_brain.nii.gz (BETed original MP2RAGE inversion 2)"
	echo "4th arg: mp2rage_inv2.nii.gz (non-BETed original MP2RAGE inversion 2)"
	echo "5th arg: the transformation matrix from mp2rage to MRf (see step 5: zcorr_mp2rage_to_mrforient_2D6dof_MI.mat)"
	echo "6th arg: zcorr_MRF.nii.gz (step 5)"
	echo "7th arg: FNIRT (non-linear transformation) 'config' file"
	echo "8th arg: output folder of the results"
	exit 1;
fi

betStdImg=$1
stdImg=$2
betMp2rageImg=$3
mp2rageImg=$4
mp2tomrfmat=$5
zcorrMRF=$6
fnirtCNF=$7
outfold=$8

idx=1

#find transformation matrix from atlas space (Juelich atlas —> MNI152_1mm) to mp2rage (1mm) space
#1st step: transform the original mp2rage_inv2 images to the MRF space using the zcorr_mp2rage_to_mrforient_2D6dof_MI.mat matrix. The reason we need mp2rage_inv2 images in addition to mp2rage_inv1 is that inv2 images are of the same contrast the the standard MNI image. Thus, it makes the registration process more reliable and reasonable:
flirt -in $mp2rageImg -ref $zcorrMRF -applyxfm -init $mp2tomrfmat -out ${outfold}/mp2rage_INV2_to_MRF
flirt -in $betMp2rageImg -ref $zcorrMRF -applyxfm -init $mp2tomrfmat -out ${outfold}/mp2rage_INV2_brain_to_MRF

#2nd step: calculate a starting point transformation matrix from the structural image (mp2rage_INV2_to_MRF) space to the standard image space, using FLIRT:
flirt -ref $betStdImg -in ${outfold}/mp2rage_INV2_brain_to_MRF -omat ${outfold}/mp2rageINV2ToMRF_to_MNI_affine_transf.mat

#3rd step: use FNIRT with the linear transformation matrix found in step 2 to create a non-linear transformation from the structural image (mp2rage_INV2_to_MRF) space to the standard image space:
fnirt --in=${outfold}/mp2rage_INV2_to_MRF.nii.gz --aff=${outfold}/mp2rageINV2ToMRF_to_MNI_affine_transf.mat --cout=${outfold}/mp2rageINV2ToMRF_to_MNI_nonlinear_transf --config=$fnirtCNF

#4th step: inverse the non-linear transformation from MP2RAGE space to the standard MNI space
invwarp --ref=${outfold}/mp2rage_INV2_to_MRF.nii.gz --warp=${outfold}/mp2rageINV2ToMRF_to_MNI_nonlinear_transf --out=${outfold}/MNI_to_mp2rageINV2ToMRF_nonlinear_transf


