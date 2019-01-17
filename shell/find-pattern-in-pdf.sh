## SCRIPT TO FIND ANY PATTERN INSIDE A PDF FILE

find -name '*.pdf' -exec sh -c 'pdftotext "{}" - | grep --with-filename --label="{}" --color "isotope"' \;
