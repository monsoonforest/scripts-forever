## MERGE TWO FILES VERTICALL, ASSUMING COLUMNS ARE THE IDENTICAL

awk 'NF' first.csv second.csv

## Merge all files vertically matching regex
awk 'NF' *dated*.csv > final.csv