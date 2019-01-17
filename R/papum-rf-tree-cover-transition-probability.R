## TRANSITION PROBABILITY BETWEEN TC 2000 TO TC 2010

## count number of pixels of a certain value in a raster

## create a variable with a all packages named
packages <- c("raster", "gridExtra","data.table", "rgdal", "rgeos", "maptools","dplyr", "ncdf4", "ggplot2", "tibble", "wesanderson", "scales")

## call all packages using lapply
lapply(packages, library,character.only=TRUE)


## CALL BOTH THE RASTERS INTO MEMORY
treecover2000 <- raster("tree-cover-2000-papum-rf-clip-utm46.tif")
treecover2010 <- raster("tree-cover-2010-papum-rf-clip-utm46.tif")

## COVERT THE 2000 TREE COVER LAYER INTO A GRID
treecover2000pts <- rasterToPoints(treecover2000)

## DEFINE A VARIABLE XY THAT REFERS TO THE COLUMNS X AND Y IN THE POINTS FILE
xy <- treecover2000pts[,c(1,2)]

## CONVERT THE POINTS FILE INTO A DATAFRAME
treecoverptssp <- SpatialPointsDataFrame(coords = xy, data=as.data.frame(treecover2000pts), proj4string = CRS("+proj=utm +zone=46 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"))

## CREATE A SEQUENCE OF ID's FOR THE ROWS THUS GIVING EACH PIXEL A UNIQUE ID
treecoverptssp$ID <- seq.int(nrow(treecoverptssp))

## CREATE A DATAFRAME OF THE VALUES OF TREECOVER 2010 FROM THE SAME LOCATIONS AS THE TREE COVER 2000
trial <- data.frame(treecoverptssp$ID, raster::extract(treecover2000, treecoverptssp), raster::extract(treecover2010, treecoverptssp))

## RENAME THE DATAFRAME
names(trial) <- c("ID","treecover2000", "treecover2010")

trial$treecover2000 <- as.numeric(trial$treecover2000)
trial$treecover2010 <- as.numeric(trial$treecover2010)

trial$TC2000bins <- cut(trial$treecover2000, breaks=c(0,10,20,30,40,50,60,70,80,90,100), labels=c("0-10","11-20","21-30","31-40","41-50","51-60","61-70","71-80","81-90","91-100"))
trial$TC2010bins <- cut(trial$treecover2010, breaks=c(0,10,20,30,40,50,60,70,80,90,100), labels=c("0-10","11-20","21-30","31-40","41-50","51-60","61-70","71-80","81-90","91-100"))

trial$TC2010bins[is.na(trial$TC2010bins)] <- "0-10"

myCols <- c("TC2000bins", "TC2010bins")
jnk <- trial %>% select(match(myCols,names(.)))

countsbygroup <- table(jnk[,c("TC2000bins","TC2010bins")])

library(ca)
## CORRESPONDENCE ANALYSIS
plot(ca(countsbygroup))

transitionmatrix <- countsbygroup/rowSums(countsbygroup)

transitionmatrixmelt <- melt(transitionmatrix)

ggplot(transitionmatrixmelt, aes(TC2000bins, TC2010bins, fill=value))+scale_fill_viridis() + coord_equal() + xlab("TREE COVER 2000") +ylab("TREE COVER 2010") + geom_tile()


## THE N SIZE OF EACH TREE COVER CLASS IS UNEQUAL, HENCE THE CONFIDENCE INTERVAL OF THE PROBABILITIES WILL BE DIFFERENT



##	TRY TRANSITION PROBABILITY FROM FOREST TO NO FOREST





