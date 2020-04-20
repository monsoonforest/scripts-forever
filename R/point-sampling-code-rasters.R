## CODE TO EXTRACT DATA FROM MULTIPLE RASTERS INTO A POINT FILE

library(raster)
library(rgdal)
library(plyr)
library(dplyr)
library(stringr)

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


## FOR POLYGONS

l <- list.files(pattern = ".*.*\\.tif$$", recursive=T)

polygon <- readOGR("/home/csheth/documents/work/remote-sensing/papum-reserve-forest/from-datta/gis-files/papum-reserve-forest-utm46.shp")

extractit <- function(x,...){

	r <- raster(paste(x))

	## names(r) will paste the name of the raster in the dataset as every row
	data <- data.frame(names(r), extract(r, polygon))

}

jnk <- lapply(l, extractit)

## rename the columns in the dataframe
for (i in 1: length(jnk)) { names(jnk[[i]]) <- c("cell", "prec")}

## Bind all rows of every dataframe in the list
allmonths <- bind_rows(jnk)

names(allmonths) <- c("month", "prec")

## Remove the string to reaname it to a month
allmonths$month <- str_remove_all(allmonths$month, "wc2.1_2.5m_tavg_")


##allmonths$month <- str_remove_all(allmonths$month, "wc2.0_30s_prec_")


##allmonths$month <- str_replace_all(allmonths$month, c("01" = "January", "02" = "February", "03" = "March", "04"= "April", "05" = "May", "06" = "June", "07" = "July", "08" = "August", "09" = "September", "10" = "October", "11" = "November", "12" = "December"))


allmonths %>% group_by(month) %>% summarise_all(mean=mean(prec), SD=sd(prec)) %>% mutate(total=sum(mean))