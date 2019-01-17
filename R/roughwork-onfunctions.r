													### 	K-MEANS CLUSTERING IN R 	###

# creates a list of the raster files contained in the working directory
files <- c("RT_LC81340402013145LGN01_B1.TIF")

# this is a loop to list the filenames of the rasters in the working directory in a list called "load.file"
load.file <- function(filename) {
	d <- raster(filename, format="GTiff")
	d
}


# looping through the list called "files" to use the files as rasters contained in a list called "data"
data <- lapply(files, load.file)


# to determine the optimal no. of clusters in the data.frame without NA
raster <- as.data.frame(raster)
pamk(data=raster, usepam = FALSE)

# must omit NAs as it cannot handle it see "fpc" doc for more details and
# plot the data
plot(pam(uppdibdfnaomit, pamk.best$nc))