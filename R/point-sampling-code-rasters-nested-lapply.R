## CODE TO EXTRACT DATA FROM MULTIPLE RASTERS INTO A POINT FILE

library(raster)
library(rgdal)
library(plyr)
library(dplyr)
library(reshape2)

## looks for files that DO NOT match the given pattern in grep
##l <- grep(list.files(pattern = ".*.*\\.tif$$", recursive=T), pattern='bio', inv=T, value=T)

## CODE TO EXTRACT DATA FROM MULTIPLE RASTERS INTO A POINT FILE
bio_clim_list <- list.files(path="/media/user/DATA/Kaikho/Bioclim",pattern = ".*bio.*\\.tif$$", recursive=T)


## LIST ALL THE SPECIES WITH THEIR LOCATIONS
combretum_list <- list.files(pattern=".*thin1.*\\.csv$$", recursive=TRUE)


## FUCNTION TO EXTRACT DATA FROM A LIST OF RASTERS OF A LIST OF SPATIAL POINTS DATAFRAMES
extract_data_func <- function(x,y,...){

	## CALL THE SPECIES CSV
	species <- read.csv(x)

	## SET THE COORDINATES
	coordinates(species) = ~Longitude+Latitude

	## SET THE CRS
	proj4string(species) = CRS("+init=epsg:4326")

	## STORE THE FILENAME VARIABLE OF EACH SPECIES >> ELEMENT IN THE LIST
	file_name <- paste0(sub(".*/(Combretum_[a-z]+).*", "\\1", x), "_bio_clim.csv")

## CREATE A LIST OF THE DATA THAT HAS BEEN EXTRACTED FOR EACH BIOCLIM RASTER
listed_df <-	
	
		lapply(y,function(z,...){

		r <- raster(paste0("/media/user/DATA/Kaikho/Bioclim/",z))

		extracted <- data.frame(species$Species, species$Longitude, species$Latitude, names(r), extract(r,species))

		})
		
	## BIND ALL THE ROWS OF THE LIST
	data <- bind_rows(listed_df)

	## SET THE NAMES OF COLUMNS OF THE DATA FRAME
	names(data) <- c("Species","Longitude","Latitude", "BIO", "value") 
		
	data <- reshape(data, timevar="BIO", idvar=c("Species","Longitude","Latitude"), direction="wide")

write.csv(data, file_name)

}


## CREATE A LIST OF THE DATA EXTRACTED FROM EVERY RASTER
lapply(combretum_list, extract_data_func, bio_clim_list)