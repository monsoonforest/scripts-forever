## scatter PLOTS FOR ANDAMANS

##LIBRARIES
library(ggplot2)
library(dplyr)
library(hrbrthemes)

## READ IN THE DATAFRAME AS A TABLE
alex_volume <- tbl_df(read.csv("Alexandria_volume_2013-2017.csv"))

## REMOVE THE COLUMN YEAR
alex_volume <- alx_volume[, !(colnames(alex_volume) %in% "year")]

## CREATE A NEW DATAFRAME WITH CENSUS NUMBER MATCHING THE YEAR
alex_census_year <- data.frame("census" = 1:5, "year" = c(2013, 2014, 2015, 2016, 2017))

## LEFT JOIN ALEXANDRIA TREE VOLUME DATA WITH THE YEARS BY CENSUS
alex_volume <- left_join(alex_volume, alex_census_year, by="census")

## RENAME COLUMS
colnames(alex_volume) <- c("census", "species", "volume", "year")

## GET TOAL VOLUME OF ALL SPECIES
alex_volume_species_total <- alex_volume %>% group_by(species) %>% summarize(total_volume = sum(volume))

## GET TOTAL VOLUME OF SPECIES BY YEAR
alex_volume_species_yearly_total <- alex_volume %>% group_by(species, year)  %>% summarize(total_volume = sum(volume))


alex_volume_trees_per_census <- alex_volume %>% group_by(year, species) %>% summarise(count= n())





rtld_volume <- tbl_df(read.csv("Rutland_volume_2012-2017.csv"))

## REMOVE THE COLUMN YEAR
rtld_volume <- rtld_volume[, !(colnames(rtld_volume) %in% "year")]

## CREATE A NEW DATAFRAME WITH CENSUS NUMBER MATCHING THE YEAR
rtld_census_year <- data.frame("census" = 1:6, "year" = c(2012, 2013, 2014, 2015, 2016, 2017))

## LEFT JOIN rtldANDRIA TREE VOLUME DATA WITH THE YEARS BY CENSUS
rtld_volume <- left_join(rtld_volume, rtld_census_year, by="census")

## RENAME COLUMS
colnames(rtld_volume) <- c("census", "species", "volume", "year")

## GET TOAL VOLUME OF ALL SPECIES
rtld_volume_species_total <- rtld_volume %>% group_by(species) %>% summarize(total_volume = sum(volume))

## GET TOTAL VOLUME OF SPECIES BY YEAR
rtld_volume_species_yearly_total <- rtld_volume %>% group_by(species, year)  %>% summarize(total_volume = sum(volume))

write.csv(rtld_volume_species_yearly_total, file="rutland_volume_species_yearly_total.csv")


rtld_volume_trees_per_census <- rtld_volume %>% group_by(year, species) %>% summarise(count= n())




x <- list(
  title = "YEAR",
  range=c(2013,2014,2015,2016,2017), 
  siz=20)

y <- list(
  title = "VOLUME IN cm<sup>3</sup>",
size=20
  )


p <- plot_ly(data=alex_volume_table, x=~year, y=~volume, color = ~species,  type = 'scatter', mode='lines+markers',
        marker = list(size = 12,  line = list(color = 'rgba(0, 0, 0, .4)', width = 1)))%>%
  layout( title =  "ALEXANDRIA TREE VOLUME 2013 - 2017" , xaxis = x, yaxis = y)    

yaxe <- c(50, 100, 200, 300, 400, 500, 600, 800, 1000, 1200, 1400, 1600, 1800, 2000)

ptedalaxe <- c(1.5, 1.6, 1.7)

smallaxe <- c(10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46)

 alex_plot <- ggplot( alex_volume, aes(x=year, y=volume, group=species, colour=species)) +
    geom_line(alpha=0.8) +
    geom_point(size=3, alpha=0.3) +
    ggtitle("ALEXANDRIA ISLAND TREE VOLUME 2013 - 2017") +
    xlab("YEAR") + ylab(bquote('VOLUME IN '*CM^3*'')) + scale_y_continuous(labels = paste0(yaxe, "K"), breaks = 10^3 * yaxe) +
    theme_ipsum_tw(axis_title_size = 12, axis_title_face="bold", plot_title_size=16)

 


 rtld_volume_sub <- rtld_volume[!grepl("PTEDAL", rtld_volume$species),]

 rtld_volume_sub <- rtld_volume_sub[!grepl("CANEUP", rtld_volume_sub$species),]

 rtld_volume_sub <- rtld_volume_sub[!grepl("DILAND", rtld_volume_sub$species),]




   rtld_plot <- ggplot(rtld_volume_sub, aes(x=year, y=volume, group=species, colour=species)) +
    geom_line(alpha=0.8) +
    geom_point(size=6, alpha=0.3) +
    theme_ipsum_tw(axis_title_size = 12, axis_title_face="bold", plot_title_size = 16) +
    ggtitle("RUTLAND ISLAND TREE VOLUME 2012 - 2017") +
    xlab("YEAR") + ylab(bquote('VOLUME IN '*CM^3*'')) + scale_y_continuous(labels = paste0(yaxe, "K"), breaks = 10^3 * yaxe)


ptedal_vol <- filter(rtld_volume, species=="PTEDAL")

     

ptedal_plot <-  ggplot(ptedal_vol, aes(x=year, y=volume, group=species, colour=species)) +
    geom_line(alpha=0.8) +
    geom_point(size=6, alpha=0.3) +
    theme_ipsum_tw(axis_title_size = 8, axis_title_face="bold", plot_title_size = 14) +
    ggtitle("RUTLAND ISLAND TREE VOLUME 2012 - 2017") +
    xlab("YEAR") + ylab(bquote('VOLUME IN '*CM^3*'')) + scale_y_continuous( labels = paste0(ptedalaxe, "M"), breaks = 10^6 * ptedalaxe)



small_trees_vol <- filter(rtld_volume, species == "CANEUP" | species == "DILAND")

 small_trees_plot <-  ggplot(small_trees_vol, aes(x=year, y=volume, group=species, colour=species)) +
    geom_line() +
    geom_point(size=6, alpha=0.3) +
    theme_ipsum_tw(axis_title_size = 8, axis_title_face="bold", plot_title_size = 14) +
    ggtitle("RUTLAND ISLAND TREE VOLUME 2012 - 2017") +
    xlab("YEAR") + ylab(bquote('VOLUME IN '*CM^3*'')) + scale_y_continuous(breaks = c(10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46))





    ## LOLIPOP PLOT TO SHOW CHANGE IN SPECIES VOLUMES 2013 - 2017

yaxe <- c(-30, 0, -50, 100, 200, 250)
yaxe <- c(-30, 0, 100, 200, 300, 400, 500, 600, 800, 1000, 1200, 1400, 1600, 1800, 2000)


alex_plot_volume_change <- ggplot(alex_volume_change, aes(x=species, y=volume_change)) + 
		geom_segment(aes(x=species, xend=species, y=1, yend=volume_change), color='grey', size = 3) + 
		geom_point(color="orange", size=4) + 
		theme_ipsum_tw(axis_title_size = 10, axis_title_face="bold", plot_title_size = 14) +
	labs( x = "SPECIES",y = bquote('VOLUME CHANGE IN '*CM^3*''), title = "ALEXANDRIA ISLAND", subtitle = "TREE VOLUME CHANGE 2013 - 2017") +
		scale_y_continuous( labels = paste0(yaxe, "K"), breaks = 10^3 * yaxe)


## Scatter and line plot showing change in volume for each species each year

		 alex_species_volume_per_year <- ggplot( alex_volume_species_yearly_total, aes(x=year, y=total_volume, group=species, colour=species)) +
    geom_line(alpha=0.8) +
    geom_point(size=3, alpha=0.3) +
   theme_ipsum_tw(axis_title_size = 10, axis_title_face="bold", plot_title_size = 14) +
	labs( x = "SPECIES",y = bquote('VOLUME CHANGE IN '*CM^3*''), title = "ALEXANDRIA ISLAND", subtitle = "TREE VOLUME CHANGE 2013 - 2017") + 
	scale_y_continuous(labels = paste0(yaxe, "K"), breaks = 10^3 * yaxe) +
    theme_ipsum_tw(axis_title_size = 12, axis_title_face="bold", plot_title_size=16)



## LOLIPOP PLOT TO SHOW CHANGE IN SPECIES VOLUMES 2013 - 2017

yaxe <- c(-10, 0, 10, 50, 100, 150)

rtld_volume_change <- tbl_df(read.csv("rutland_volume_change.csv"))

rtld_plot_volume_change <- ggplot(rtld_volume_change, aes(x=species, y=volume_change)) + 
		geom_segment(aes(x=species, xend=species, y=1, yend=volume_change), color='grey', size = 3) + 
		geom_point(color="orange", size=4) + 
		theme_ipsum_tw(axis_title_size = 10, axis_title_face="bold", plot_title_size = 14) +
	labs( x = "SPECIES",y = bquote('VOLUME CHANGE IN '*CM^3*''), title = "RUTLAND ISLAND", subtitle = "TREE VOLUME CHANGE 2012 - 2017") +
		scale_y_continuous( labels = paste0(yaxe, "K"), breaks = 10^3 * yaxe)





## Scatter and line plot showing change in volume for each species each year

rtld_volume_species_yearly_total <- rtld_volume_species_yearly_total[!grepl("PTEDAL", rtld_volume_species_yearly_total$species),]


yaxe <- c(-30, 0, 100, 200, 300, 400, 500, 600, 800, 1000, 1200, 1400, 1600, 1800, 2000)


		rtld_species_volume_per_year <- ggplot( rtld_volume_species_yearly_total, aes(x=year, y=total_volume, group=species, colour=species)) +
    geom_line(alpha=0.8) +
    geom_point(size=3, alpha=0.3) +
   theme_ipsum_tw(axis_title_size = 10, axis_title_face="bold", plot_title_size = 14) +
	labs( x = "SPECIES",y = bquote('VOLUME CHANGE IN '*CM^3*''), title = "RUTLAND ISLAND", subtitle = "TREE VOLUME CHANGE 2012 - 2017") + 
	scale_y_continuous(labels = paste0(yaxe, "K"), breaks = 10^3 * yaxe) +
    theme_ipsum_tw(axis_title_size = 12, axis_title_face="bold", plot_title_size=16)



