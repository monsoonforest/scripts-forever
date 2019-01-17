##RECURSIVE COUNT OF UNIQUE FILE TYPES IN DIRECTORY

find . -type f | sed 's/.*\.//' | sort | uniq -c