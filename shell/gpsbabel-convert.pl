## script to convert a gpx file to a csv
## type gpsbabel -h or gpsbabel in a terminal for further details
## -w >> waypoint -i >> specify input filetype -f >> input file in quotes  -o >> output file format  -F >> output file
gpsbabel -w -i gpx -f "Waypoints_11-JUN-16.gpx" -o unicsv -F "Waypoints_11-JUN-16.csv"

gpsbabel -w -i gpx -f "Waypoints_12-JUN-16.gpx" -o unicsv -F "Waypoints_12-JUN-16.csv"


gpsbabel -w -i gpx -f "Waypoints_13-JUN-16.gpx" -o unicsv -F "Waypoints_13-JUN-16.csv"

gpsbabel -w -i gpx -f "Waypoints_14-JUN-16.gpx" -o unicsv -F "Waypoints_14-JUN-16.csv"


