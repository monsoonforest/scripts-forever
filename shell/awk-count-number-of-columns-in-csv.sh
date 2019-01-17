## COUNT NUMBER OF COLUMNS IN EVERY CSV FILE AND PRINT

awk -F',' 'FNR==1{print FILENAME ":" NF}' *.csv > number-columns-in-all-files.csv
