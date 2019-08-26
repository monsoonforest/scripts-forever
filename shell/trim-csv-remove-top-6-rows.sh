## USING AWK TO TRIM TOP THREE LINES OF CSV

while IFS= read -r file; 
do
awk 'NR>6 {print}' "$file" > "${file%.*}_trimmed.csv"
done < <(find . -name '*.csv')


## KEEP FIRST 26 LINES OF CSV

while IFS= read -r file;
do
	head -n 26 "$file" > "${file%.*}_trimmed.csv"
done < <(find . -name '*.csv')