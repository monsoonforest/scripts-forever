## FUNCTION TO CREATE A RASTER OD SPECIFIC RANDOMS VALUES, DIMENSIONS AND EXTENTS. MYPATH <- () IS A WAY TO NAME THE RASTER AND writeRaster WILL SAVE THE RASTER 


library(raster)

# set the working directory to where all the input rasters are
setwd("/home/chintan/documents/work/remote_sensing/analysis/dibang-landcover/band1-clustering/Band_1/")

# create a list of the input files on which the analyses is to be run
files <- c("RT_LC81340402013145LGN01_B1.TIF")


randomrastersave <- function(i, k)	
{
	# create a matrix of values i, k
	xy <- matrix(rnorm(200), i, k)
	
	# create a raster of the above variable
	rast <- raster(xy)


	# specify extents in long/lat
	extent <- c(36, 37, -3, -2)

	# set the projection
	projection(rast) <- CRS("+proj=longlat +datum=WGS84")

	rast}


	# this function will use the current working directory's path and name the file in sequential order of elements in the braket
	# k is the no. of clusters in runkmeans function. whats in quotes is not a function but a name.
	#  if the file needs to be saved in a specific directory then write as file.path("/home", "chintan", "path", paste(), sep = "")
	mypath <- file.path(paste(paste(k), "clusters_", files, sep = ""))

	writeRaster(rast, format = "GTiff", file = mypath, overwrite = TRUE)	

}

