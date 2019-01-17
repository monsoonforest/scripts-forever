while IFS= read -r file; 
do
awk 'NR>6 {print}' "$file" > "${file%.*}_trimmed.csv"
done < <(find . -name '*.csv')