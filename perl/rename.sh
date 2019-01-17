# script to rename all files in a folder

# the pattern to be renamed is kept between the first two backslashes after s, here the
# hyphen is replaced by an underscore in all files of the folder as indicated by a *
rename -- 's/-/_/g' *

# the code below will add a hyphen between every letter of the file including the 
# file extension and the start of the filename
rename "s//-/g" *

# an issue with a hyphen at the beginning of the filename is that perl will read it as
# an option command. The code below removes any hyphens that start at the beginning of
# the filename using \- The double hyphen -- is a GNU/Linux command that indicates the
# end of options (such as -v for verbose etc.), so that subsequent - hyphen prefixed
# words are not treated as options.
rename -- "s/\-//g" *


# replace the space in filenames with an underscore
rename -- "s/\ /_/g" *