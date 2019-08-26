## remove first column using cut

## or keep all columns except first using the --complement key

cut -f1 -d" " --complement input.file > output.file

while IFS= read -r file; do
            cut -f1 -d"," --complement "$file" > "${file%.*}-20column.csv"
done < <(find . -name '*trimmed*.csv')
