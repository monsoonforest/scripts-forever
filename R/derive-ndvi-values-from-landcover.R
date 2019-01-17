## Derive NDVI values for different land use types

##Exmaple using odisha dataset

setwd("/home/csheth/documents/work/remote-sensing/chilika/odisha")

library(raster)
library(rgdal)

## create the DIVA landcover raster layer
landcover <- raster("odisha-DIVA-landcover-utm45.tiff")

## Read in Odisha's districts layer to use a particular district for the work
districts <- readOGR("odisha-districts-utm45.shp")

## Check the CRS of the above vectors, do the necessary conversion
districts <- spTransform(districts, crs(landcover))

## Select a particulr distrcit to work with
head(districts)

## this will select the district of choice. the comma is imperative as it indicates choosing rows and columns
ganjam <- districts[districts$NAME_2 == "Ganjam",]

## Create a landcover layer using the rectangular extents of ganjam
ganjamjnk <- crop(landcover, extent(ganjam))

## create a landcover layer precisely of the boundary of ganjam district
ganjamlc <- mask(ganjamjnk, ganjam)

plot(ganjamlc) ##check if it looks alrightq

## Simulate an NDVI raster with no of cells = 19680 and min and max, include nrow, ncol
xy <- matrix(runif(19680, -1, 1),160,123)
image(xy)

r <- raster(xy)

extent(r) <- extent(ganjam)

gjndvi <- mask(r, ganjam)