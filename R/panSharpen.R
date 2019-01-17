## THIS IS A FUNCTION TO PANSHARPEN (method = brovey) BANDS 5, 3, 2 IN A FOLDER USING BAND8 - PAN BAND

## load the libraries
library(raster)
library(RStoolbox)


# set the working directory to where the 532 band and the pan band is
setwd("/path/to/directory/containing/all/files")

# create a list of the 532 files
files <- c("Band_5.tif", "Band_3.tif", "Band_2.tif")

# create a function that will create a list of the filenames
load.file <- function(filename) {
			d <- raster(filename, format="GTiff")
			d
}

# data is a list that contains each of the rasters d from load.file. lapply repeats the loading process of the images contained in the list "files" 
data <- lapply(files, load.file)

# create a RasterStack of "data"
stack532 <- stack(data)

# load the pan-band-8 onto the workspace
band8 <- raster("Band_8.tif")

# this function will perform "brovey transform" and write the raster. Remember to change filename
pansharpfunc <- function(i, p) {

p <- panSharpen(i, p, r = 1, b = 2, g = 3, method = "brovey")

writeRaster(p, filename="brovey-532-LANDSATSCENENUMBER.tif", format = "GTiff")

}

# perform the pansharpening on the RasterStack using Band_8
pansharpfunc(stack532, band8)