## ADD A NEW COLUMN NAMED "SITEID", BEFORE THE 1ST COLUMN, OR MORE PRECISELY ON THE RIGHT OF THE FIRST COLUMN

awk 'BEGIN{FS=OFS=","} {print (NR>1?"ALXA":"SITEID"), $0}' siteid-seedtrap.csv