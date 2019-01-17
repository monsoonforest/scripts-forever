### PERFORMING K-MEAnS CLUSTERIING ON BAND8 TO MASK OUT CLOUDS WATER 

library(raster)
library(tools)

setwd("/home/chintan/documents/work/remote_sensing/analysis/dibang-landcover/output/clustering/band8-clustering")



B8 <- raster("")

# sets NA for a given value, here: 0
B8[B8 %in% 0] <- NA


## function to write rasters in blocksized units to preserve system memory
f4 <- function(x, filename, format, ...) 
	{
		out <- raster(x)

		bs <- blockSize(out)

		out <- writeStart(out, filename, overwrite=TRUE)

		for (i in 1:bs$n) 

		{

			v <- getValues(x, row=bs$row[i], nrows=bs$nrows[i] )

			out <- writeValues(out, v, bs$row[i])

		}

		out <- writeStop(out)

		return(out)
	}

# save the raster on disk
f4(B8, "Band8-NAat-0.tif", format = "GTiff")

# assign the last evaluated  classified raster of Band8 to the RasterLayer "raster1"
raster1 <- raster("2classes-.tiff")
	

## filename() gives me the entire path-to-file; ‘basename’ removes all of the path up to and including the last path separator (if any); 
## and file_path_sans_ext() removes the file extension.
name <- file_path_sans_ext(basename(filename(raster1)))


## classified.img is the previous classified RasterLayer clustered using kmeans . B8 is the band8 RasterLayer
## function will set NA values in the raster according to the NA values in the classified raster
setNA <- function(classified.img, B8, ...)	
	{
			
		# set NA at the required class (snow, water, clouds)
		classified.img[classified.img %in% 1] <- NA

		# create a RasterLayer called imgdimension  
		imgdimension <- raster(classified.img)

		# modifiedclassified.img is an array of the values of the RasterLayer classified.img
		modifiedclassified.img <- getValues(classified.img)
		
		x <- setValues(imgdimension, modifiedclassified.img)
		x

		# filepath will create a name of the raster c, where we have added NA values at some unecessary class like snow
		filepath <- file.path(paste(paste(name), "NA-at-class    ??????   ", ".tif", sep = ""))								#### RENAME HERE!!!
		
		# write the raster to file using the functon f4
		f4(x, filename = filepath, format = "GTiff", overwrite = TRUE)

		## B8 is band8 RasterLayer and this expression sets NAs at locations that are NA in the RasterLayer x
		values(B8)[is.na(values(x))] <- NA

		# create a RasterLayer with the extents of "B8"
		B8withNAraster <- raster(B8)
		
		# get the values of B8 on a vector "B"
		B <- getValues(B8)
		
		# set the values in "B8withNAraster" from the values in "B"
		y <- setValues(B8withNAraster, B)
		
		# write the raster "y" to disk
		f4(y, filename = "B8withNAatclass      ?????    classraster.tiff", overwrite = TRUE)    ##### RENAME HERE!!!

	} 


# open the RaterLayer saved after setting NAs in the required locations.
B8NA <- raster("B8withNAatclass1of2classraster")

## Do not run this on the RasterLayer it is memory expensive and the Ubuntu kernal will kill the process as the OS is out of memory
## clustering function to cluster and image "i" with "k" clusters

kclustering <- function (i, k, ...) 
			
			{

				# create a data.frame of the raster layer
				raster.df <- as.data.frame(i)

				# create a matrix of this dataframe. instead of using as.matrix() directly on the raster, data.matix() will handle factors 
				# appropriately by converting them to numeric values based on the internal levels. Coercing via as.matrix() will result in a 
				# character matrix if any of the factor labels is a non-numeric.
				raster.matrix <- data.matrix(raster.df)

				# run a k-means on the matrix omiting the NAs
				cluster.image <- kmeans(na.omit(raster.matrix), k, iter.max = 20, nstart = 25)	

				# fill up the NAs back from band8 raster
				image.matrix.factor <- rep(NA, length(raster.matrix[,1]))
				image.matrix.factor[!is.na(raster.matrix[,1])] <- cluster.image$cluster

				# create raster output
				# create an empty raster with same extent than "b"
				clusters <- raster(i)

				# fill the empty raster with the class results
				clusters <- setValues(clusters, image.matrix.factor)

				# this function will use the current working directory's path and name the file in sequential order of elements within the "paste()" function
				# k is the no. of clusters in band1kmeans function. whats in quotes is not a function but part of the desired filename.
				# if the file needs to be saved in a specific directory then write as file.path("/home", "chintan", "path", paste(), sep = "")
				mypath <- file.path(paste(paste(k), "classes-band8", ".tif", sep = ""))

				f4(clusters,  filename = mypath, format = "GTiff", overwrite = TRUE)
	
			}