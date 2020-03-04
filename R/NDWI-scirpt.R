	
##  NDWI SCRIPT TO MAP GLACIAL LAKES IN ARUNACHAL

packages <- c("raster", "rgdal", "sp", "plotly", "maptools")

lapply(X = packages, FUN = library, character.only=TRUE)


##setwd("/home/csheth/documents/work/remote-sensing/lohit-dibang-glaciers/satellite-images/mathun-basin/2015/")

mathun_basin_2015_list <- list.files(pattern=".*merged.*\\.tif$$", recursive=TRUE)


## here x should be a list of characters

NDWI <- function(x,...){

		for (i in 1:length(x)) {


					r <- stack(paste0(x[i]))

					names(r) <- c("blue", "green", "red", "red_edge", "nir")

					ndwi <- (r[["green"]] - r[["nir"]])/(r[["green"]] + r[["nir"]])

						## reclassify matrix 
						## -1 to   -0.19 = 0 
						##    -0.19 to 1 = 1
						m <- c(-1, -0.19, 1, -0.19, 1, NA)

						## create matrix of the same
						rclmat <- matrix(m, ncol=3, byrow=TRUE)

					rc <- reclassify(ndwi, rclmat)	

					##rc_poly <- rasterToPolygons(rc, fun=NULL, n=8, na.rm=TRUE, digits=12, dissolve=FALSE)

					## set file path such that we can name rasters with an rc suffix
					## split x[i] into two parts where the slash occurs. first part gives ndwi, second gives the tile number used
					filepath1 <- paste0("2015_ndwi_", paste0(unlist(strsplit(x[i], split='_'))[3]))

					filepath2 <- paste0("2015_ndwi_reclassified_", paste0(unlist(strsplit(x[i], split='_'))[3]))

					filepath3 <- paste0("2015_ndwi_reclassified_polygon_", paste0(unlist(strsplit(x[i], split='_'))[3]))

					writeRaster(ndwi, filename = filepath1, format="GTiff", overwrite=TRUE)

					writeRaster(rc, filename = filepath2, format="GTiff", overwrite=TRUE)

					##writeOGR(rc_poly, filename=filepath3, driver="ESRI Shapefile")	


								} 
						}


NDWI(mathun_basin_2015_list)


