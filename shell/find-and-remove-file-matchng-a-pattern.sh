## FIND AND REMOVE FILES MATCHING PATTERN

## -type f means type file -type d will be fore directories

find . -type f -name '*plot_data_format*.csv' -exec rm {} +
