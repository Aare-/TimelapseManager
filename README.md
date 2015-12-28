# TimelapseMerger

Tool for merging chronolapse images captured from different sources / computers / persons. Usefull for creating timelapses of the game jams or other group computer activities into the one video. 
Images are merged based on the similarities of the last modified timestamp. The treshold can be adjusted using the optional parameters.

Output images can be converted into the video using the chronolapse tool.
Require imagemagick to be installed on the system, and accesible from bash.

# Arguments and usage
./TimelapseMerger.sh [-h] [-i s] [-o s] [-c s] [-s s] [-b s] [-t s] [-g s] [-r n]

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
  -r  merge creation time treshold. in seconds (default '45') 