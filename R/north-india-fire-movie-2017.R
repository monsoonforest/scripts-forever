## CODE TO CREATE ANIMATION OF BURNED AREA OF NORTH INDIA FOR 17 YEARS

## Load required packages
packages <- c("raster", "rgdal", "ggplot2", "ggmap", "reshape", "tidyr","dplyr", "ggridges", "broom")
lapply(X = packages, FUN = library, character.only=TRUE)

## Recursively list all rasters with the pattern
burndaterasterlist <- list.files(pattern=".*burndate.*\\.tif$", recursive = TRUE)

## stack the rasters
burnstack <- stack(burndaterasterlist)

## get AOI of region
aoi <- readOGR("/home/user/documents/csheth/gis-rs-work/remotely-sensed/MODIS/fire/north-pak-india-nov-2017/polygon.shp")

## crop the area within the burnstack to extents of the aoi
burnjnk <- crop(burnstack, extent(aoi))

## create a mask of the cropped area
burnedaoistack <- mask(burnjnk, aoi)

## Set NA values that are less than or equal to 0
burnedaoistack[burnedaoistack <= 0] <- NA

## get centroid of aoi
centroid <- getSpPPolygonsLabptSlots(aoi)

polylist <- lapply(as.list(burnedaoistack), rasterToPolygons)

## make a list of the names of the rasters
rasternames <- names(burnstack)

dfrasternames <- as.data.frame(rasternames)

## make a dataframe and split the columns using a period
rasternamesplit <- separate(data = dfrasternames, col = rasternames, 
	into = c("l1", "l2", "l3", "l4", "l5"), sep = "\\.")

## column of year list of rasters
yearlist <- data.frame(rasternamesplit$l2)

## rename the column l2 to yearstring
colnames(yearlist)[1] <- "yearstring"

##create an ID list of the rows
yearlist$ID <- seq.int(nrow(yearlist))

## Gives the year of the raster
##substr(yearlist$yearstring, 2,5)
## gives the julian day of the raster
##substr(yearlist$yearstring, 6,8)

## create a new dataframe to separate the data  into two columns splitting it at character 5
yearname <- separate(data = yearlist, col=yearstring, into = c("year", "julianday"), sep=5)

## remove the letter A from the dataframe
yearname <- lapply(yearname, gsub, pattern='A', replacement='')

## convert the julianday column to a numeric
yearname$julianday <- as.numeric(as.character(yearname$julianday))
class(yearname$julianday)

## make a another column named month from the julian day data
yearname$month <- (yearname$julianday/30) + 1
 
 head(yearname)

## make as an integer
yearname$month <- lapply(yearname$month, as.integer)
head(yearname)
 
## convert all months to month names
yearname$monthname[yearname$month == 1] <- "january"
yearname$monthname[yearname$month == 2] <- "february"
yearname$monthname[yearname$month == 3] <- "march"
yearname$monthname[yearname$month == 4] <- "april"
yearname$monthname[yearname$month == 5] <- "may"
yearname$monthname[yearname$month == 6] <- "june"
yearname$monthname[yearname$month == 7] <- "july"
yearname$monthname[yearname$month == 8] <- "august"
yearname$monthname[yearname$month == 9] <- "september"
yearname$monthname[yearname$month == 10] <- "october"
yearname$monthname[yearname$month == 11] <- "november"
yearname$monthname[yearname$month == 12] <- "december"

head(yearname)
 ## year julianday ID month monthname
##1 2000       306  1    11  november
##2 2000       336  2    12  december
##3 2001         1  3     1   january
##4 2001        32  4     2  february
##5 2001        60  5     3     march
##6 2001        91  6     4     april

## create a list of names of the rasters in the rsaterstack
rasternamenew <- paste(yearname$month, yearname$year, sep="-")

## rename the rasterstack layers
names(burnedaoistack) <- paste0(rasternamenew)

## create a list of polygons of the rasterstack and reorder sequence so that 
## firemap function can read it in sequence
polylist <- polylist[!sapply(polylist, is.null)]


## where x is the polygon list
firemap <- function(x, ...) {

## map centre, hybrid, zoom, and admin layers to view for the plot
map <-	get_googlemap(center = c(75.99605, 30.20054), zoom=7, maptype = "hybrid",
             			style ="feature:administrative.locality|element:labels|visibility:off|
    	          			feature:administrative.province|element:labels|visibility:off|
	       	      			feature:poi.attraction|element:labels|visibility:off")

## tidy is from the library broom		
mapplot <- ggmap(map) + geom_polygon(data = tidy(x),
            				aes(long, lat, group = group),
             				fill = "orange", colour = "red", size=0.1) +
							labs(title = names(x), x = "LONGITUDE", y = "LATTITUDE")


## get the name to path to be placed in ggsave
## firename = "/home/user/Win18/plots/x.jpeg"
firename <- file.path("/home/user/Win18/plots", paste(names(x), ".jpeg", sep=""))

## filename, plot to plot, dimensions and units
ggsave(filename = firename, plot = mapplot, width=15, height=15, unit = "cm")
}

## apply the firemap function to the polygons
 lapply(polylist, firemap)


## ## get a list of names of the polygons into another list using lapply
polynameslist <- lapply(polylist, names)

head(polynameslist)

class(polynameslist)


## create a data frame of the list after unlistingm creating a matrix and then data.frame
df <- data.frame(matrix(unlist(polynameslist), nrow=177, byrow=T),stringsAsFactors=FALSE)

## rename the first column to something sensible
colnames(df)[1] <- "name"

## create an ID column of the 
df$ID <- seq.int(nrow(df))

## this summary gives the features of the polygon list we first created
df2 <- summary(polylist)

## length means the number of features in each polygon = number of 500m pixels in the raster
##head(df2)
##     Length Class                    Mode
##[1,]   346  SpatialPolygonsDataFrame S4  
##[2,]   177  SpatialPolygonsDataFrame S4  
##[3,]   167  SpatialPolygonsDataFrame S4  
##[4,]   105  SpatialPolygonsDataFrame S4  
##[5,]    66  SpatialPolygonsDataFrame S4  
##[6,]  7597  SpatialPolygonsDataFrame S4 

## Unclass the summary table
df2 <- unclass(df2)

class(df2)
[1] "matrix"

## make it a data.frame
df2 <- as.data.frame(df2)

## create an ID column for df2 as well
df2$ID <- seq.int(nrow(df2))

## use dplyr and left_join the two tables using the ID column
firepolycount <- left_join(df, df2, by="ID")

##head(firepolycount)
  ##         name ID Length                    Class Mode
##1 november.2000  1    346 SpatialPolygonsDataFrame   S4
##2 december.2000  2    177 SpatialPolygonsDataFrame   S4
##3  january.2001  3    167 SpatialPolygonsDataFrame   S4
##4 february.2001  4    105 SpatialPolygonsDataFrame   S4
##5    march.2001  5     66 SpatialPolygonsDataFrame   S4
##6    april.2001  6   7597 SpatialPolygonsDataFrame   S4

## create a vector called drops naming the columns to drop
drops <- c("Class", "Mode")

## create the data.frame firepolycount again after dropping "drops"
firepolycount <- firepolycount[, !(names(firepolycount) %in% drops)]

## rename the Length column to feature counts
colnames(firepolycount)[3] <- "featurecount"

## create a new column called areakm2 which is the burned area after multiplying
## the feature count with 250000 m2 and dividing by 1000000 for km2 units
firepolycount$areakm2 <- (firepolycount$featurecount*500*500)/1000000

##head(firepolycount)
##           name ID featurecount areakm2
##1 november.2000  1          346   86.50
##2 december.2000  2          177   44.25
##3  january.2001  3          167   41.75
##4 february.2001  4          105   26.25
##5    march.2001  5           66   16.50
##6    april.2001  6         7597 1899.25



 animate(x = aoiburnstack, pause = 0.25, n = 1)	


## boring PLOT
plot_ly(firepolycount, x = ~name, y = ~areakm2, type ='bar')

## split the dataframe making year as another column
firepolycount1 <- separate(data = firepolycount, col=name, into=c("month", "year"), sep="\\.")

## head(firepolycount1)
##     month year ID featurecount areakm2
##1 november 2000  1          346   86.50
##2 december 2000  2          177   44.25
##3  january 2001  3          167   41.75
##4 february 2001  4          105   26.25
##5    march 2001  5           66   16.50
##6    april 2001  6         7597 1899.25



colrs <- c("#a6cee3", "#1f78b4", "#b2df8a", "#33a02c", "#fb9a99", "#e31a1c","#fdbf6f","#ff7f00","#cab2d6", "#6a3d9a", "#ffff99", "#b15928") 

 burnedareaplot <- ggplot(firepolycount1, aes(year, areakm2)) + 
 geom_bar(aes(fill=factor(month, levels = c("january", "february", "march", "april", "may", "june", "july",
  "august", "september", "october", "november", "december"))), stat="identity") + 
 scale_fill_manual("month",values=colrs) + labs(x="YEAR", y="BURNED AREA IN SQUARE KILOMETRES") +
 scale_y_continuous(breaks=seq(0,50000,5000))

ggsave(filename = "/home/user/Win18/plots/burnedareaplot.jpeg", plot = burnedareaplot, width=25, height=15, unit = "cm")
