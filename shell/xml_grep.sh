## This script will parse the 'coordinates' field from the file ap-roads.kml (which is an .xml file). grep searches for the pattern in the file. 
## tee will save the output to the text file.

xml_grep 'coordinates' ap-roads.kml --text_only | tee ap-roads-coordinates.txt

## using tr -d meaning delete, tr will delete whats in the  quotes "" and the sequences in the quotes. \t = horizontal tab, \n = new line and \r = return
## tr --help for more information
cat ap-roads-coordinates.txt | tr -d " \t\n\r" | tee ap-roads.txt