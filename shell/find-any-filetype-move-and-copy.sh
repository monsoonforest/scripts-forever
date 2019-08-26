## find file of type .xlsx and execute a mv command to the directory /jnk

find . -name '*.xlsx' -exec mv {} /jnk \;


## find files matching the name in quotes and stars and execute a copy command to another folder

find -type f -name "*SEEDLINGS*" -exec cp {} new-folder/ \;