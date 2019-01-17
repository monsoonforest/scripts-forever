## SORT AND SAVE FILENAMES OF A DIRECTORY TO A TEXT FILE

find ./  -printf "%f\n" | sort > filenames.txt 