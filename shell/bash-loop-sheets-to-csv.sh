## BATCH CONVERSION OF FILES INTO CSV BASED ON SHEETNAMES

## PART I: SAVING THE SHEETNAMES TO A FILE
## this loop will recursively (using the $(find...) expression) find in subdirectories both .xls
## and .xlsx files. Then performs an in2csv conversion of the sheetnames (in2csv -n). 
## the ${file%.xls} expression will prefix the name of $file

for file in $(find . -name '*.xls' -o -name '*.xlsx'); 
do in2csv --sheet "Eflux" "$file" > ${file%}-Eflux-data.csv; done


## HOW DO I USE THE -sheetnames.csv TO SAVE SPECIFIC SHEETS OF A SPREADSHEET FILE
while IFS= read -r file; do
    while IFS= read -r sheet; do
        in2csv --sheet "$sheet" "$file" > "${file%.*}-${sheet// /-}.csv"
    done < <(in2csv -n "$file")
done < <(find . -name '*.xls' -o -name '*.xlsx')

## ${sheet// /-} part will replace a space with hyphen in the sheetname.csv
## character to be replaced enclosed between first two // and one /
## one / precedes replacement character -

## above is one command to get sheetnames and write them separately