## how to rename filenames with date

## Assuming the file extension for all files in the directory is.gif remove the file 
## extension using:

rename "s/.gif//g" *

## below code converts the date into current time zone
date -d '06Z28Aug17'

## run a loop over all files $f in the directory such that it uses date -d '06Z28Aug17'
## to convert to IST

for f in *; do mv -v -- "$f" "$(date -d "$f" '+%Y%m%d%H%M')"; done

## append file extension to all files back

for f in *; do mv "$f" "$f.gif"; done

##OR do it in one step by adding %%.gif to $f

for f in *; do mv -v -- "$f" "$(date -d "${f%%.gif}" '+%Y%m%d%H%M')".gif; done
