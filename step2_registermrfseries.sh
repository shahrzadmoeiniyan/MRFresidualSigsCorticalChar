#!/bin/sh

#Shahrzad Moinian | 13 March 2018
#part of the image processing scripts for the paper "Human grey matter characterisation based on MR fingerprinting residual signals"


#This script co-registers MRF images of the three series of MRF acquisitions per slice, then calculates the average per MRF frame
#1st arg: the MRF image of an input series 1, after BET
#2nd arg: the MRF image of an input series 2, after BET
#3rd arg: the MRF image of the ref series (e.g. series 3), after BET
#4th arg: output folder of the results
#the 5th and 6th args: the folder of input MRF images of series 1 and series 2
#7th arg: folder of the MRF series that has been chosen as the reference

if [ "$#" -ne 7 ] 
then
	echo "Usage: $0"
	echo "1st arg: the MRF image of an input series 1, after BET"
	echo "2nd arg: the MRF image of an input series 2, after BET"
	echo "3rd arg: the MRF image of the ref series, after BET"
	echo "4th arg: output folder of the results"
	echo "the 5th and 6th args: the folder of input MRF images of series 1 and series 2"
	echo "7th arg: folder of the MRF series that has been chosen as the reference"
	exit 1;
fi

mrfin1=$1
mrfin2=$2
mrfref=$3
outfold=$4
infold1=$5
infold2=$6
mrfreffold=$7

inputarray1=${infold1}/*.nii.gz
inputarray2=${infold2}/*.nii.gz
refarray=${mrfreffold}/*.nii.gz

outfold1="${outfold}/inputs1_to_ref"
outfold2="${outfold}/inputs2_to_ref"
#reffold="${outfold}/refseries_to_ref"
reffold=${mrfreffold}
avgfold="${outfold}/seriesavg"

mkdir ${outfold1}
mkdir ${outfold2}
mkdir "${outfold1}/reged_inputs1"
mkdir "${outfold2}/reged_inputs2"
#mkdir ${reffold}
mkdir ${avgfold}


#finding transformation matrix from the first series to the ref series
mrfin1name=$(basename "$mrfin1")
mrfin1name="${mrfin1name%.*.*}"		#skip '.nii.gz'... if '.nii' only, %.*
mrftmat1="${outfold}/${mrfin1name}-tmat.mat"
flirt -in ${mrfin1} -ref ${mrfref} -omat ${mrftmat1} -2D -schedule $FSLDIR/etc/flirtsch/sch2D_6dof

#finding transformation matrix from the second series to the ref series
mrfin2name=$(basename "$mrfin2")
mrfin2name="${mrfin2name%.*.*}"		#skip '.nii.gz'... if '.nii' only, %.*
mrftmat2="${outfold}/${mrfin2name}-tmat.mat"
flirt -in ${mrfin2} -ref ${mrfref} -omat ${mrftmat2} -2D -schedule $FSLDIR/etc/flirtsch/sch2D_6dof


#finding transformation matrix from all mrf images of input series 1 to the reference mrf image within the same series, and then concatenating it with the transformation matrix found (above) from the input series 1 to the ref series, to perform co-registration of all mrf images of input series 1 to the ref series.
for i in ${inputarray1[@]}
do
	infile=$(basename "$i")		#with the file extension
	infile="${infile%.*.*}"		#without the file extension

	if [ "$mrfin1name" != "$infile" ] 
	then
		#for registration between the images of the same series, I don’t use 6DOF schedule, because it is usually not even useful to do 6DOF when registering intra-subject. Thus, 6DOF seems even more unnecessary when dealing with the images of the same series.
		#flirt -in ${i} -ref ${mrfin1} -out "${outfold1}/reged_inputs1/${infile}-toser" -2D
		flirt -in ${i} -ref ${mrfref} -out "${outfold1}/${infile}-reg" -applyxfm -init ${mrftmat1}
		echo "${infile} registered!"
	else
		#if the current input (i.e. infile) is the same as the reference image of the current series (i.e. mrfin1), then I just need to apply the transformation matrix found before (i.e. mrfmat1).
		flirt -in ${i} -ref ${mrfref} -out "${outfold1}/${infile}-reg" -applyxfm -init ${mrftmat1}
		echo "${infile} registered!"
	fi
done

#same as above, for input series 2 . . .
for i in ${inputarray2[@]}
do
	infile=$(basename "$i")		#with the file extension
	infile="${infile%.*.*}"		#without the file extension

	if [ "$mrfin2name" != "$infile" ] 
	then
		#flirt -in ${i} -ref ${mrfin2} -out "${outfold2}/reged_inputs2/${infile}-toser" -2D
		flirt -in ${i} -ref ${mrfref} -out "${outfold2}/${infile}-reg" -applyxfm -init ${mrftmat2}
		echo "${infile} registered!"	
	else
		#if the current input (i.e. infile) is the same as the reference image of the current series (i.e. mrfin2), then I just need to apply the transformation matrix found before (i.e. mrfmat2).
		flirt -in ${i} -ref ${mrfref} -out "${outfold2}/${infile}-reg" -applyxfm -init ${mrftmat2}
		echo "${infile} registered!"
	fi
done


#registering the MRF images in the mrfref series to the ref mrf image. After this step, basically all images of all series are registered to the reference mrf image of the reference series.
#mrfrefname=$(basename "$mrfref")
#mrfrefname="${mrfrefname%.*.*}"		#skip '.nii.gz'... if '.nii' only, %.*
#for i in ${refarray[@]}
#do
	
#	infile=$(basename "$i")		#with the file extension
#	infile="${infile%.*.*}"		#without the file extension
		

#	if [ "$mrfrefname" != "$infile" ] 
#	then
		 
#		flirt -in ${i} -ref ${mrfref} -out "${reffold}/${infile}-reg" -2D 
#	else
#		cp ${mrfref} "${reffold}/${mrfrefname}-reg.nii.gz"	#dont register the image to itself!
#	fi
#done



#NOTE: Calculating the average image of the series, ASSUMING THAT MRF REPETITIONS EQUAL TO 1000
avgbasename="${mrfin1name%s??_a_c*}"

for ((idx=1;idx<=1000;idx++))
do
	if [ $idx -lt 10 ]
	then
		repID="000${idx}"
	else
		if [ $idx -lt 100 ]
		then
			repID="00${idx}"
		else
			if [ $idx -lt 1000 ]
			then
				repID="0${idx}"
			else 
				repID=${idx}
			fi
		fi
		
	fi
	echo Averaging the ${repID} repetition . . .
	fslmaths ${outfold1}/*_s??_a_c??_${repID}_brain-reg.nii.gz -add ${outfold2}/*_s??_a_c??_${repID}_brain-reg.nii.gz -add ${reffold}/*_s??_a_c??_${repID}_brain.nii.gz -div 3 ${avgfold}/${avgbasename}_seriesavg_a${repID}
done


