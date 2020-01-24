#!/bin/sh

#Shahrzad Moinian | 27 Feb 2018
#part of the image processing scripts for the paper "Human grey matter characterisation based on MR fingerprinting residual signals"


#This script transforms Juelich brain atlas masks from MNI152 space to the MRF space.


if [ "$#" -lt 6 ]
then
	echo "Usage: $0"
	echo "1st arg: the nonlinear transformation (which contains spline coefficients + affine transformation) from MNI standard space to the MP2RAGEINV2ToMRF native space (see step 8: MNI_to_mp2rageINV2ToMRF_nonlinear_transf.nii.gz)"
	echo "2nd arg: (non-BETed) mp2rage_inv2_To_MRF.nii.gz, calculated using zcorr_mp2rage_to_mrforient_2D6dof_MI.mat on mp2rage_INV2.nii.gz:"
	echo "flirt -in ./needed_for_processingSteps/mp2rage_INV2-ND.nii.gz -ref ./step6_zcorrected3Dmrforients/zcorr_mrf.nii.gz -applyxfm -init ./intermediate_products/zcorr_mp2rage_to_mrforient_2D6dof_MI.mat -out ./intermediate_products/mp2rage_INV2_to_MRF"
	echo " "
	echo "3rd arg: output folder of the results"
	echo "4th arg: slice number (the slice that matches the MRF slice)"
	echo "5th arg: the sliced binary and thresholded GM mask that should be created by performing segmentation on the MP2RAGE image"
	echo "the rest of arguments are to be the atlas masks"
	exit 1;
fi

mniToMRFTransf=$1
mp2ToMRFImg=$2
outfold=$3
SlcPos=$4
binGMmaskSlc=$5

idx=1

#step1: find transformation matrix from atlas space (Juelich atlas —> MNI152_1mm) to mp2rageToMRF (1mm) space. See step 8.


#step2: use the transformation found in step1 to transform atlas masks to the MRF slice space:
for i in "$@"
do
	if [ $idx -gt 5 ]	
	then
		echo "processing ${i} . . ."
		inputmask=$(basename "$i")	#with the file extension
		inmask=${inputmask%.*.*}	

		applywarp --ref=$mp2ToMRFImg --in=$i --warp=$mniToMRFTransf --out=${outfold}/${inmask}_to_MRFspace --interp=nn

		#the transformed masks need to be thresholded and binarized again (even after extracting e.g. only those voxels with probability of above 60% from the original masks in the MNI space). That’s because in the transformation process some estimations are involved. Thus, need the threshold of above 90% to extract only those voxels, which with 90% probability, are in the new space.
		fslmaths ${outfold}/${inmask}_to_MRFspace -thr 0.9 -bin ${outfold}/${inmask}_to_MRFspace_bin

		#should then be sliced at the specified slice number
		fslroi ${outfold}/${inmask}_to_MRFspace_bin ${outfold}/${inmask}_to_MRFspace_bin_Slc 0 -1 0 -1 $SlcPos 1		
		#should then be multiplied by the correct GM_mask_bin, to only include the GM voxels in the process
		fslmaths ${outfold}/${inmask}_to_MRFspace_bin_Slc -mul $binGMmaskSlc ${outfold}/${inmask}_to_MRFspace_bin_Slc_GMmasked

	fi
	let "idx=idx+1"
done
