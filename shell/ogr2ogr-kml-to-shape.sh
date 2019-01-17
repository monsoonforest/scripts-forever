## use ogr2ogr to convert into a shapefile

for FILE in $(find . -name '*.kml'); do ogr2ogr -f "ESRI Shapefile" "${FILE}.shp" "${FILE}"; done
																	## output.shp   input.kml

