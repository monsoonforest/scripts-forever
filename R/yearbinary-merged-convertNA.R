## create a variable with a all packages named
packages <- c("raster","reshape2", "gridExtra", "rgdal", "rgeos", "maptools","dplyr", "ncdf4", "ggplot2", "tibble", "wesanderson")

## call all packages using lapply
lapply(packages, library,character.only=TRUE)

l <- list.files(pattern = ".*reclass.*\\.tif$")

## function to NA values less than 1
nait <- function(x,y,...){
	r <- raster(paste0(x))
	r[r == 0] <- NA
		## paste name of each layer and DONT FORGET TO MENTION WHICH LAYER IS BEING USED
	filepath <- paste(paste0(unlist(strsplit(x, split='\\.'))[1]), sep="")
	writeRaster(r, filename = filepath, format="GTiff", overwrite=TRUE)
}



lapply(l, nait)



## MORE MEMORY EFFICIENT WAY IS:

r <- raster(l)

rna <- reclassify(r, cbind(0, NA))


## THIS SCRIPT IS FOR YEAR BINARY SUM MERGED