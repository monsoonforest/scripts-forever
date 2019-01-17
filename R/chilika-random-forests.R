## from http://amsantacco/blog/en/2015/11/28/classification-rhtml

##list of packages required
packages <- c("rgdal", "snow", "tools", "raster", "randomForest", "caret")

##call all packages at once instead of one at a time
lapply(packages, library, character.only=TRUE)

## set the working directory
setwd("")

##create an object of the rasters in the directory only these rasters will be used for the classification
rasters <- list.files(pattern='\\.tif$')

##create a raster stack of the images
img <- stack(rasters)

rasters

RT_T45QUB_20170108T045151_B02 
RT_T45QUB_20170108T045151_B03
RT_T45QUB_20170108T045151_B04 
RT_T45QUB_20170108T045151_B05
RT_T45QUB_20170108T045151_B06 
RT_T45QUB_20170108T045151_B07
RT_T45QUB_20170108T045151_B08 
RT_T45QUB_20170108T045151_B09
RT_T45QUB_20170108T045151_B11 
RT_T45QUB_20170108T045151_B12
RT_T45QUB_20170108T045151_B8A


##get names of the images
names(img)

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

## get the raster which is 2 classes. water and land
water <- raster("products/1263-water-rf.tif")

## set NA at the water layer
water[water %in% 1] <- NA

## create a RasterLayer called water
waterdim <- raster(water)

## modwater is an array of the values of the RasterLayed waterdim
modwater <- getValues(water)

## set values of the raster from modwater of extents/dimensions waterdim
waterNA <- setValues(waterdim, modwater)

## write file to disk as it will be used by other functions
f4(waterNA, filename="waterNA", format="GTiff")

i <- raster("RT_T45QUB_20170108T045151_B8A.tif")

## classified.img is the previous classified RasterLayer clustered using kmeans . B8 is the band8 RasterLayer
## function will set NA values in the raster according to the NA values in the classified raster
setNA <- function(i, ...)	
	{
		## filename() gives me the entire path-to-file; ‘basename’ removes all of the path up to and 
		## including the last path separator (if any); 
		## and file_path_sans_ext() removes the file extension.
		name <- file_path_sans_ext(basename(filename(i)))

		# filepath will create a name of the raster c, where we have added NA values at some unecessary class 
		## like snow		#### RENAME HERE!!!
		filepath <- file.path(paste(paste(name), "NA-at-water", ".tif", sep = ""))
		
		## B8 is band8 RasterLayer and this expression sets NAs at locations that are NA in the RasterLayer x
		values(i)[is.na(values(waterNA))] <- NA

		# create a RasterLayer with the extents of "B8"
		bandwithNAraster <- raster(i)
		
		# get the values of B8 on a vector "B"
		B <- getValues(i)
		
		# set the values in "B8withNAraster" from the values in "B"
			y <- setValues(bandwithNAraster, B)
		
		# write the raster "y" to disk
		##### RENAME HERE!!!	
		f4(y, filename = filepath, overwrite = TRUE)

	} 

## have to do it individually for each raster till you find lapply
setNA(i)

img <- stack("MY RASTER")
names(img) <- c("X1","X2","X3","X4","X5")


## train the data
trainData <- shapefile("shp")

##set response col as class
responseCol <- "class"

	dfAll = data.frame(matrix(vector(), nrow = 0, ncol = length(names(img)) + 1))   
 for (i in 1:length(unique(trainData[[responseCol]]))){
  category <- unique(trainData[[responseCol]])[i]
  categorymap <- trainData[trainData[[responseCol]] == category,]
  dataSet <- extract(img, categorymap)
  if(is(trainData, "SpatialPointsDataFrame")){
    dataSet <- cbind(dataSet, class = as.numeric(rep(category, nrow(dataSet))))
    dfAll <- rbind(dfAll, dataSet[complete.cases(dataSet),])
  }
  if(is(trainData, "SpatialPolygonsDataFrame")){
    dataSet <- dataSet[!unlist(lapply(dataSet, is.null))]
    dataSet <- lapply(dataSet, function(x){cbind(x, class = as.numeric(rep(category, nrow(x))))})
    df <- do.call("rbind", dataSet)
    dfAll <- rbind(dfAll, df)
  }
}

nsamples <- 6000
sdfAll <- subset(dfAll[sample(1:nrow(dfAll), nsamples), ])

modFit_rf <- train(as.factor(class) ~ X1 + X2 + X3 + X4 + X5, method = "rf", data = sdfAll, na.action=na.omit)

beginCluster()
preds_rf <- clusterR(img, raster::predict, args = list(model = modFit_rf))
endCluster()

preds_rf <- predict(img, model=modFit_rf, na.rm=T)


table(factor(pred.rf, levels=min(test):max(test)), 
      factor(test, levels=min(test):max(test)))


mod.rf <- train(as.factor(class) ~  X1 + X2 + X3 + X4 + X5, method = "rf", data = training_bc)
pred.rf <- predict(mod.rf, testing)