#!/bin/sh

#Shahrzad Moinian | 26 Feb 2018
#part of the image processing scripts for the paper "Human grey matter characterisation based on MR fingerprinting residual signals"


#step 5-2:
flirt -in ./intermediate_products/zcorr_mp2rage_to_mrforient.nii.gz -ref zcorr_mrf.nii.gz -out ./intermediate_products/mp2rage_to_mrf_52 -schedule /usr/local/fsl/etc/flirtsch/sch2D_6dof -omat ./intermediate_products/mp2rage_to_mrf_52.mat

#create the z-corrected transformation matrix for co-registration of mp2rage with mrf images 
convert_xfm -omat ./intermediate_products/zcorr_mp2rage_to_mrforient_2D6dof_MI.mat -concat ./intermediate_products/mp2rage_to_mrf_52.mat ./intermediate_products/zcorr_mp2rage_to_mrforient.mat