#!/bin/bash

# if not executable or permission issues try:
# chmod u+x universalProcessing.sh

if [ ! -e "eyetracker/targetonsetsAll_mod.txt" ]
then 
  echo "Cannot find file with target onsets"
  exit 1
fi

if [ ! -f "TrialsIn2Txt.m" ]
then
  echo "TrialsIn2Txt.m not in this directory"
  exit 1
fi 

echo "Creating trials2beIncluded files"
matlab -nojvm -nodisplay -nosplash -nodesktop -r "TrialsIn2Txt;quit;" > matOut.out

cd eyetracker

if [ ! -e "edf2asc" ]
then 
  echo "Copy edf2asc binary into this directory"
  exit 1
fi

echo "Converting EDF files to ASC files, if it has not been done before"
for files in *.edf
do
	ascfile="${files%.edf}.asc"
	if [ ! -e $ascfile ]
	then
		./edf2asc $files
	fi 
done

echo "Check that there is a MAT file for each ASC file created"
# MAT file name: "../behaviour/responses_s01noise_subN_1_.mat" 
# ASC file name: "s01noise.asc"
#

for files in ../behaviour/*.mat
do
	matFile="${files#.*_}" # Strip out shortest match between '.' and '_' from front of $files.
	fileName="${matFile%%_*t}" # Deletes longest match of $substring from back of $string.
	ascFile=$fileName".asc" # add extension
	if [ ! -e ../eyetracker/$ascfile ]
	then
		echo "Mismatch between "$fileName" and "$ascFile 
		exit 1
	fi 
done

echo "getting newest binary version, if available"
if [ -e "/disk2/cPlusPlusDeveloping/extractEyeTrackingData/tmp/bin/binary" ]
then
	mv /disk2/cPlusPlusDeveloping/extractEyeTrackingData/tmp/bin/binary processingWithBaselines 
fi

echo "create file with list of subjects to analyze"
ls [sS]*.asc > subnames.txt

echo "Run binary file if present"
if [ -e "processingWithBaselines" ]
then 
	chmod u+x processingWithBaselines # make executable
	./processingWithBaselines 
else	
	if [ ! -e "binary" ]
	then 
		echo "Also the old binary file is not present, terminating"
		exit 1
	else
		echo "Running old binary file, fillers and non-fillers with marleen's region of interest definition." 
		echo "Is this the correct procedure?"
		chmod u+x binary 
		./binary 
	fi
fi

# # note the & at the end of the command is to have the R process in the background
echo "Computing and plotting proportions of fixations"
R CMD BATCH --no-save --no-restore proportionFixations.R proportionFixations.out &
# python script printing an error if R execution halted unexpectedly
python checkRexecution.py proportionFixations.out

echo "Computing and plotting pupil size baseline 1 and 2"
R CMD BATCH --no-save --no-restore pupilSizePlot_Baseline1_2.R pupilSizePlot_Baseline1_2.out &
python checkRexecution.py pupilSizePlot_Baseline1_2.out

echo "Computing and plotting pupil size baseline 3"
R CMD BATCH --no-save --no-restore pupilSizePlot_Baseline_3.R pupilSizePlot_Baseline_3.out &
python checkRexecution.py pupilSizePlot_Baseline_3.out
