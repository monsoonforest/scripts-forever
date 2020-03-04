## CODE TO EXTRACT DATA FROM MULTIPLE RASTERS INTO A POINT FILE

library(raster)
library(rgdal)
library(plyr)
library(dplyr)

## change file names to call accordingly
rainfall <- raster("BIO12.tif")

## CALL YOUR POINT FILE
sites <- read.csv("LOCATIONS.csv")

coordinates(sites) = ~longitude+latitude

proj4string(sites) = CRS("+init=epsg:4326")

## names(r) will paste the name of the raster in the dataset
data <- as.data.frame(extract(rainfall, sites))

write.csv(data,"LOCATIONS_WITH_RAINFALL.csv")
