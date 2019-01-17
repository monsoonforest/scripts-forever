#!/bin/bash
SRC_DIR=/media/chintan/Work/FROM_Windows/Work/ArunachalPradesh/EBP_FROG/ABP_Frog_Season_2014/General_collection_locations/
DST_DIR=/media/chintan/Work/FROM_Windows/Work/ArunachalPradesh/EBP_FROG/ABP_Frog_Season_2014/General_collection_locations/jnk
for FILE in *.gpx
do 
	echo gpsbabel -w -i gpx -f "${FILE}" -o unicsv -F "${DST_DIR}/$(basename \"${FILE}\" .gpx).csv"
done   
