## find hyphen in column 3 of all csv files in directory and print filename and the 3rd column
awk -F',' '$3~/-/{print FILENAME":"$3}' *.csv


## find "findthis" in column 3 in all csv files and print filename and 3 column
awk -F'-' '$3~/findthis/{print FILENAME ":"$3}' *.csv