library(raster)
library(rgdal)
library(tidyr)
library(dplyr)
library(stringr)
library(ggplot2)
library(reshape2)
library(ggExtra)
library(hrbrthemes)

l <- list.files(pattern = ".*transposed*\\.csv$$", recursive = FALSE)


mutate_it <- function(x,...)

{
		snow_cover <- read.csv(x)

		snow_cover <- snow_cover %>%  
		 			mutate(coordinates = str_extract_all(.geo, "\\(?[0-9.]+\\)?")) %>% 
		 			separate(coordinates, into = c("longitude", "latitude"), sep=",") %>% 
		 			mutate(longitude=str_replace_all(longitude, c('"' = '', '\\\\' = '', '[:alpha:]' = '', '\\(' = '', '\\)' = '', '\\,' = '')))%>% 
		 			mutate(latitude=str_replace_all(latitude, c('"' = '', '\\\\' = '', '[:alpha:]' = '', '\\(' = '', '\\)' = '', '\\,' = '')))%>% 
		 			mutate(longitude=as.numeric(longitude))%>% 
		 			mutate(latitude=as.numeric(latitude))


		snow_cover[snow_cover == -9999] <- NA

		## rename the columns with X
				for ( col in 1:ncol(snow_cover))
				{
				    colnames(snow_cover)[col] <-  sub("X", "", colnames(snow_cover)[col])
				}

		## DROP COLUMNS
		drops <- c("system.index", ".geo")
		snow_cover_select <- snow_cover[ , !(names(snow_cover) %in% drops)]

		## mean basin snow cover
		##snow_cover_mean <- snow_cover_select %>% summarise_all(mean, na.rm=TRUE)

		## standard deviation of basin snow cover
		##snow_cover_sd <- snow_cover_select %>% summarise_all(sd, na.rm=TRUE)

		## melt both dataframes
		# snow_cover_mean_melt <- melt(snow_cover_mean)
		# snow_cover_sd_melt <- melt(snow_cover_sd)


		## bind both stats as rows for each day = each column
		# snow_cover_stats <- cbind(snow_cover_mean_melt, snow_cover_sd_melt)
		
		## change col names
		# colnames(snow_cover_stats) <- c("date", "mean_basin_snow_cover", "date1", "sd_basin_snow_cover")

		## drop one column
		# drops <- "date1"
		# snow_cover_stats <- snow_cover_stats[ , !(names(snow_cover_stats) %in% drops)]
			
}

## apply the function on all dataframes
snow_cover_all_years_list <- lapply(l, mutate_it)

## bind columns so that every column is a day
snow_cover_all_years <- tibble(bind_cols(snow_cover_all_years_list))

## drop the duplicate columns
drops <- c("featureID...366", "longitude...367", "latitude...368", "featureID...734", "longitude...735", "latitude...736", "featureID...1102", "longitude...1103", "latitude...1104", "featureID...1462", "longitude...1463", "latitude...1464", "featureID...1830", "longitude...1831", "latitude...1832")
snow_cover_all_years <- snow_cover_all_years[ , !(names(snow_cover_all_years) %in% drops)]

## rename the columns
colnames(snow_cover_all_years)[2183] <- "featureID"
colnames(snow_cover_all_years)[2184] <- "longitude"
colnames(snow_cover_all_years)[2185] <- "latitude"

## to get the number of columns for which data is NA
##ncol(snow_cover[, which(colMeans(!is.na(snow_cover)) > 0.9)])

## new drops for the snow_cover_long format that will be used to make the join with the elevation data
drops <- c("longitude", "latitude")

## drop the columns
snow_cover_without_lat_long <- snow_cover_all_years[ , !(names(snow_cover_all_years) %in% drops)]

## create a new dataframe in long format
snow_cover_long <- snow_cover_without_lat_long %>%
  gather(date, value, -featureID) %>% 
  mutate(date = as.Date(date, format = "%Y_%m_%d"))


elevation <- raster("output_srtm.tif")

coordinates(snow_cover_all_years) = ~longitude+latitude
proj4string(snow_cover_all_years) = CRS("+init=epsg:4326")

data <- as.data.frame(snow_cover_all_years[,1:2183], raster::extract(elevation, snow_cover_all_years))


for ( col in 1:ncol(data))
				{
				    colnames(data)[col] <-  sub("X", "", colnames(data)[col])
				}

colnames(data)[2186] <- "elevation"

## get featureID and elevation from the data df
elevn_feature <- select(data, featureID, elevation)

## join the feature ID to the elevation dataset
elevn_snow_cover <- left_join(snow_cover_long, elevn_feature, by="featureID")

## separate the dataframe into year, month, day
##elevn_snow_cover_year <- separate(elevn_snow_cover, date, into = c('year', 'month', 'day'), remove=FALSE)

## omit all NA
elevn_snow_cover_na_rm <- na.omit(elevn_snow_cover)

elevn_snow_cover_na_rm$elevation <- as.numeric(elevn_snow_cover_na_rm$elevation)

elevn_snow_cover_na_rm$group = cut(elevn_snow_cover_na_rm$elevation, c(2800,3150,3500,3580,4200,4550,4900,5250,5600,5950,6300,6550))

levels(elevn_snow_cover_na_rm$group) = c("2800-3150","3150-3500","3500-3850", "3850-4200","4200-4550","4550-4900","4900-5250","5250-5600","5600-5950","5950-6300","6300-6650")

rm(snow_cover_without_lat_long,snow_cover_long,snow_cover_all_years,data,elevation,elevn_snow_cover, elevn_feature, snow_cover_all_years_list)

gc()



## plot all months
p2018 <- ggplot(elevn_snow_cover_2018, aes(x = group, y = value)) + 
		geom_violin(scale="area") + 
		facet_wrap(~month) +
		xlab("ELEVATION BINS") +
		ylab("SNOW COVER %") +
		theme(axis.text.x = element_text(angle = 60, hjust = 1))

ggsave("2018-snow_cover_elevation.jpeg", plot=p2018, device="jpeg", width=60,height=40,units="cm", dpi=300)


p <- ggplot(elevn_snow_cover_na_rm, aes(date, value, color=group)) + 
geom_point(size=1, alpha=0.3) + scale_colour_viridis_d(option = "inferno") + 
guides(colour = guide_legend(override.aes = list(alpha = 1, size=2))) + 
theme_ft_rc(axis_title_size = 14, axis_title_face="bold", plot_title_size = 18, axis_title_just = "ct") + ## THEME CONTROLS
theme(
	axis.ticks.x = element_line(colour = 'grey80', size = 0.3), 
	axis.ticks.length.x = unit(2, "mm"), 
	axis.ticks.y = element_line(colour = 'grey80', size = 0.3), 
	axis.ticks.length.y = unit(1, "mm"), 
	legend.position="right"
		) + facet_wrap(~year)


ggsave("test_snow_cover_plot.jpeg", plot=p, device="jpeg", width=29, height=21, units="cm", dpi=300)


p <- plot_ly(elevn_snow_cover_na_rm, x = ~date, y = ~value, z = ~group,
               marker = list(color = ~group, colorscale = c('#FFE1A1', '#683531'), showscale = TRUE))



plot3d( 
  x=elevn_snow_cover_na_rm$`date`, y=elevn_snow_cover_na_rm$`value`, z=elevn_snow_cover_na_rm$`group`, 
  type = 's', 
  radius = 0.01,
  xlab="Date", ylab="Snow Cover %", zlab="Elevation bin")


