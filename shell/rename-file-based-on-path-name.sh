#! /bin/bash

## code to rename files in a directory using a phrase from the parent directory of the file

target_dir_path="/home/user/documents/lemon-india/database-creation/seed-trap-cleanup/andamans/jnk"

for file in */*/*/*.JPG; do
        ##IFS='_'
        ##array="($file%%/*)"
        l1="${file%//*}"
        l2="${file%%//*}"
        ##l2="${file##*/}"
        l2="${l2%%/*}"
        ##l2="{$l1}" 
        filename="${file##*/}"
        target_file_name="${l1}_${l2}_${filename}"
##      target_file_name="${array[1]}_${array[2]}_${array[4]}_${array[5]}_${array[5]}_${filename}"
        echo cp "$file" "${target_dir_path}/${target_file_name}"
done