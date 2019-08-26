## create a column in the given csv file that writes out the date in the filename
## technically the filename is a string and is then split up using the IFS key and 
## only those strings at specific intervals will be used as a column content
## BASICALLY THIS CODE WILL CREATE A NEW COLUMN IN EVERY CSV BASED ON A STRING (THAT HAS BEEN SPLIT) IN THE FILENAME



ZERO IS A NUMBER AND THE FIRST ITEM IN THE ARRAY


while IFS= read -r file; 
do
IFS='_'        
string="($file)"
array=($string)
awk -v d="${array[3]}-${array[4]}-${array[5]}" -F"," 'BEGIN { OFS = "," } {$1=d; print}' "$file" > "${file%.*}_dated.csv"
done < <(find . -name '*trimmed*.csv')




## to add column name date amd use this one below

while IFS= read -r file; 
do
IFS='_'        
string="($file)"
array=($string)
awk -v d="${array[3]}-${array[4]}-${array[5]}" -F"," 'BEGIN { OFS = "," } {print $0, (NR>1?d:"date")}' "$file" > "${file%.*}_dated.csv"
done < <(find . -name '*trimmed*.csv')




## 	EXTRACTING PART OF A STRING TO A VARIABLE IN BASH FROM 
## https://stackoverflow.com/questions/15897276/extracting-part-of-a-string-to-a-variable-in-bash

testString="abcdefg:12345:67890:abcde:12345:abcde"
IFS=':'
array=( $testString )
echo "value = ${array[2]}"