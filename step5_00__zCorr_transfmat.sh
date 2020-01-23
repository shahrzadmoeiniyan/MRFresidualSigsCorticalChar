#!/bin/sh

#Shahrzad Moinian | 16 May 2018
#part of the image processing scripts for the paper "Human grey matter characterisation based on MR fingerprinting residual signals"

#This script performs zcorrection and xcorrection on the mp2rage_to_mrforient.mat transformation matrix (step 4). Also performs zcorrection on the noReg.mat file.

if [ "$#" -ne 3 ]
then
    echo "Usage: $0"
    echo "1st arg: mp2rage_to_mrforient.mat (see step 4)"
    echo "2nd arg: noReg.mat (see step 3)"
    echo "3rd arg: output folder"
    exit 1;
fi


inputFile=$1
noRegFile=$2
outfold=$3


echo "processing $inputFile . . ."

#replace 'space' values with 'tab'
tr ' ' \\t < $inputFile > ${outfold}/temp_tabbed.mat

#extract the 'zTranslation' value from the input transformation matrix
zTransf=$(awk 'NR == 3 {print $4}' ${outfold}/temp_tabbed.mat)
#to negate the 'zTransf' value for later use
negvar=-1	
zTranslation=$(bc <<< "scale=0;$zTransf / $negvar")
echo $zTranslation > ${outfold}/zTranslationVariable.txt
echo "zTransf value: $zTranslation"

#replace the 'Ztranslation' value with '0'
awk 'FNR==3{$4=0};1' ${outfold}/temp_tabbed.mat > ${outfold}/temp_zcorrected.mat

#extract the 'XTranslation' value of the input transformation matrix
xTranslation=$(awk 'NR == 1 {print $4}' ${outfold}/temp_zcorrected.mat)
xcorr=$(bc <<< "$xTranslation - 45")
echo "old xTransf value: $xTranslation, new xTrans value: $xcorr"

#replace the xTranslation value of the input transformation matrix with the 'xcorr' value
awk 'FNR==1{$4='$xcorr'};1' ${outfold}/temp_zcorrected.mat > ${outfold}/temp_xzcorrected.mat

#replace the 'tab' with 'space' again, in the final output file
inFileName=$(basename "$inputFile")
inFileName="${inFileName%.mat}"
tr \\t ' ' < ${outfold}/temp_xzcorrected.mat > ${outfold}/zcorr_${inFileName}.mat

#remove the temp files
rm ${outfold}/temp_tabbed.mat
rm ${outfold}/temp_zcorrected.mat
rm ${outfold}/temp_xzcorrected.mat


#processing the noReg.mat file
echo "processing $noRegFile . . ."

#replace 'space' values with 'tab'
tr ' ' \\t < $noRegFile > ${outfold}/temp_tabbed.mat

#replace the zTranslation value of the noReg matrix with the 'zTranslation' value
awk 'FNR==3{$4='$zTranslation'};1' ${outfold}/temp_tabbed.mat > ${outfold}/temp_zcorrected.mat

#replace the 'tab' with 'space' again, in the final output file
noRegFileName=$(basename "$noRegFile")
noRegFileName="${noRegFileName%.mat}"
tr \\t ' ' < ${outfold}/temp_zcorrected.mat > ${outfold}/zcorr_${noRegFileName}.mat

#remove the temp files
rm ${outfold}/temp_tabbed.mat
rm ${outfold}/temp_zcorrected.mat
