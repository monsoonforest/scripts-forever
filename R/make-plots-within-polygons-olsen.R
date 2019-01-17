## PROGRAM TO GET NUTRIENT/RASTER RANGES WITHIN MULTIPLE POLYGONS

## create a variable with a all packages named
packages <- c("raster", "gridExtra", "rgdal", "rgeos", "maptools","dplyr", "ncdf4", "ggplot2", "tibble", "wesanderson")

## call all packages using lapply
lapply(packages, library,character.only=TRUE)

## CLAY raster
glclay <- raster("/home/user/documents/csheth/gis-rs-work/gis/data/ISLSCP_SOILS_1DEG_1004/data/soil_clay_perc0-30_1d.asc")

## NITROGEN raster
glnitro <- raster("/home/user/documents/csheth/gis-rs-work/gis/data/ISLSCP_SOILS_1DEG_1004/data/soil_nitrogen_dens0-30_1d.asc")	

## MEAN ANNUAL PRECIPITATION RASTER

maprec <- raster("/home/user/documents/csheth/gis-rs-work/gis/data/world-clime-2.0/wc2.0_30s_bio/wc2.0_bio_30s_12.tif")

## PHOSPHOROUS DENSITY RASTER
glphos <- raster("/home/user/documents/csheth/gis-rs-work/gis/data/GLOBAL_PHOSPHORUS_DIST_MAP_1223/data/pforms_den.nc")

fire <- raster("/media/user/HDD2-Data/csheth/gis-rs/analysis/savannas/fire-merged/africa/burn-frequency/africa-merged-burnfrequency.tif")

## list of savanna polygons
savannalist <- list.files(pattern = ".*leaved.*\\.shp$$", recursive = F)

## crop and mask using each polygon in the list
cropitmaskit <- function(x,y,...){
	s <- readOGR(x)
	execrop <- crop(y, extent(s))
	exemask <- mask(execrop, s)

	## paste name of each layer and DONT FORGET TO MENTION WHICH LAYER IS BEING USED
	filepath <- paste(paste0(unlist(strsplit(x, split='\\.'))[1]), "-fire-frequency", sep="")
	writeRaster(exemask, filename = filepath, format="GTiff", overwrite=TRUE)
}

## create a list of the raster layers
clayrasterlist <- lapply(savannalist, cropitmaskit, y=glclay)

nitrorasterlist <- lapply(savannalist, cropitmaskit, y=glnitro)

maprecrasterlist <- lapply(savannalist, cropitmaskit, y=maprec)

phosrasterlist <- lapply(savannalist, cropitmaskit, y=glphos)

firerasterlist <- lapply(savannalist, cropitmaskit, y=fire)

colnames(firesummarylist[[1]])[2] <- "central.deccan.plateau.dry.deciduous.forests"
colnames(firesummarylist[[2]])[2] <- "deccan thorn scrub forests"
colnames(firesummarylist[[3]])[2] <- "east.deccan.dry.evergreen.forests"
colnames(firesummarylist[[4]])[2] <- "eastern.highlands.moist.deciduous.forests"
colnames(firesummarylist[[5]])[2] <- "malabar.coast.moist.forests"
colnames(firesummarylist[[6]])[2] <- "north.western.ghats.moist.deciduous.forests"
colnames(firesummarylist[[7]])[2] <- "north.western.ghats.montane.rain.forests"
colnames(firesummarylist[[8]])[2] <- "south.deccan.plateau.dry.deciduous.forests"
colnames(firesummarylist[[9]])[2] <- "south.western.ghats.moist.deciduous.forests"
colnames(firesummarylist[[10]])[2] <- "south.western.ghats.montane.rain.forests"



firerasterlist[[1]][firerasterlist[[1]]== 0] <- NA
firerasterlist[[2]][firerasterlist[[2]]== 0] <- NA
firerasterlist[[3]][firerasterlist[[3]]== 0] <- NA

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

claystatsummarylist <- lapply(clayrasterlist, rasterstats)

nitrostatsummarylist <- lapply(nitrorasterlist, rasterstats)

maprecstatsummarylist <- lapply(maprecrasterlist, rasterstats)

phosststatsummarylist <- lapply(phosrasterlist, rasterstats)

firestatsummarylist <- lapply(firerasterlist, rasterstats)


	colnames(claystatsummarylist[[1]])[2] <- "BROAD-LEAVED SAVANNAS"
	colnames(claystatsummarylist[[2]])[2] <- "FINE-LEAVED SAVANNAS"

colnames(nitrostatsummarylist[[1]])[2] <- "BROAD-LEAVED SAVANNAS"
	colnames(nitrostatsummarylist[[2]])[2] <- "FINE-LEAVED SAVANNAS"

colnames(maprecstatsummarylist[[1]])[2] <- "BROAD-LEAVED SAVANNAS"
	colnames(maprecstatsummarylist[[2]])[2] <- "FINE-LEAVED SAVANNAS"

colnames(phosststatsummarylist[[1]])[2] <- "BROAD-LEAVED SAVANNAS"
	colnames(phosststatsummarylist[[2]])[2] <- "FINE-LEAVED SAVANNAS"

colnames(firestatsummarylist[[1]])[2] <- "BROAD-LEAVED SAVANNAS"
	colnames(firestatsummarylist[[2]])[2] <- "FINE-LEAVED SAVANNAS"


    colnames(statsummarylist[[3]])[2] <- "MIXED-LEAVED SAVANNAS"


	claystatdf <- as.data.frame(claystatsummarylist)
	nitrostatdf <- as.data.frame(nitrostatsummarylist)
	phosstatdf <- as.data.frame(phosststatsummarylist)
	maprecstatdf <- as.data.frame(maprecstatsummarylist)
	firestatdf <- as.data.frame(firestatsummarylist)

	write.csv(t(claystatdf), file="clay-broad-fine-stats.csv")
	write.csv(t(nitrostatdf), file="nitrogen-broad-fine-stats.csv")
	write.csv(t(maprecstatdf), file="maprecipitation-broad-fine-stats.csv")
	write.csv(t(phosstatdf), file="phosphorous-broad-fine-stats.csv")
	write.csv(t(firestatdf), file="fire-broad-fine-stats.csv")



wes_palette(n=11, name="Royal1")


fireboxplot <-	ggplot(fire, aes(x=ECOREGION, ymin=min, ymax=max, lower=q25, middle=median, upper=q75), label=rownames(fire)) + 
	geom_boxplot(stat='identity', aes(fill=ECOREGION)) +
	geom_point(aes(x=ECOREGION, y=mean), shape=23, fill="blue", color="darkred", size=3) +
	ylab("NUMBER OF FIRE YEARS") +
	scale_y_continuous(breaks=c(0,1,2,3,4,6,8, 10, 12,14,16,18,20,22,24, 26, 28,30)) +
	scale_color_brewer(palette="Dark2") +
	scale_fill_manual(name="ECOREGION NAME",values = c("#8dd3c7", "#ffffb3","#bebada","#fb8072","#80b1d3","#fdb462","#b3de69","#fccde5","#d9d9d9","#bc80bd"))	+
theme_bw() +
theme(
	   axis.title.x=element_blank(),
    axis.title.y=element_text(color="black", size=9, face = "bold"),
     axis.text.x=element_blank(),  
       legend.title=element_text(color="black",size=9, face="bold"),
       legend.text=element_text(color="black",size=12, face="bold"),
         strip.text.x = element_text(face="bold", size = 10, colour = "black"))

firemeanplot <- ggplot(fire, aes(x=BURNED.AREA)) + 
	 geom_errorbar( data = fire, aes(BURNED.AREA, mean, ymin = mean - sd, ymax = mean + sd),
    colour = 'black',
    width = 0.05, linetype=1) +
	geom_point(aes(y=mean), size=2, color="black") +
	ylab("NUMBER OF FIRE YEARS 2000-2017") +
	scale_y_continuous(breaks=c(0,2, 5, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 100)) +
		scale_fill_manual(guide=FALSE,values=wes_palette(n=3, name="Royal1")) +		
theme_bw() +
theme(
		axis.title.x=element_blank(),
		axis.title.y=element_text(color="black", size=10, face="bold"),
		axis.text.x=element_text(color="black", size =10, face="bold"),  
		legend.title=element_blank(),
		legend.text=element_blank(),
		strip.text.x = element_text(face="bold", size = 10, colour = "black"),
		axis.line = element_line(colour = "black"),
		panel.grid.major = element_blank(),
		panel.grid.minor = element_blank(),
		panel.border = element_blank(),
		panel.background = element_blank())

phosboxplot <-	ggplot(phos, aes(x=Phosphorous.density, ymin=min, ymax=max, lower=q25, middle=median, upper=q75)) + 
		geom_errorbar(aes(ymin=min,ymax=max),linetype = 1,width = 0.1) +
	geom_boxplot(stat='identity', aes(fill=Phosphorous.density)) +
		ylab(bquote(bold('TOTAL SOIL PHOSPHOROUS ('*g/m^2*')'))) +
	scale_y_continuous(breaks=c(0, 200, 400, 600, 800, 1000, 1200, 1400, 1600)) +
	scale_fill_manual(guide=FALSE,values=c("darkolivegreen2", "darkolivegreen4")) +
theme_bw() +
theme(
		axis.title.x=element_blank(),
		axis.title.y=element_text(color="black", size=10, face="bold"),
		axis.text.x=element_text(color="black", size =10, face="bold"),  
		legend.title=element_blank(),
		legend.text=element_blank(),
		strip.text.x = element_text(face="bold", size = 10, colour = "black"),
		axis.line = element_line(colour = "black"),
		panel.grid.major = element_blank(),
		panel.grid.minor = element_blank(),
		panel.border = element_blank(),
		panel.background = element_blank()) ##+
	##facet_grid(. ~ title)

phosmeanplot <- ggplot(phos, aes(x=Phosphorous)) + 
	 geom_errorbar( data = phos, aes(Phosphorous, mean, ymin = mean - sd, ymax = mean + sd),
    colour = 'black',
    width = 0.05, linetype=1) +
	geom_point(aes(y=mean), size=2, color="black") +
	ylab("SOIL PHOSPHOROUS DENSITY [g/m2]") +
	scale_y_continuous(breaks=c(0, 200, 300, 400, 500, 600, 700, 800, 1000, 1200)) +
		scale_fill_manual(guide=FALSE,values=wes_palette(n=3, name="Royal1")) +		
theme_bw() +
theme(
	    axis.title.x=element_blank(),
    axis.title.y=element_blank(),
     axis.text.x=element_text(color="black", size =8),  
       legend.title=element_blank(),
    legend.text=element_blank(),
         strip.text.x = element_text(face="bold", size = 10, colour = "black")) +
	  facet_grid(. ~ title)

nitroboxplot <-	ggplot(nitro, aes(x=Nitrogen.density, ymin=min, ymax=max, lower=q25, middle=median, upper=q75)) + 
			geom_errorbar(aes(ymin=min,ymax=max),linetype = 1,width = 0.1) +
	geom_boxplot(stat='identity', aes(fill=Nitrogen.density)) +
	ylab(bquote(bold('SOIL NITROGEN DENSITY ('*g/m^2*')'))) +
	scale_y_continuous(breaks=c(0,100,200,300, 400,500, 600,700, 800)) +
	scale_fill_manual(guide=FALSE,values=c("darkolivegreen2", "darkolivegreen4")) +
theme_bw() +
theme(
		axis.title.x=element_blank(),
		axis.title.y=element_text(color="black", size=10, face="bold"),
		axis.text.x=element_text(color="black", size =10, face="bold"),  
		legend.title=element_blank(),
		legend.text=element_blank(),
		strip.text.x = element_text(face="bold", size = 10, colour = "black"),
		axis.line = element_line(colour = "black"),
		panel.grid.major = element_blank(),
		panel.grid.minor = element_blank(),
		panel.border = element_blank(),
		panel.background = element_blank()) ##+
	##facet_grid(. ~ title)

nitromeanplot <- ggplot(nitro, aes(x=Nitrogen.density)) + 
 geom_errorbar( data = nitro, aes(Nitrogen.density, mean, ymin = mean - sd, ymax = mean + sd),
    colour = 'black',
    width = 0.05, linetype=1) +
	geom_point(aes(y=mean), size=2, color="black") +
	ylab("SOIL NITEOGEN DENSITY [g/m2]") +
	scale_y_continuous(breaks=c(0, 200, 250, 300, 350, 400, 450, 500, 600, 700, 800, 900, 1000)) +
		scale_fill_manual(guide=FALSE,values=wes_palette(n=3, name="Royal1")) +
theme_bw() +
theme(axis.title.x=element_blank(),
    axis.title.y=element_blank(),
     axis.text.x=element_text(color="black", size =8),  
       legend.title=element_blank(),
    legend.text=element_blank(),
         strip.text.x = element_text(face="bold", size = 10, colour = "black")) +
	  facet_grid(. ~ title)


clayboxplot <-	ggplot(clay, aes(x=Clay., ymin=min, ymax=max, lower=q25, middle=median, upper=q75)) + 
		geom_errorbar(aes(ymin=min,ymax=max),linetype = 1,width = 0.1) +
	geom_boxplot(stat='identity', aes(fill=Clay.)) +
	ylab(bquote(bold('SOIL CLAY (%)'))) +
		scale_y_continuous(breaks=c(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60)) +
	scale_fill_manual(guide=FALSE,values=c("darkolivegreen2", "darkolivegreen4")) +
theme_bw() +
theme(
		axis.title.x=element_blank(),
		axis.title.y=element_text(color="black", size=10, face="bold"),
		axis.text.x=element_blank(),  
		legend.title=element_blank(),
		legend.text=element_blank(),
		strip.text.x = element_text(face="bold", size = 10, colour = "black"),
		axis.line = element_line(colour = "black"),
		panel.grid.major = element_blank(),
		panel.grid.minor = element_blank(),
		panel.border = element_blank(),
		panel.background = element_blank()) ##+
	##facet_grid(. ~ title)


claymeanplot <- ggplot(clay, aes(x=Clay)) + 
geom_errorbar( data = clay, aes(Clay, mean, ymin = mean - sd, ymax = mean + sd),
    colour = 'black',
    width = 0.05, linetype=1) +
	geom_point(aes(y=mean), size=2, color="black") +
	ylab("SOIL CLAY %") +
	scale_y_continuous(breaks=c(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60)) +
	scale_fill_manual(guide=FALSE,values=wes_palette(n=3, name="Royal1")) +
theme_bw() +
theme(
	    axis.title.x=element_blank(),
    axis.title.y=element_blank(),
     axis.text.x=element_text(color="black", size =8),  
       legend.title=element_blank(),
    legend.text=element_blank(),
         strip.text.x = element_text(face="bold", size = 10, colour = "black")) +
	  facet_grid(. ~ title)

mapboxplot <-	ggplot(maprec, aes(x=MAP, ymin=min, ymax=max, lower=q25, middle=median, upper=q75)) + 
		geom_errorbar(aes(ymin=min,ymax=max),linetype = 1,width = 0.1) +
	geom_boxplot(stat='identity', aes(fill=MAP)) +
	ylab(bquote(bold('MEAN ANNUAL PRECIPITATION (mm)'))) +	
	scale_y_continuous(breaks=c(0, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500)) +
	scale_fill_manual(guide=FALSE,values=c("darkolivegreen2", "darkolivegreen4")) +
	theme_bw() +
	theme(
		axis.title.x=element_blank(),
		axis.title.y=element_text(color="black", size=10, face="bold"),
		axis.text.x=element_blank(),  
		legend.title=element_blank(),
		legend.text=element_blank(),
		strip.text.x = element_text(face="bold", size = 10, colour = "black"),
		axis.line = element_line(colour = "black"),
		panel.grid.major = element_blank(),
		panel.grid.minor = element_blank(),
		panel.border = element_blank(),
		panel.background = element_blank()) ##+
	##facet_grid(. ~ title)


mapmeanplot <- ggplot(maprec, aes(x=MAP)) + 
geom_errorbar( data = maprec, aes(MAP, mean, ymin = mean - sd, ymax = mean + sd),
    colour = 'black',
    width = 0.05, linetype=1) +
	geom_point(aes(y=mean), size=2) +
	ylab("MEAN ANNUAL PRECIPITATION [mm]") +
	scale_y_continuous(breaks=c(0, 200,400, 600,  800, 1000, 1200, 1400)) +
	scale_fill_manual(guide=FALSE,values=wes_palette(n=3, name="Royal1")) +
	theme_bw() +
theme(
	    axis.title.x=element_blank(),
    axis.title.y=element_blank(),
     axis.text.x=element_text(color="black", size =8),  
       legend.title=element_blank(),
    legend.text=element_blank(),
         strip.text.x = element_text(face="bold", size = 10, colour = "black")) +
	  facet_grid(. ~ title)


meanplots <- grid.arrange(mapmeanplot, claymeanplot, nitromeanplot, phosmeanplot, nrow=2, ncol=2)

boxplots <- grid.arrange(mapboxplot, clayboxplot, nitroboxplot, phosboxplot, nrow=2, ncol=2)

ggsave(filename = "africansavannas-fine-broad-burnedarea-meanplots-sayre2013.jpeg", plot = firemeanplot, width=17, height=15, unit = "cm")
ggsave(filename = "africansavannas-fine-broad-burnedarea-boxplots-sayre2013.jpeg", plot = fireboxplot, width=17, height=15, unit = "cm")



 ##fire frequency plots
bdf <- read.csv("DF OF FIRE RASTER")

## FUNCTION TO GET 10 TO THE POWER AS SUFFIX
fancy_scientific <- function(l) {
     # turn in to character string in scientific notation
     l <- format(l, scientific = TRUE)

	 l <- gsub("0e\\+00","0",l)
     # quote the part before the exponent to keep all the digits
     l <- gsub("^(.*)e", "'\\1'e", l)
     # turn the 'e+' into plotmath format
     l <- gsub("e", "%*%10^", l)
     # return this as an expression
     parse(text=l)
}

broadsavburnfreq <- ggplot() + geom_histogram(data=bdf, aes(x=burn.freq.broad.l), binwidth=1, color="white", fill=rgb(0.2,0.7,0.1,0.4)) + 
	stat_count() + 
	scale_y_continuous(labels=fancy_scientific) + 
	xlab("BURN FREQUENCY BROAD-LEAVED SAVANNAS") + ylab("NUMBER OF PIXELS")
	ggsave(filename = "africa-broadleaved-savannas-burnfrequency.jpeg", plot = broadsavburnfreq, width=25, height=15, unit = "cm")


finesavburnplot <- ggplot() + geom_histogram(data=finedf, aes(x=burn.freq.fine.l), binwidth=1, color="white", fill=rgb(0.2,0.7,0.1,0.4)) + 
	stat_count() + 
	scale_y_continuous(labels=fancy_scientific) + 
	xlab("BURN FREQUENCY FINE-LEAVED SAVANNAS") + ylab("NUMBER OF PIXELS")
	ggsave(filename = "africa-fineleaved-savannas-burnfrequency.jpeg", plot = finesavburnplot, width=25, height=15, unit = "cm")




firemeanplot2 <- ggplot(fire, aes(x=BURNED.AREA)) + 
	 geom_errorbar( data = fire, aes(BURNED.AREA, mean, ymin = mean - sd, ymax = mean + sd),
    colour = 'black',
    width = 0.05, linetype=1) +
	geom_point(aes(y=mean), size=2, color="black") +
	ylab("PERCENTAGE OF SAVANNA BURNED") +
	scale_y_continuous(breaks=c(0, 5, 10, 15, 20, 25, 30), limits=c(0,30)) +
		scale_fill_manual(guide=FALSE,values=wes_palette(n=3, name="Royal1")) +		
theme_bw() +
theme(
		axis.title.x=element_blank(),
		axis.title.y=element_text(color="black", size=10, face="bold"),
		axis.text.x=element_text(color="black", size =10, face="bold"),  
		legend.title=element_blank(),
		legend.text=element_blank(),
		strip.text.x = element_text(face="bold", size = 10, colour = "black"),
		axis.line = element_line(colour = "black"),
		panel.grid.major = element_blank(),
		panel.grid.minor = element_blank(),
		panel.border = element_blank()) +
		##panel.background = element_blank()) +
annotate("text", x=1.5, y=30, label= "bold(AFRICA)", parse=TRUE)