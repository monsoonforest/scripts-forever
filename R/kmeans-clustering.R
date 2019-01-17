# A functions to cluster an image using k-means in R



# "i" is any image that needs to be clustered, this function is designed to deal with RasterLayers  "k" is the number of cluster centers to be computed in the image


kclustering <- function (i, k, ...) {

			# create a data.frame of the RasterLayer
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
			# k is the no. of clusters in kclustering function. what is in quotes is not a function but part of the desired filename.
			# if the file needs to be saved in a specific directory then write as "file.path("/home", "chintan", "path", paste(), ".tif", sep = "")""
			mypath <- file.path(paste(paste(k), "classes-band8", ".tif", sep = ""))

			# f4 is a function that will write out the RasterLayer in blocks of rows as calculated using "blockSize".
			# Check the function "blockSize-rasterprocessing-function.R" in the folder "/dibang-landcover/R/scripts/functions"
			f4(clusters,  filename = mypath, format = "GTiff", overwrite = TRUE)
		
		}