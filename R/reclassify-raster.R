	
##  NDWI SCRIPT TO MAP GLACIAL LAKES IN ARUNACHAL

packages <- c("raster", "rgdal", "sp", "plotly", "maptools")

lapply(X = packages, FUN = library, character.only=TRUE)

## RASTER RECLASSIFY FUNCTION

rasterlist <- list.files(pattern=".*.*\\.grd$$", recursive=FALSE)

reclassify <- function(x,...){

for (i in 1:length(x)){

r <- raster(paste0(x[i]))

## reclassify matrix 
						## 0 to   1200 = NA
						##    1201 to 10000000000 = 1
						m <- c(-1, -0.018, NA, -0.018, 0.15, 1, 0.15, 0.7, NA)

						## create matrix of the same
						rclmat <- matrix(m, ncol=3, byrow=TRUE)

					rc <- reclassify(r, rclmat)

writeRaster(rc, filename = "reclassified-built-up-raster-blore.tif", format="GTiff", overwrite=TRUE)

}
 }

 reclassify(rasterlist)