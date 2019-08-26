## PROGRAM TO CALCULATE FIRE RETURN-INTERVAL OR PROBABILITY OF A LOCATION CATCHNG FIRE USING MCD64 MODIS
## 17 YEARS DATASET

## Load required packages
packages <- c("raster", "rgdal", "ggplot2", "ggmap", "reshape", "tidyr","dplyr", "ggridges", "broom")
lapply(X = packages, FUN = library, character.only=TRUE)

## Recursively list all rasters with the pattern
burndaterasterlist <- list.files(pattern=".*burndate.*\\.tif$", recursive = TRUE)

## remove the year 2000 as it is incomplete
burndaterasterlist <- burndaterasterlist[-1]

## reclassify matrix 
## -40000 to   0 = 0 
##      0 to 366 = 1
m <- c(-40000, 0, 0, 0, 366, 1)

## create matrix of the same
rclmat <- matrix(m, ncol=3, byrow=TRUE)


## batch reclassification into binary 1 and 0
batch_reclass <- function(x,...){
	for (i in 1:length(x)) {
		#read in raster
		r <- raster(paste0(x[i]))
		#perform the reclassifcation
		rc <- reclassify(r, rclmat)

		## set file path such that we can name rasters with an rc suffix
		## split x[i] into two parts where the slash occurs. first part gives year, second is /rc and third is month file
		filepath <- paste0(paste0(unlist(strsplit(x[i], split='/'))[1]), "/rc_", paste0(unlist(strsplit(x[i], split='/'))[2]))

		#write each reclass to a new file 
		writeRaster(rc, filename = filepath, format="GTiff", overwrite=TRUE)
} }

## reclassify all months data
batch_reclass(burndaterasterlist)

## keep both false otherwise full.names will create "./2000" that won't read into the lapply stack 
years <- list.files(full.names=FALSE, recursive=FALSE, pattern="2")

## function to list files in a given path
listing <- function(x,...){
     list.files(path=x, pattern=".*rc.*\\.tif$", full.names = TRUE)
 }

## create a list of the list of files in each directory
yearlist <- lapply(years, listing)

## remove the year 2000 becuase the data is incomplete
yearlist <- yearlist[-1]

a <- getwd()

regionnumber <- paste0(unlist(strsplit(a, split='/'))[4])


DID YOU RENAME THE FILEPATH2????

##NOW TO ADD ALL RASTERS of a year and divide by itself
sumitdivideit <- function(x,...){

		## place i within two square brackets as that is how you access the character. wihin in single brackets it will read it as a list only
		## see class(monthlist[1]) vs. class(monthlist[[1]])
		yearstack <- stack(paste0(x))
			
		## use stackApply to sum every stack. Each stack is a list of every months burndate of a given year.	
		yearsum <- stackApply(yearstack, indices=rep(1,nlayers(yearstack)), fun="sum") 	

		## divide the year sum by itself to make it a binary file
		yearsumbinary <- yearsum/yearsum

		## create a varibale called year, so that it can be pasted within the naming filepath
		year <- paste0(unlist(strsplit(paste0(unlist(x)[1]), split='/'))[1])

		## create the file path, place in the year first to access the directory, then the "/yearsumbinary", year again (is included in filename), region name = ...
		filepath2 <-  paste0(year, "/yearsumbinary_", year, "-Madagascar-", regionnumber)

		## write the rasters into each directory
		writeRaster(yearsumbinary, filename=filepath2, format="GTiff", overwrite=TRUE)
}


## Run the damn function on the list
lapply(yearlist, sumitdivideit)


## list all files with yearly summed fire, matching the pattern = yearsumbinary
yearlysummedfire <- list.files(pattern = ".*yearsumbinary.*\\.tif$", full.names = FALSE, recursive = TRUE)

## create a stack of the list
yearlyfirestack <- stack(yearlysummedfire)

## sum all the years of burned pixels.
seventeenyearsum <- stackApply(yearlyfirestack, indices=rep(1,nlayers(yearlyfirestack)), fun="sum")

DID you rename the file????
## write the raster! 
writeRaster(seventeenyearsum, filename="seventeenyearfire-Win18-India", format="GTiff", overwrite=TRUE)
