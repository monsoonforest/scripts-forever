##  SCRIPT TO CONVERT RADIOMETRICALLY CALIBRATED "ANALYTIC" RAPIDEYE IMAGES TO TOA REFLECTANCE


packages <- c("raster", "rgdal", "sp", "satellite","maptools", "XML", "RJSONIO")

lapply(X = packages, FUN = library, character.only=TRUE)


rapideye_image_list <- list.files(pattern=".*3A_Analytic.*\\.tif$$", recursive=TRUE)

TOAreflectance <- function(x,...) {
for (i in 1:length(x)) {

filenameofimage <- paste0(x[i])

## STACK THE RADIANCE IMAGES 
r <- brick(filenameofimage)

## RENAME THE BANDS
names(r) <- c("blue", "green", "red", "red_edge", "nir")

## SAVE THE IMAGE DATE AS A VECTOR
image_date <- paste0(unlist(strsplit(basename(x[i]), "_"))[2])

## CALCULATE EARTH SUN DISTANCE BY PASTING THE DATE OF THE IMAGE ACQUISITION
EarthSunDist <- calcEarthSunDist(date=image_date, formula="Spencer" )

## EAI = Exo-Atmospheric Irradiance FOR EACH BAND
EAIblue <- 1997.8
EAIgreen <- 1863.5
EAIred <- 1560.4
EAIred_edge <- 1395.0
EAInir <- 1124.4


json_filename <- paste0(unlist(strsplit(dirname(x[i]), "/"))[4])

## LUCKILY THE DIRECTORY OF THE IMAGE AND THE JSON NAME CAN BE MATCHED TO LIST THE JSON 
json_name <- paste0(dirname(x[i]),"/", paste0(json_filename), '_metadata.json')

## match the image number with the image number in the json file
metadata <- fromJSON(paste0(json_name), flatten=TRUE)

## COPY SOLAR ZENITH PROPERTY
SolarZenith <- (90 - metadata$properties$sun_elevation)

## CALCUALTE TOA FOR EACH BAND
blueTOA <-     (r[["blue"]] * pi * (EarthSunDist^2) / (EAIblue * cos(SolarZenith*pi/180)))

greenTOA <-    (r[["green"]] * pi * (EarthSunDist^2) / (EAIgreen * cos(SolarZenith*pi/180)))

redTOA <-      (r[["red"]] * pi * (EarthSunDist^2) / (EAIred * cos (SolarZenith*pi/180)))

red_edgeTOA <- (r[["red_edge"]] * pi * (EarthSunDist^2) / (EAIred_edge * cos(SolarZenith*pi/180)))

nirTOA <-      (r[["nir"]] * pi * ( EarthSunDist ^2) / ( EAInir * cos ( SolarZenith *pi/180)))


allbandsTOA <- stack(blueTOA, greenTOA, redTOA, red_edgeTOA, nirTOA)

new_file_name <- paste0(dirname(x[i]), "/", "TOA_reflectance_", basename(x[i]))

writeRaster(allbandsTOA, filename = new_file_name, format="GTiff", overwrite=TRUE)

  }
}

TOAreflectance(rapideye_image_list)




## to check the range of values in each band of each RapidEye image

toa_image_list <- list.files(pattern=".*TOA.*\\.tif$$", recursive=TRUE)


cellStats_function <- function(x,...){

	r <- brick(x)
	names(r) <- c("blue", "green", "red", "red_edge", "nir")
	mean <- cellStats(r, mean)
}
