for file in $(find . -name '*.png'); 
do tesseract "$file" ${file%}; done