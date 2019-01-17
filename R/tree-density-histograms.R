## PROGRAM TO PLOT TREE DENSTY HISTOGRAMS FROM VARIOUS RASTERS AND WITHIN SPECIFIC RAINFALL ZONES

setwd()

## create a variable with a all packages named
packages <- c("raster", "rgdal", "rgeos", "maptools","dplyr", "ncdf4", "ggplot2")

## call all packages using lapply
lapply(packages, library, character.only=TRUE)
## set something called pathz here
pathz <- "/media/user/HDD2-Data/csheth/gis-rs/data/treecover-2010"

## filez is a list of the files matching the pattern in the directory /treecover-2010
filez <- list.files(path = paste(pathz, "/zero-as-nodata", sep = ""), pattern = ".tif$")

## make a list of names of the raster using r and the lenght of the list
namez <- paste("r", c(1:length(filez)), sep = "")

## for loop to get the rasters onto the environment
for(i in 1:length(filez)){  
   temp <- raster(paste(pathz, "/zero-as-nodata/", filez[i], sep = ""))  
   assign(namez[i], temp)  
}  

## create a list of the rasters
jnk <- as.list(r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r17,r18,r19,r20)

## set a filenam
jnk$filename <- 'mosaic.tif'
jnk$overwrite <- TRUE

## create a mosaic, that will save to disk using merge() 
m <- do.call(merge,jnk)

