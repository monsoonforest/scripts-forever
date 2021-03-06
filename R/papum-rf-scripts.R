## count number of pixels of a certain value in a raster

## create a variable with a all packages named
packages <- c("raster", "gridExtra","data.table", "rgdal", "rgeos", "maptools","dplyr", "ncdf4", "ggplot2", "tibble", "wesanderson", "scales")

## call all packages using lapply
lapply(packages, library,character.only=TRUE)


loss20012009count <- read.csv("2001-2009-lost-pixels-tree-cover-cell-count-area.csv")
loss20102017count <- read.csv("2010-2017-lost-pixels-tree-cover-cell-count-area.csv")

loss20012009count$treecover2000 <- as.numeric(loss20012009count$treecover2000)
loss20102017count$treecover2010 <- as.numeric(loss20102017count$treecover2010)

loss20012009count$bins <- cut(loss20012009count$treecover2000, breaks=c(0,10,20,30,40,50,60,70,80,90,100), labels=c("0-10","11-20","21-30","31-40","41-50","51-60","61-70","71-80","81-90","91-100"))
loss20102017count$bins <- cut(loss20102017count$treecover2010, breaks=c(0,10,20,30,40,50,60,70,80,90,100), labels=c("0-10","11-20","21-30","31-40","41-50","51-60","61-70","71-80","81-90","91-100"))


treecover2000bins <- loss20012009count %>% group_by(bins) %>% summarise(binareaha = sum(arealosthectare))
treecover2010bins <- loss20102017count %>% group_by(bins) %>% summarise(binareaha = sum(arealosthectare))

treecover2000bins$binareaha <- round(treecover2000bins$binareaha, 0)
treecover2010bins$binareaha <- round(treecover2010bins$binareaha, 0)



treecoverbinslost20012009 <- ggplot(treecover2000bins, aes(x = bins, y = binareaha)) + 
geom_bar(stat="identity")+ 
scale_y_continuous(breaks=c(0, 200, 400, 600, 800, 1000, 1200, 1400, 1600, 1800, 2000)) +
xlab("% TREE COVER 2000") + ylab("AREA LOST IN HECTARES") + 
geom_text(aes(label = binareaha, x = bins, y = binareaha), position = position_dodge(width = 0.8), vjust = -0.2) +
ggtitle("AREA OF TREE COVER LOST 2001-2009")+
annotate("text", x = "21-30", y = 1000, label = "Total area lost ~ 3000 Ha", face="bold", size=6) +
theme(
	 axis.title.x=element_text(face="bold", size=13),
     axis.title.y=element_text(face="bold", size=13),
     axis.text.x=element_text(color="black", size =10), 
     axis.text.y=element_text(color="black", size =10),
     legend.title=element_blank(),
     legend.text=element_blank(),
     legend.position="top",
     plot.title=element_text(face="bold", size = 18, hjust=0.5, colour = "black"))




treecoverbinslost20102017 <- ggplot(treecover2010bins, aes(x = bins, y = binareaha)) + 
geom_bar(stat="identity") + 
scale_y_continuous(breaks=c(0, 200, 400, 600, 800, 1000, 1200, 1400, 1600, 1800, 2000)) +
xlab("% TREE COVER 2010") + ylab("AREA LOST IN HECTARES") + 
geom_text(aes(label = binareaha, x = bins, y = binareaha), position = position_dodge(width = 0.8), vjust = -0.2) +
ggtitle("AREA OF TREE COVER LOST 2010-2017") +
annotate("text", x = "21-30", y = 1000, label = "Total area lost ~ 1900 Ha", face="bold", size=6) +
theme(
	 axis.title.x=element_text(face="bold", size=13),
     axis.title.y=element_text(face="bold", size=13),
     axis.text.x=element_text(color="black", size =10), 
     axis.text.y=element_text(color="black", size =10),
     legend.title=element_blank(),
     legend.text=element_blank(),
     legend.position="top",
     plot.title=element_text(face="bold", size = 18, hjust=0.5, colour = "black"))


p <- grid.arrange(treecoverbinslost20012009, treecoverbinslost20102017)

ggsave(filename="tree-cover-percentage-area-lost-2001-2017.jpeg", plot=p, height=21, width=29, unit='cm')

## SLIGHTLY DIFFERENT PLOTS OF THE PAPUM RF ANALYSIS

## count number of pixels of a certain value in a raster

## create a variable with a all packages named
packages <- c("raster", "gridExtra","data.table", "rgdal", "rgeos", "maptools","dplyr", "ncdf4", "ggplot2", "tibble", "wesanderson")

## call all packages using lapply
lapply(packages, library,character.only=TRUE)

loss20012009count <- read.csv("2001-2009-lost-pixels-tree-cover-cell-count-area.csv")
loss20102017count <- read.csv("2010-2017-lost-pixels-tree-cover-cell-count-area.csv")

loss20012009count$treecover2000 <- as.numeric(loss20012009count$treecover2000)
loss20102017count$treecover2010 <- as.numeric(loss20102017count$treecover2010)


treecover2000values <- loss20012009count %>% group_by(treecover2000) %>% summarise(treecoverareaha = sum(arealosthectare))
treecover2010values <- loss20102017count %>% group_by(treecover2010) %>% summarise(treecoverareaha = sum(arealosthectare))


treecover2000values$year <- "2001-2009"
treecover2010values$year <- "2010-2017"

names(treecover2010values) <- c("treecover","treecoverareaha","year")
names(treecover2000values) <- c("treecover","treecoverareaha","year")

treecover20002010ha <- bind_rows(treecover2000values, treecover2010values)


ggplot(treecover20002010ha, aes(x=treecover, y=treecoverareaha, colour=year)) + 
geom_step(stat='bin', bins=10)) + 
scale_x_continuous(breaks=c(0,10,20,30,40,50,60,70,80,90,100)) + 
scale_y_continuous(breaks=c(50,100,150,200,250,300,350,400,450,500)) + 
scale_colour_manual(values=c("#ba3a00", "#000000"))



##  CUMULATIVE PLOT OF AREA LOST

arealost <- read.csv("papum-rf-buffer-area-lost-2001-2017.csv")

arealostyears <- ggplot(data=arealost, aes(x = lossyear, y = cumsum(Area.ha))) + 
geom_area(stat="identity", fill="#bababa") +
scale_x_continuous(breaks=c(2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017)) + 
scale_y_continuous(breaks=c(0,200,400,600,800,1000,1200,1400,1600,1800,2000,2200,2400,2600,2800,3000)) +
xlab("LOSS YEAR") + ylab("AREA IN HECTARES") + 
geom_text(aes(label=round(cumsum(Area.ha)), vjust=-0.25)) +
ggtitle("CUMULATIVE TREE COVER AREA LOST 2001 - 2017") +
theme_classic() +
theme(
	 axis.title.x=element_text(face="bold", size=13),
     axis.title.y=element_text(face="bold", size=13),
     axis.text.x=element_text(color="black", size =10), 
     axis.text.y=element_text(color="black", size =10),
     legend.title=element_blank(),
     legend.text=element_blank(),
     legend.position="top",
     plot.title=element_text(face="bold", size = 18, hjust=0.5, colour = "black"))

cumarealostyears <- ggplot(data=arealost, aes(x = lossyear, y = cumsum(Area.sq.km))) + 
geom_area(stat="identity", fill="#545454") +
scale_x_continuous(breaks=c(2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017)) + 
scale_y_continuous(breaks=c(0, 5, 10, 15, 20, 25, 30)) +
xlab("LOSS YEAR") + ylab("AREA IN SQAURE KILOMETERS") + 
#geom_text(aes(label=round(cumsum(Area.sq.km)), vjust=-0.25)) + 
geom_label(aes(label=round(cumsum(Area.sq.km), 1), vjust=-0.25), label.size = 0.15, family="serif") +
#ggtitle("CUMULATIVE TREE COVER AREA LOST 2001 - 2017") +
theme_classic() +
theme(
      axis.title.x=element_text(face="bold", size=13, family="serif"),
     axis.title.y=element_text(face="bold", size=13, family="serif"),
     axis.text.x=element_text(color="black", size =10, family="serif"), 
     axis.text.y=element_text(color="black", size =10, family="serif"),
     legend.title=element_blank(),
     legend.text=element_blank(),
     legend.position="top",
     plot.title=element_text(face="bold", size = 18, hjust=0.5, colour = "black"))

ggsave("PRF-2001-2017-cumulative-loss-areafill-simple.jpeg", plot=cumarealostyears, height=10, width=10)

arealostyears <- ggplot(data=arealost, aes(x = lossyear, y = Area.sq.km)) + 
geom_bar(stat="identity") +
scale_x_continuous(breaks=c(2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017)) + 
scale_y_continuous(breaks=c(0, 1, 2, 3, 4, 5, 6,7, 8, 9, 10)) +
xlab("LOSS YEAR") + ylab("AREA IN SQAURE KILOMETERS") + 
geom_label(aes(label=round(Area.sq.km, 1), vjust=-0.25),  label.size = 0.15,  family="serif") +
#ggtitle("TREE COVER AREA LOST 2001 - 2017") +
theme_classic() +
theme(
      axis.title.x=element_text(face="bold", size=13, family="serif"),
     axis.title.y=element_text(face="bold", size=13, family="serif"),
     axis.text.x=element_text(color="black", size =10, family="serif"), 
     axis.text.y=element_text(color="black", size =10, family="serif"),
     legend.title=element_blank(),
     legend.text=element_blank(),
     legend.position="top",
     plot.title=element_text(face="bold", size = 18, hjust=0.5, colour = "black"))

ggsave("PRF-2001-2017-loss-simple.jpeg", plot=arealostyears, height=10, width=10)


## PLOT TO COMPARE BOTH TREE COVER BASELINES

treecover2000count <- read.csv("2000-tree-cover-cell-counts-area.csv")
treecover2010count <- read.csv("2010-tree-cover-cell-counts-area.csv")

treecover2000count$treecover2000 <- as.numeric(treecover2000count$treecover2000)
treecover2010count$treecover2010 <- as.numeric(treecover2010count$treecover2010)

treecover2000count$bins <- cut(treecover2000count$treecover2000, breaks=c(0,10,20,30,40,50,60,70,80,90,100), labels=c("0-10","11-20","21-30","31-40","41-50","51-60","61-70","71-80","81-90","91-100"))
treecover2010count$bins <- cut(treecover2010count$treecover2010, breaks=c(0,10,20,30,40,50,60,70,80,90,100), labels=c("0-10","11-20","21-30","31-40","41-50","51-60","61-70","71-80","81-90","91-100"))


treecover2000bins <- treecover2000count %>% group_by(bins) %>% summarise(binareaha = sum(area.ha))
treecover2010bins <- treecover2010count %>% group_by(bins) %>% summarise(binareaha = sum(area.ha))

treecover2000bins$binareaha <- round(treecover2000bins$binareaha, 0)
treecover2010bins$binareaha <- round(treecover2010bins$binareaha, 0)



treecover2000plot <-  ggplot(treecover2000bins, aes(x = bins, y = binareaha)) + 
geom_bar(stat="identity") + 
scale_y_continuous(breaks=c(0,1000,5000,10000,15000,20000,25000,30000,35000,40000,45000,50000)) +
xlab("% TREE COVER 2000") + ylab("AREA IN HECTARES") + 
ggtitle("TREE COVER AREA 2000 BASELINE") +
geom_text(aes(label = binareaha, x = bins, y = binareaha), position = position_dodge(width = 0.8), vjust = -0.2) +
annotate("text", x = "11-20", y = 35000, label = "Total area ~ 70000 ha", face="bold", size=6) +
theme(
	 axis.title.x=element_text(face="bold", size=13),
     axis.title.y=element_text(face="bold", size=13),
     axis.text.x=element_text(color="black", size =10), 
     axis.text.y=element_text(color="black", size =10),
     legend.title=element_blank(),
     legend.text=element_blank(),
     legend.position="top",
     plot.title=element_text(face="bold", size = 18, hjust=0.5, colour = "black"))

treecover2010plot <-  ggplot(treecover2010bins, aes(x = bins, y = binareaha)) + 
geom_bar(stat="identity") + 
scale_y_continuous(breaks=c(0,1000,5000,10000,15000,20000,25000,30000,35000,40000,45000,50000)) +
xlab("% TREE COVER 2010") + ylab("AREA IN HECTARES") + 
ggtitle("TREE COVER AREA 2010 BASELINE") +
geom_text(aes(label = binareaha, x = bins, y = binareaha), position = position_dodge(width = 0.8), vjust = -0.2) +
annotate("text", x = "11-20", y = 35000, label = "Total area ~ 70000 ha", face="bold", size=6) +
theme(
      axis.title.x=element_text(face="bold", size=13),
     axis.title.y=element_text(face="bold", size=13),
     axis.text.x=element_text(color="black", size =10), 
     axis.text.y=element_text(color="black", size =10),
     legend.title=element_blank(),
     legend.text=element_blank(),
     legend.position="top",
     plot.title=element_text(face="bold", size = 18, hjust=0.5, colour = "black"))


treecoverplots <- grid.arrange(treecover2000plot, treecover2010plot)

ggsave(filename="2000-2010-tree-cover-baseline.jpeg", plot=treecoverplots, width=29,height=21,unit="cm")



treecover20002010areas <- left_join(treecover2000bins, treecover2010bins, by="bins")

names(treecover20002010areas) <- c('treecover', '2001-2009', '2010-2017')

jnk <- melt(treecover20002010areas, id.vars="treecover")

names(jnk) <- c('treecover', 'YEAR', 'value')

treecoverchange <- ggplot(jnk, aes(treecover, value,fill=YEAR)) + 
geom_bar(stat="identity", position=position_dodge(width=0.8)) + 
scale_fill_manual(values=wes_palette(n=2, name="Chevalier1")) +
geom_text(aes(label=value,x=treecover,y=value), position = position_dodge(width = 0.8), vjust = -0.6) +
scale_y_continuous(breaks=c(0, 250, 500, 750, 1000,5000,10000,15000,20000,25000,30000,35000,40000,45000,50000)) +
xlab("% TREE COVER") + ylab("AREA IN HECTARES") + 
ggtitle("% TREE COVER CLASSES LOST") +
theme(
	 axis.title.x=element_text(face="bold", size=13),
     axis.title.y=element_text(face="bold", size=13),
     axis.text.x=element_text(color="black", size =10), 
     axis.text.y=element_text(color="black", size =10),
     legend.title=element_blank(),
     legend.text=element_text(color="black", size =10),
     legend.position="top",
     plot.title=element_text(face="bold", size = 18, hjust=0.5, colour = "black"))


ggsave(filename='tree-cover-change-all-years.jpeg', plot=treecoverchange, height=21, width=30,unit='cm')


## crop and mask using each polygon in the list
cropitmaskit <- function(x,y,...){
	s <- readOGR(x)
	execrop <- crop(y, extent(s))
	exemask <- mask(execrop, s)

	## paste name of each layer and DONT FORGET TO MENTION WHICH LAYER IS BEING USED
	filepath <- paste(paste0(unlist(strsplit(x, split='m'))[1]), "elevation", sep="")
	writeRaster(exemask, filename = filepath, format="GTiff", overwrite=TRUE)
}

rasterstats <- function(x,...){
	rastmean <- as.data.frame(cellStats(x, mean, na.rm=TRUE))
	colnames(rastmean)[[1]] <- "value"
	rastsd <- as.data.frame(cellStats(x, sd, na.rm=TRUE))
	colnames(rastsd)[[1]] <- "value"
	rastquantiles <- as.data.frame(quantile(x))
	colnames(rastquantiles)[[1]] <- "value"
	rasterstatistics <- rbind(rastmean, rastquantiles, rastsd)
	rasterstatistics <- rownames_to_column(rasterstatistics, "statistic")
	rasterstatistics[1,1] <- "mean"
	rasterstatistics[7,1] <- "sd"
	return(rasterstatistics)
	}

jnk <- read.csv("elevation-treecover/tree-cover-2000-2010-elevation-stats.csv")

treecoverboxplot <-	ggplot(jnk, aes(x=factor(elevation, levels=c("0-200","200-400","400-600","600-800","800-1000","1000-1200","1200-1400","1400-1600","1600-1800","1800-2000","2000-2200")), ymin=min, ymax=max, lower=q25, middle=median, upper=q75)) + 
	geom_boxplot(stat='identity', aes(fill=factor(year))) +
	ylab("% TREE COVER") +
	xlab("ELEVATION ZONE IN METERS") +
	ggtitle("PERCENTAGE TREE COVER IN DIFFERENT ELEVATION ZONES") +
	scale_y_continuous(breaks=c(0, 10,20,30, 40, 50, 60, 70, 80, 90, 100)) +
	scale_fill_manual(values=wes_palette(n=2, name="Chevalier1")) +
theme_bw() +
theme(
	 axis.title.x=element_text(face="bold", size=13),
     axis.title.y=element_text(face="bold", size=13),
     axis.text.x=element_text(color="black", size =10), 
     axis.text.y=element_text(color="black", size =10),
     legend.title=element_blank(),
     legend.text=element_text(color="black", size =10),
     legend.position="top",
     plot.title=element_text(face="bold", size = 18, hjust=0.5, colour = "black"))



elev <- raster()

lost1stdecade <- readOGR()

lostelev1stdecade <- extract(elev, lost1stdecade)

class(lostelev1stdecade)

jnk1 <- lapply(lostelev1stdecade, summary)

elevloss <- read.csv("elevation-loss-year-stats.csv")


elevlossboxplot <-	ggplot(elevloss, aes(x=year, ymin=min, ymax=max, lower=q25, middle=median, upper=q75)) + 
	geom_boxplot(stat='identity') +
	ylab("ELEVATION IN METERS") +
	xlab("YEAR") +
	geom_point(aes(y=mean), size=1, color="red") +
	ggtitle("FOREST LOSS BY ELEVATION AND YEAR") +
	scale_x_continuous(breaks=c(2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016)) +
	scale_y_continuous(breaks=c(0,200,400,600,800,1000,1200,1400,1600,1800,2000)) +
	##scale_fill_manual(values=wes_palette(n=2, name="Chevalier1")) +
theme_bw() +
theme(
	 axis.title.x=element_text(face="bold", size=13),
     axis.title.y=element_text(face="bold", size=13),
     axis.text.x=element_text(color="black", size =10), jnk <- arealost[!grepl("TOTAL", arealost$class),]

jnk$percentage <- jnk$percentage/100

jnk$year <- as.factor(jnk$year)

     axis.text.y=element_text(color="black", size =10),
     legend.title=element_blank(),
     legend.text=element_text(color="black", size =10),
     legend.position="top",
     plot.title=element_text(face="bold", size = 18, hjust=0.5, colour = "black"))




## SCRIPTS FOR LOSS AREA CALCULATION WITHIN NEST SITES

setwd("/home/csheth/documents/work/remote-sensing/papum-reserve-forest/analysis/rapid-eye-classification/forest-non-forest/nest-sites")

arealost <- read.csv("cell-count-2010-2019.csv")

jnk <- arealost[!grepl("TOTAL", arealost$class),]


jnk$percentage <- jnk$percentage/100

# ## this swtiches the year to a 1 to 19
# jnk$year <- as.factor(jnk$year)

deforestyears <- jnk[jnk$year %in% c(2011,2012,2013,2014,2015,2016,2017,2018,2019),]

deforestyears$year <- as.numeric(deforestyears$year)

forestloss <- ggplot(na.omit(deforestyears), aes(x=year, y=area, fill=class, label=round(area, 1))) + 
geom_bar(stat="identity", position="dodge") + 
scale_fill_manual(values=c("#007f00","#e3d618","#828654")) +
scale_y_continuous(breaks=c(0, 5, 10, 15, 20, 25,30,35,40)) + 
geom_segment(aes(y=0,yend=40,x=-Inf,xend=-Inf)) +
geom_segment(aes(x=0.5,xend=9.5,y=-Inf,yend=-Inf)) +
ylab("AREA IN SQUARE KILOMETERS") +
xlab("YEAR") +
#geom_text(size = 3, position = position_dodge(width=1), hjust= 0, vjust=5, colour="black", fontface = "bold", family="TT Times New Roman") +
theme_classic() +


theme(
      axis.title.x=element_text(face="bold", size=13, family="TT Times New Roman"),
     axis.title.y=element_text(face="bold", size=13, family="TT Times New Roman"),
     axis.text.x=element_text(face="bold", size =10, family="TT Times New Roman"), 
     axis.text.y=element_text(face="bold",  size =10, family="TT Times New Roman"),
     legend.title=element_blank(),
     legend.text=element_text(color="black", size =10, face="bold", family="TT Times New Roman"),
     legend.justification=c(1.2,1),
     legend.position=c(1,1),
     plot.title=element_text(face="bold", size = 18, hjust=0.5, colour = "black"),
     axis.line=element_blank()
     )

ggsave(filename='forest-change-2011-to-2019.jpeg', plot=forestloss, height=16, width=21,unit='cm')


arealost <- read.csv("cell-count-2010-2019.csv")
jnk2 <- arealost[arealost$class %in% "FOREST",]

## removing 2010
forestarea <- jnk2[-1,]


cumarealostyears <- ggplot(data=forestarea, aes(x = year, y = area)) + 
geom_line(stat="identity") +
scale_x_continuous(breaks=c(2011,2012,2013,2014,2015,2016,2017,2018, 2019)) + 
scale_y_continuous(breaks=c(0, 20,22,24,26,28,30,32,34,36,38,40)) +
xlab("YEAR") + ylab("FOREST AREA IN SQUARE KILOMETERS") + 
#geom_text(aes(label=round(cumsum(Area.sq.km)), vjust=-0.25)) + 
geom_label(aes(label=round(area, 1), vjust=-0.25), label.size = 0.10, family="TT Times New Roman") +     
#ggtitle("CUMULATIVE TREE COVER AREA LOST 2001 - 2017") +
theme_classic() +
theme(
      axis.title.x=element_text(face="bold", size=13, family="TT Times New Roman"),
     axis.title.y=element_text(face="bold", size=13, family="TT Times New Roman"),
     axis.text.x=element_text(face="bold", size =10, family="TT Times New Roman"), 
     axis.text.y=element_text(face="bold", size =10, family="TT Times New Roman"),
     legend.title=element_blank(),
     legend.text=element_blank(),
     legend.position="top",
     plot.title=element_text(face="bold", size = 18, hjust=0.5, colour = "black"))



## LINE PLOT OF ALL CLASSES AND ALL YEARS

forestlossline <- ggplot(deforestyears, aes(x=year, y=area, group=class, label=round(area, 1))) + 
geom_line(aes(colour=class)) +
geom_point(aes(fill=class, shape=class), size = 2) +
scale_colour_manual(values=c("#007f00","#e3d618","#828654")) + 
scale_fill_manual(values=c("#007f00","#e3d618","#828654")) +
scale_y_continuous(breaks=c(0, 5, 10, 15, 20, 25,30,35,40)) + 
scale_x_continuous(breaks=c(2011,2012,2013,2014,2015,2016,2017,2018, 2019)) + 
geom_segment(aes(y=0,yend=40,x=-Inf,xend=-Inf)) +
geom_segment(aes(x=2011,xend=2019,y=-Inf,yend=-Inf)) +
ylab("AREA IN SQUARE KILOMETERS") +
xlab("YEAR") +
theme_classic() +
     theme(
      axis.title.x=element_text(face="bold", size=13, family="TT Times New Roman"),
     axis.title.y=element_text(face="bold", size=13, family="TT Times New Roman"),
     axis.text.x=element_text(face="bold", size =10, family="TT Times New Roman"), 
     axis.text.y=element_text(face="bold",  size =10, family="TT Times New Roman"),
     legend.title=element_blank(),
     legend.text=element_text(color="black", size =10, face="bold", family="TT Times New Roman"),
     legend.justification=c(1.2,1),
     legend.position=c(1,1),
     plot.title=element_text(face="bold", size = 18, hjust=0.5, colour = "black"),
     axis.line=element_blank()
     )

  #   ggsave(filename='forest-change-2011-to-2019.jpeg', plot=forestloss, height=16, width=21,unit='cm')

#finalplot <- grid.arrange(cumarealostyears, forestlossline, nrow=2)

ggsave(filename='figure-ii.jpeg', plot=forestlossline, height=16, width=21,unit='cm', dpi=600)


ggplot(data=prf, aes(x = year, y = loss_area_ha)) + 
geom_point() +
geom_line(stat="identity") +
scale_x_continuous(breaks=c(2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019)) + 
scale_y_continuous(limits=c(0,350)) +
xlab("YEAR") + ylab("LOSS AREA IN HECTARES")+
theme_classic() +
theme(
      axis.title.x=element_text(face="bold", size=13, family="TT Times New Roman"),
     axis.title.y=element_text(face="bold", size=13, family="TT Times New Roman"),
     axis.text.x=element_text(face="bold", size =10, family="TT Times New Roman"), 
     axis.text.y=element_text(face="bold", size =10, family="TT Times New Roman"),
     legend.title=element_blank(),
     legend.text=element_blank(),
     legend.position="top",
     plot.title=element_text(face="bold", size = 18, hjust=0.5, colour = "black"),
      axis.line=element_blank())

dev.new()


ggplot(data=ptr, aes(x = year, y = loss_area_ha)) + 
geom_point() +
geom_line(stat="identity") +
scale_x_continuous(breaks=c(2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019)) + 
scale_y_continuous(limits=c(0,350)) +
xlab("YEAR") + ylab("LOSS AREA IN HECTARES")+
theme_classic() +
theme(
      axis.title.x=element_text(face="bold", size=13, family="TT Times New Roman"),
     axis.title.y=element_text(face="bold", size=13, family="TT Times New Roman"),
     axis.text.x=element_text(face="bold", size =10, family="TT Times New Roman"), 
     axis.text.y=element_text(face="bold", size =10, family="TT Times New Roman"),
     legend.title=element_blank(),
     legend.text=element_blank(),
     legend.position="top",
     plot.title=element_text(face="bold", size = 18, hjust=0.5, colour = "black"),
      axis.line=element_blank())


fsi <- read.csv("FSI-data.csv")

fsiplot <- ggplot(data=fsi, aes(x = as.factor(Year), y = forest_cover)) + 
geom_bar(stat="identity", colour="black", fill = "#999999", width = 0.6) +
scale_x_discrete(labels=c(2003,2005,2009,2011,2013,2015,2017)) + 
coord_cartesian(ylim=c(66500,67800)) +
scale_y_continuous(breaks = c(66500, 67000,67500,67800)) +
xlab("ASSESSMENT YEAR") + ylab("LOSS AREA IN SQUARE KILOMETRES")+
geom_segment(aes(y=66000,yend=67800,x=-Inf,xend=-Inf)) +
geom_segment(aes(x=0.5,xend=7.5,y=-Inf,yend=-Inf)) +
theme_classic() +
theme(
      axis.title.x=element_text(face="bold", size=13,colour = "black", family="TT Times New Roman"),
     axis.title.y=element_text(face="bold", size=13, colour = "black", family="TT Times New Roman"),
     axis.text.x=element_text(face="bold", size =10, colour = "black", family="TT Times New Roman"), 
     axis.text.y=element_text(face="bold", size =10, colour = "black", family="TT Times New Roman"),
     legend.title=element_blank(),
     legend.text=element_blank(),
     plot.title=element_text(face="bold", size = 18, hjust=0.5, colour = "black"),
      axis.line=element_blank())

ggsave(filename='supplementary-figure-i.jpeg', plot=fsiplot, height=16, width=21,unit='cm', dpi=600)

library(reshape2)
library(ggplot2)

nestoccupancy <- read.csv("Nest-occupancy-graph.csv")

colnames(nestoccupancy) <- c("year", "Great hornbill and Wreathed hornbill", "Oriental pied hornbill")

nestmelt <- melt(nestoccupancy, id.vars="year")





nestplot <- ggplot(data=nestmelt, aes(x = as.factor(year), y = value, fill=variable)) + 
geom_bar(stat="identity", position=position_dodge(width=0.7), colour="black", width = 0.7, size=0.4) +
scale_fill_manual(values=c("#999999", "#1d1d1d")) +
scale_x_discrete(labels=c(2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019)) + 
coord_cartesian(ylim=c(0, 100)) +
scale_y_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100)) +
xlab("YEAR") + ylab("NEST OCCUPANCY") +
geom_segment(aes(y=0,yend=100,x=-Inf,xend=-Inf)) +
geom_segment(aes(x=0.5,xend=8.5,y=-Inf,yend=-Inf)) +
# annotate(geom = "text", x = 1.2, y = 68, label = "#") +
# annotate(geom = "text", x = 1.8, y = 51, label = "#") +
# annotate(geom = "text", x = 3.8, y = 42.6, label = "#") +
# annotate(geom = "text", x = 4.8, y = 59.3, label = "#") +
# annotate(geom = "text", x = 5.2, y = 66, label = "#") +
# annotate(geom = "text", x = 5.8, y = 59.3, label = "#") +
# annotate(geom = "text", x = 6.2, y = 71.5, label = "#") +
# annotate(geom = "text", x = 6.8, y = 37.3, label = "#") +
# annotate(geom = "text", x = 7.2, y = 70, label = "#") +
# annotate(geom = "text", x = 8.2, y = 70.5, label = "#") +
theme_classic() +
theme(
      axis.title.x=element_text(face="bold", size=13,colour = "black", family="TT Times New Roman"),
     axis.title.y=element_text(face="bold", size=13, colour = "black", family="TT Times New Roman"),
     axis.text.x=element_text(face="bold", size =10, colour = "black", family="TT Times New Roman"), 
     axis.text.y=element_text(face="bold", size =10, colour = "black", family="TT Times New Roman"),
     legend.text=element_text(color="black", size =10, face="bold", family="TT Times New Roman"),
     legend.title=element_blank(),
     legend.justification=c(1.2,1),
     legend.position=c(1,1),
     legend.key.size = unit(0.8, "cm"),
     legend.key = element_rect(size=1, fill = "white", colour = "white"),
     plot.title=element_text(face="bold", size = 18, hjust=0.5, colour = "black"),
      axis.line=element_blank())

ggsave(filename='supplementary-figure-ii.jpeg', plot=nestplot, height=16, width=21,unit='cm', dpi=600)

