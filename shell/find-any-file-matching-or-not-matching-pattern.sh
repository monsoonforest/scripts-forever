## 	FIND ANY FILE MATCHING OR NOT MATCHING A PATTERN

## \! is the NOT MATCHING parameter

## one can also pipe multiple matches using brackets

find . \! \( -name \*mod*.csv -o -name \*.xlsx \) -print

## ONE MAY ALSO USE SINGLE QUOTES BUT THE BACKSLAH SEEMS TYPER FRIENDLY

find . \! \( -name '*mod*.csv' -o -name '*.xlsx' \) -print
