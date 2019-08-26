LANG=en_EN join -t, -1 1 -2 1 <(LANG=en_EN sort -k1 hosagadde-tree-names.csv) <(LANG=en_EN sort -k1 hosagadde-tree-height-2018.csv) > hosagadde-tree-height-name.csv 


csvjoin  -c date file1.csv file2.csv > final.csv
