## PRINT SPECIFIC LINE NUMBER IN FILE AND SAVE RESULT TO ANOTHER CSV

find -type f -name "*.csv" -exec awk 'FNR==7 {print FILENAME; print}' {} + > jnk.csv


## PRINT FIRST 6 LINES OF ALL CSV FILES 
awk 'FNR <= 6 {print}' *.csv > first-6lines.csv