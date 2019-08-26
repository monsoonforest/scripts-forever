##A solution using find:

##To recursively rename files only:

find /your/target/path/ -type f -exec rename -v 's/special/regular/g' '{}' \;

##To recursively rename directories only:

find /your/target/path/ -type d -execdir rename -v 's/special/regular/g' '{}' \+

##To rename both files and directories recursively:

find /your/target/path/ -execdir rename -v 's/special/regular/g' '{}' \+

## g replaces all special in each filename. removing g will rename it only once 
## in the filename


## this will replace special character space with hyphen in the current directory
rename -- "s/\ /-/g" *

## this will replace the word andamans with the word location *not recursive*
rename -- "s/andamans/location/g" *

## change the case of letters
rename 'y/A-Z/a-z/' *
