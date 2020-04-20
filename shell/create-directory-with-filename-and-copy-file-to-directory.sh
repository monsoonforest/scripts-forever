# find all pdf files recursively. create a temporary variable "dir" and mk dir with "dir" and mv to that "dir"
# create a direcrtory with that filename and move that file into that directory 

for file in $(find . -name '*.pdf'); 
do
    dir="${file%.pdf}"
    mkdir -- "$dir"
    mv -- "$file" "$dir"
done