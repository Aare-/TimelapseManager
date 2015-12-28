#!/bin/bash

usage="
*************************************
*** Chronolapse merge tool. v.1.0 ***
*************************************

Program for merging chronolapse images captured from different sources. 
Require imagemagick to be installed on the system, and accesible from bash.

Arguments: [-h] [-c s] [-s s] [-i s] [-o s]

where:
	-h  show this help text
	-c  sets the camera images prefix (default 'cam')
	-s  sets the screnshoot images prefix (default 'screen')
	-i  path to the directory containing images (will search it recursivelly)
	-o  path to the directory for the output images"	

pref_cam="cam"
pref_scr="screen"

#defining functions
PROGRESS_STEP=0
function showProgress() {		
	spinner="|"
	case $(($PROGRESS_STEP%4)) in
		[0]*)
			spinner="\\"
			;;
		[1]*)
			spinner="|"
			;;
		[2]*)
			spinner="/"
			;;
		[3]*)
			spinner="-"
			;;		
	esac	
	PROGRESS_STEP=$(($PROGRESS_STEP+1))
	echo -ne "Working $spinner \r"
}

#parsing the parameters
while getopts 'hc:s:i:o:' opt; do
	case "$opt" in
		h) echo "$usage"
			exit	
			;;

		c) pref_cam=$OPTARG
			;;			

		s) pref_scr=$OPTARG	
			;;

		i) search_path=$OPTARG
			;;
		o) out_path=$OPTARG
			;;

		:) 
		   echo "$usage" >&2
			exit 1
			;;

		\?) 
			echo "$usage" >&2
			exit 1
			;;
	esac
done

shift $((OPTIND -1))

#check if path has been set
if ! [[ $search_path ]]; then
	echo "
Please provide path to be searched for photos." >&2
	echo "$usage" >&2
	exit 1	
fi
if ! [[ $out_path ]]; then
	echo "
Please provide output path for the results." >&2
	echo "$usage" >&2
	exit 1	
else
	if ! [ -d $out_path ]; then
		echo "
Output directory must exists" >&2
		echo "$usage" >&2
		exit 1	
	fi
	if [ "$(ls -A $out_path)" ]; then
		echo "
Output directory must be empty" >&2
		echo "$usage" >&2
		exit 1	
	fi
fi

echo "S: $search_path $out_path"

declare -a arr_cam=()
declare -a arr_scr=()

#scan path for the images and add them to array
echo "Screnshoot prefix: $pref_scr
Camera prefix: $pref_cam

Starting scan $search_path

"

# $1 - path
function searchForImages() {
	#arr=$3
	for f in $( ls $1 ); do		
		full_path="$1\\$f"
		#if a directory search it
		if [ -d $full_path ]; then			
			searchForImages $full_path
		else #if file then add to correct array			
			if [[ $f = $pref_cam* ]]; then
				arr_cam+=($full_path)
			fi
			if [[ $f = $pref_scr* ]]; then
				arr_scr+=($full_path)
			fi		
		fi		
	done
}

searchForImages $search_path

#echo ${arr_cam[@]}
#echo ${arr_scr[@]}

#sort array by the creation time

#merge images
echo "Merging images"
cam_pos=0
scr_pos=0
while [[ $cam_pos -lt ${#arr_cam[@]} ]]; do
	showProgress()
	
	declare -a merged_cam=()
	declare -a merged_scr=()

	merged_cam+=(${arr_cam[$cam_pos]})
	merged_scr+=(${arr_scr[$scr_pos]})	

	cam_pos=$(($cam_pos+1))
	scr_pos=$(($scr_pos+1))

	echo " - M: ${merged_cam[@]} 
	C: ${merged_scr[@]}"

	
done

