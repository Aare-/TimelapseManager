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

if ! [[ $search_path ]] ; then
	echo "
Please provide path to be searched for photos." >&2
	echo "$usage" >&2
	exit 1	
fi