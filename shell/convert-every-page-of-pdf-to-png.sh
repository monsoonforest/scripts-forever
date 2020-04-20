## every image file will have the page number suffixed to the filename using a hyphen
## to remove the extension .pdf in the name of the file then add a .* after file% as shown below
for file in $(find . -name '*.pdf'); 
do pdftoppm "$file" ${file%.*} -png -r 300; done