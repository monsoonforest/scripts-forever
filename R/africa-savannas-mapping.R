## PROGRAM TO PLOT THE DISTRIBUTION OF NUTRIENTS AND MAP IN dry-zone AND wet-zone SAVANNAS

## create a variable with a all packages named
packages <- c("raster", "rgdal", "rgeos", "maptools","dplyr", "ncdf4", "ggplot2")

## call all packages using lapply
lapply(packages, library,character.only=TRUE)

## CLAY raster
glclay <- raster("data/ISLSCP_SOILS_1DEG_1004/data/soil_clay_perc0-30_1d.asc")

## NITROGEN raster
glnitro <- raster("data/ISLSCP_SOILS_1DEG_1004/data/soil_nitrogen_dens0-30_1d.asc")

## MEAN ANNUAL PRECIPITATION RASTER
maprec <- raster("data/world-clime-2.0/wc2.0_30s_bio/wc2.0_bio_30s_12.tif")

## PHOSPHOROUS DENSITY RASTER
glphos <- raster("data/GLOBAL_PHOSPHORUS_DIST_MAP_1223/data/pforms_den.nc")

## dry-zone SHAPEFILE
dryzone <- readOGR("analysis/savanna-ratnam-book/nutrients/africa/nutrient-rich/nutrient-rich-dryzonesavannas.shp")

## wet-zone SHAPEFILE
wetzone <- readOGR("analysis/savanna-ratnam-book/nutrients/africa/nutrient-poor/nutrient-poor-wet-zonesavannas.shp")



## w is the layer name, and v is the text of the column as saved on a variable
layerdf <- function(w,v,...){

## CROP and then MASK the given raster from the extents "dryzone"
dryjnk <- crop(w, extent(dryzone))
dryimg <- mask(dryjnk, dryzone)

## Create a dataframe of the same
dryimgdf <- as.data.frame(dryimg)

## CROP AND MASK for "wetzone"
wetjnk <- crop(w, extent(wetzone))
wetimg <- mask(wetjnk, wetzone)
wetimgdf <- as.data.frame(wetimg)

## create a new column "LEAF" and name it as per the layer
dryimgdf$leaf <- "dry-zone"

wetimgdf$leaf <- "wet-zone"

## bind the two data frames
fineandbroaddf <- rbind(dryimgdf, wetimgdf)

## remove all the NAs from the dataframe
fineandbroaddf <- na.omit(fineandbroaddf)

## pasting the column name as specified in the function, respective to the layer being used
colnames(fineandbroaddf)[1] <- paste0(v,sep="")

## filter the rows that match the leaf-type and get the 5th and 95th quartiles
dryzonedf <- filter(fineandbroaddf, leaf=="dry-zone")

wetzonedf <- filter(fineandbroaddf, leaf=="wet-zone")

## 5th and 95th quartile of the dataset, rename the leaf column because its renaming it to max value
quantiles <- quantile( dryzonedf[,1], c(.05, .95 ) )
dryzonedf[ dryzonedf < quantiles[1] ] <- quantiles[1]
dryzonedf[ dryzonedf > quantiles[2] ] <- quantiles[2]
dryzonedf$leaf <- "dry-zone"

## 5th and 95th quartile of the dataset, rename the leaf column because its renaming it to max value
quantilesb <- quantile( wetzonedf[,1], c(.05, .95 ) )
wetzonedf[ wetzonedf < quantilesb[1] ] <- quantilesb[1]
wetzonedf[ wetzonedf > quantilesb[2] ] <- quantilesb[2]
wetzonedf$leaf <- "wet-zone"

## bind the two data frames again
quartilecorrected <- rbind(dryzonedf, wetzonedf)

## return fineandbroad into the 
return(quartilecorrected)

}


## NOW save the name of the COLUMNS as variables so that they can be specified in the function layerdf{}
clay <- "clay"

nitrogen <- "nitrogen"

phosphorous <- "phosphorous"

precipitation <- "MAP"



## this will create the required data frames for the layers that can be used in plotting
claydf <- layerdf(glclay, clay)

nitrogendf <- layerdf(glnitro, nitrogen)

phosphorousdf <- layerdf(glphos, phosphorous)

precipdf <- layerdf(maprec, precipitation)


## GET MEANS OF THE FINE AND BROAD LEAVED GROUPS
muclay <- ddply(claydf, "leaf", summarize, grp.mean=mean(clay))
munitro <- ddply(nitrogendf, "leaf", summarize, grp.mean=mean(nitrogen))
muphos <- ddply(phosphorousdf, "leaf", summarize, grp.mean=mean(phosphorous))
muprecip <- ddply(precipdf, "leaf", summarize, grp.mean=mean(MAP))


## plot the ggplot step plot and specify the binwidth

maprecplot <- ggplot(precipdf, aes(x=MAP, colour=leaf)) + geom_step(stat="bin",binwidth=50) +
				geom_vline(data=muprecip, aes(xintercept=grp.mean, colour=leaf), linetype="dashed") +
				scale_x_continuous(limits=c(0,1600), breaks=c(0,200,400,600,800,1000,1200,1400,1600)) +
				xlab("MEAN ANNUAL PRECIPITATION [mm]") + ylab("CELL COUNT")

phosplot <- ggplot(phosphorousdf, aes(x=phosphorous, colour=leaf)) + geom_step(stat="bin",binwidth=50) +
			geom_vline(data=muphos, aes(xintercept=grp.mean, colour=leaf), linetype="dashed") +
			scale_x_continuous(limits=c(0,1400),breaks=c(0,200,400,600,800,1000,1200,1400)) +
			xlab("PHOSPHOROUS DENSITY [g/m2]") + ylab("CELL COUNT")


nitroplot <- ggplot(nitrogendf, aes(x=nitrogen, colour=leaf)) + 
				geom_step(stat="bin",binwidth=10) +
				scale_x_continuous(limits=c(0,700), breaks=c(50,100,150,200,250,300,350,400,450,500,550,600,650,700)) +
				geom_vline(data=munitro, aes(xintercept=grp.mean, colour=leaf), linetype="dashed") +
				xlab("NITROGEN DENSITY [g/m2]") + ylab("CELL COUNT")


clayplot <- ggplot(claydf, aes(x=clay, colour=leaf)) + geom_step(stat="bin",binwidth=2) + 
			geom_vline(data=muclay, aes(xintercept=grp.mean, colour=leaf), linetype="dashed") +
            xlab("PERCENTAGE CLAY") + ylab("CELL COUNT")

ggplot(claydf, aes(x=clay, colour=leaf)) + geom_step(stat="bin",binwidth=2) + 
			geom_vline(data=muclay, aes(xintercept=grp.mean, colour=leaf), linetype="dashed") +
            xlab("PERCENTAGE CLAY") + ylab("CELL COUNT") + scale_fill_manual(values=c("#00AFBB", "#E7B800"))
