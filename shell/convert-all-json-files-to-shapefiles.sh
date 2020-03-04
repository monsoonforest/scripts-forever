for file in $(find . -name '*.json' ); 
do ogr2ogr -nlt POLYGON -skipfailures ${file%.json}.shp "$file"; done