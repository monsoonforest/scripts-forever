## REPLACE STRING IN  ALL FILES, OF A CERTAIN KIND, IN THE CURRENT DIRECTORY, BUT NOT RECURSIVELY 

sed -i -- 's/foo/bar/g' *.csv

## FIND AND REPLACE STRING IN ALL FILES, OF A CERTAIN KIND, IN ALL DIRECTORIES AND SUB-DIRECTORIES RECURSIVELY

find . -type f -name "*csv*" -exec sed -i 's/foo/bar/g' {} +


## TEST STRING REMOVAL USING ECHO ESPECIALY IF THERE ARE SPECIAL CHARACTERS IN THE STRING
echo '64/58' | sed 's/64\/58/58/g'



