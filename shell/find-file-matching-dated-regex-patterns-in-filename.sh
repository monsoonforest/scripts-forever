## FIND FILES MATCHING REGEX DATED PATTERN		## THIS PART HERE IS THE FILENAME PATTERN			## ${0##*/} CATCHES ONLY THE FILENAME WITH BASENAME
																												## ${fn:20:-4} catches that part of the filename string after 20 characters from the left and reducing 4 characters from the right, essentially to remove the file extension .csv	
find . -type f -regextype posix-egrep -regex ".*ALEXANDRIA_SEEDTRAP\_[0-9]{8}\.csv" -exec bash -c 'fn=${0##*/}; d=${fn:20:-4}; 
[[ $d -ge 20120718 && $d -le 20140418 ]] && echo "$0"' {} \;

## the stuff between -ge and -le is the dates between whcih one needs the files