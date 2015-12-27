#!/bin/bash

usage="
*************************************
*** Chronolapse merge tool. v.1.0 ***
*************************************

Program for merging chronolapse images captured from different sources. 
Require imagemagick to be installed on the system, and accesible from bash.

Arguments: [-h] [-c s] [-s s] PATH_TO_SCAN

where:
	-h  show this help text
	-c  sets the camera images prefix (default 'cam')
	-s  sets the screnshoot images prefix (default 'screen')
	PATH_TO_SCAN  path to the directory containing images (will search it recursivelly)"

pref_cam="cam"
pref_scr="screen"

#defining functions
SLEEP_PROGRESS=0
function showProgress() {		
	spinner="|"
	case $(($SLEEP_PROGRESS%4)) in
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
	SLEEP_PROGRESS=$(($SLEEP_PROGRESS+1))
	echo -ne "Working $spinner \r"
}

#parsing the parameters
while getopts 'hc:s:' opt; do
	case "$opt" in
		h) echo "$usage"
			exit	
			;;

		c) pref_cam=$OPTARG
			;;			

		s) pref_scr=$OPTARG	
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

search_path=${@:0:1}

#check if path has been set
if ! [[ $search_path ]] ; then
	echo "
Please provide path to be searched for photos." >&2
	echo "$usage" >&2
	exit 1	
fi

arr_cam=()
arr_scr=()
#scan path for the images and add them to array
echo "Screnshoot prefix: $pref_scr
Camera prefix: $pref_cam

Starting scan $search_path

"




#sort array by the creation time

#merge images


