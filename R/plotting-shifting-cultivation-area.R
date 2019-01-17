
## Load required packages
packages <- c("raster", "rgdal", "ggplot2", "ggmap", "reshape", "tidyr","dplyr", "ggridges", "broom")
lapply(X = packages, FUN = library, character.only=TRUE)

## list the rasters
nbrlist <- list.files(pattern="\\.tif$$")


## reclassify matrix 
## -1 thru -0.3 = 1
## -0.3 thru -0.1 = 2
## -0.1 thru 0.1 = 3
## 0.1 thru 0.25 = 4
## 0.25 thru 0.45 = 5
## 0.45 thru 0.70 = 6
## 0.70 thru 1 = 7
m <- c(-1, -0.3, 1, -0.3,-0.1, 2, -0.1, 0.1, 3, 0.1, 0.25, 4, 0.25, 0.45, 5, 0.45, 0.70, 6, 0.70, 1, 7)

## create matrix of the same
rclmat <- matrix(m, ncol=3, byrow=TRUE)


## batch reclassification into binary 1 and 0
batch_reclass <- function(x,...){
		#read in raster
		r <- raster(paste0(x))
		#perform the reclassifcation
		rc <- reclassify(r, rclmat)

		## set file path such that we can name rasters with an rc suffix
		
		filepath <- paste0("reclass-", paste0(x))

		#write each reclass to a new file 
		writeRaster(rc, filename = filepath, format="GTiff", overwrite=TRUE)
 }

## reclassify all months data
lapply(nbrlist, batch_reclass)



## create a list of the JHUM polygons
polylist <- list.files(pattern="\\.shp$$")

## create a function to calculate the area sums of all polygons in each shapefile
polyarea <- function(p,...){
	## make each element a shapefile
	x <- shapefile(p)

	## get area in hectares
	x$area_ha <- area(x)/10000
	y <- sum(x$area_ha)
}

## create a list of the po
polyarealist <- lapply(polylist, polyarea)

## get the name of each element in the polylist
l <- lapply(polylist, getname)

## add the names from l to the polyarea list
names(polyarealist) <- l

## create a dataframe of the year and the area burned
jhumyearareadf <- do.call(rbind.data.frame, polyarealist)

## create a dataframe such that each row name is a column entry itself and name it by year
jhumyearareadf <- rownames_to_column(jhumyeardf, "YEAR")

## rename the second column header
colnames(jhumyearareadf)[2] <- "area_hectare"


## ggplot bar plot of the same
plot <- ggplot(jhumareayear, aes(x=YEAR, y=area_hectare)) + geom_bar(stat="identity") +
 xlab("YEAR") +
 ylab("AREA UNDER SHIFTING CULTIVATION [HECTARE]") +
 scale_y_continuous(breaks=c(0, 25, 50, 75, 100, 125, 150, 175, 200)) +
theme(
    axis.title.x=element_text(angle=0, color='black', face="bold", size=14),
    axis.title.y=element_text(angle=90, color='black', face='bold', size=14),
    axis.text.x=element_text(angle=0, color='black', size=10),
     axis.text.y=element_text(angle=0, color='black', size=10),
    legend.title=element_blank()
    )

ggsave(filename = "shifting-cultivation-area.jpeg", plot = plot, width=25, height=15, unit = "cm")
