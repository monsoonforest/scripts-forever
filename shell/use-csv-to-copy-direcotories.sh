##script to copy a set of directories as specified in a .csv


## in xargs -a "Read items from file instead of standard input."
## cp -r copies directories recursively -t indicates the target directory


xargs -a /path/to/csv/jnk.csv cp -r -t /taregt/directory/