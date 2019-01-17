## CODE TO EXTRACT DATA FROM MULTIPLE RASTERS INTO A POINT FILE

library(raster)
library(rgdal)
library(plyr)
library(dplyr)

## looks for files that DO NOT match the given pattern in grep
l <- grep(list.files(pattern = ".*.*\\.tif$$", recursive=T), pattern='bio', inv=T, value=T)


## CALL YOUR POINT FILE
lemonsites <- read.csv("/home/user/documents/lemon-india/database-creation/LEMON-SITES.csv")

coordinates(lemonsites) = ~longitude+latitude

proj4string(lemonsites) = CRS("+init=epsg:4326")

## CREATE A FUNCTION THAT CAN EXTRACT THE DATA FROM A SINGLE RASTER AND MAKE A DATAFRAME
extractit <- function(x,...){

	r <- raster(paste(x))

	## names(r) will paste the name of the raster in the dataset
	data <- data.frame(lemonsites$siteid, names(r), extract(r, lemonsites))

}


## CREATE A LIST OF THE DATA EXTRACTED FROM EVERY RASTER
jnk <- lapply(l, extractit)


## USING THE DPLYR PACKAGE MAKE A DATAFRAME OF THE LIST
lemonsitesdata <- ldply(jnk, as.data.frame)


names(lemonsitesdata) <- c("SITEID", "DATASET", "VALUE")

## now reshape the datasets such that every SITE IS A ROW AND THE DATASETS FOLLOW AS COLUMNS
jnk3 <- reshape(lemonsitesdata, timevar="DATASET", idvar="SITEID", direction="wide")