#!/bin/bash

usage="
*************************************
*** Chronolapse merge tool. v.1.0 ***
*************************************

Tool for merging chronolapse images captured from different sources. 
Require imagemagick to be installed on the system, and accesible from bash.

Arguments: [-h] [-i s] [-o s] [-c s] [-s s] [-b s] [-t s] [-g s] [-r n]

where:
	-h  show this help text

	mandatory:
	  -i  path to the directory containing images (will search it recursivelly)
	  -o  path to the directory for the output images
	optional:	
	  -c  sets the camera images prefix (default 'cam')
	  -s  sets the screnshoot images prefix (default 'screen')	
	  -b  background colour (default '#000000')
	  -t  tile layout (default '3x3')
	  -g  geometry size (default '660x')
	  -r  merge creation time treshold. in seconds (default '45') "	

pref_cam="cam"
pref_scr="screen"
bgcolor="#000000"
tiles="3x3"
geometry="660x"
timeTreshold=45	

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
while getopts 'hc:s:i:o:b:t:g:' opt; do
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

		b) bgcolor=$OPTARG
			;;

		t) tiles=$OPTARG
			;;

		g) geometry=$OPTARG
			;;

		r) timeTreshold=$OPTARG
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

declare -a arr_cam=()

#scan path for the images and add them to array
echo "
Starting scan $search_path"

# $1 - path
function searchForImages() {
	#arr=$3
	for f in $( ls $1 ); do		
		full_path="$1/$f"
		#if a directory search it
		if [ -d $full_path ]; then			
			searchForImages $full_path
		else #if file then add to correct array	
			#adding 0/1 to ensure that during the sort, camera will always be before screen		
			if [[ $f = $pref_cam* ]]; then				
				arr_cam+=($(stat -c '%Y0%n' "$full_path"))
				showProgress
			fi			
			if [[ $f = $pref_scr* ]]; then				
				arr_cam+=($(stat -c '%Y1%n' "$full_path"))
				showProgress
			fi			
		fi		
	done
}

searchForImages $search_path

#sort array by the creation time
arr_cam=( $(
	for e in "${arr_cam[@]}"; do
		echo "$e"
	done | sort -g)
	)

echo -ne "Done          

"

#merge images
echo "Merging images"
cam_pos=0
counter=0
out_counter=0
lastTimeStamp=-1
declare -a merged_cam=()	
showProgress

while [[ $cam_pos -lt ${#arr_cam[@]} ]]; do			

	timestamp="${arr_cam[$cam_pos]:0:10}"
	filepath="${arr_cam[$cam_pos]:11}"	
	counter=$(($counter+1))	

	cam_pos=$(($cam_pos+1))

	if [[ $lastTimeStamp -eq -1 ]]; then
		lastTimeStamp=${timestamp}
	else
		diff=$((timestamp - lastTimeStamp))		

		#last loop - push everything we have
		if [[ $cam_pos -eq ${#arr_cam[@]} ]]; then
			merged_cam+=(${filepath})	
			diff=${timeTreshold}
		fi

		if [[ $diff -ge $timeTreshold ]]; then
			lastTimeStamp=${timestamp}

			#performing montage
			mergeCommand="montage -geometry $geometry -tile $tiles -background '$bgcolor' "
			for c in "${merged_cam[@]}"; do
				mergeCommand+="$c "
			done	

			out_file_name="$pref_scr""_$out_counter"	
			out_counter=$(($out_counter+1))
			mergeCommand+="$out_path""/""$out_file_name.jpg"						

			showProgress
			eval $mergeCommand&>/dev/null			

			#clean up			
			declare -a merged_cam=()
		fi
	fi

	merged_cam+=(${filepath})	
	
done
echo -ne "Done           
"



