## CODE MODIFIED FROM https://www.r-bloggers.com/2020/10/climate-animation-of-maximum-temperatures/
## CLIMATE ANIMATIONS

## LOAD LIBRARIES
library(rnaturalearthdata)
library(ncdf4)
library(raster)
library(tidyverse)
library(ggplot2)
library(lubridate)
library(ggthemes)
library(sf)
library(rnaturalearth)
library(extrafont)
library(showtext)
library(RColorBrewer)
library(gifski)	


d18Olist <- list.files(pattern=paste("O",".*c.asc",sep=""), all.files=FALSE, recursive=TRUE)

d18Orasters <- lapply(d18Olist, raster)

prec <- brick(d18Orasters)

## for orissa
e <- as(extent(81, 87, 17, 23), 'SpatialPolygons')
## CREATE A VARIABLE OF THE GEOGRAPHICAL ROI 
#e <- as(extent(86, 98, 20, 30), 'SpatialPolygons')

## SET THE CRS TO WHAT WAS IN THE BRICK
crs(e) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

## CROP THE BRICK TO THE EXTENTS
odisha_prec <- crop(prec, e)

## CONVERT THE NC FILE TO A DATAFRAME
odisha_prec_monthly <- as.data.frame(odisha_prec, xy = TRUE, na.rm = TRUE)

## SET NAMES TO VARIABLES IN THE DF
odisha_prec_monthly <- set_names(odisha_prec_monthly, c("lon", "lat", str_c("M", 1:12)))

states <- st_read("/home/csheth/documents/work/gis/India-shapefile-kashmir/india_states.shp")

## CROP THE BORDERS TO THE ROI
map <- st_crop(states, xmin = 81, xmax = 87, ymin = 17, ymax = 23) 

# dev.new()
# plot(map)

## CREATE A VARIBALE OF CLASS "character" TO HOLD VALUES OF THE DATES IN THE DATAFRAME THE DOY IS FROM 120 - 180 FOR THE YEAR 1981
## SO CREATE CHARACTERS FROM DOY 120-180 IN THE YEAR 1981. %d IS date and %B is MONTH 
##lab <- as_date(1:12, "1998-01-01") %>% format("%d %B")
lab <- c("JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC")

## VARIABLE WITH A LIST OF BREAKS FOR THE CATEGORICALLY DIVIDE THE DATASET
##ct <- c(0, 40, 80, 120, 160, 200, 240, 280, 320)
ct <- c(-12,-11,-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,0,1)

## CATEGORICALLY DIVIDE THE DATASET
odisha_prec_monthly_cat <- mutate_at(odisha_prec_monthly, 3:14, cut, breaks = ct)

## CREATE A TIME STEP FROM M1 TO M12
time_step <- str_c("M", 1:12)

## NAME THE FILES USING THE STRINGS
files <- str_c("M", str_pad(1:12, 3, "left", "0"), ".png")

col_spec <- colorRampPalette(rev(brewer.pal(14, "Spectral")))

## EXPORT PLOTS FOR EACH month FROM M1 TO M12
for(i in 1:12){
 ggplot(odisha_prec_monthly_cat) + 
         geom_raster(aes_string("lon", "lat", fill = time_step[i])) +
         geom_sf(data = map,
                colour = "black", size = 0.2, alpha=0) +
  coord_sf(expand = FALSE) +
  scale_fill_manual(values = col_spec(14), drop = FALSE) +
  guides(fill = guide_colorsteps(barwidth = 30, 
                                 barheight = 0.5,
                                 title.position = "right",
                                 title.vjust = .1)) +
   theme_void() +
   theme(legend.position = "top",
      legend.justification = 1,
      plot.caption = element_text(family = "Montserrat", 
                                  margin = margin(b = 5, t = 10, unit = "pt")),                
      plot.title = element_text(family = "Montserrat", 
                                size = 16, face = "bold", 
                                margin = margin(b = 2, t = 5, unit = "pt")),
     legend.text = element_text(family = "Montserrat"),
     plot.subtitle = element_text(family = "Montserrat", 
                                  size = 13, 
                                  margin = margin(b = 10, t = 5, unit = "pt"))) +
   labs(title = "monthly d18O", 
     subtitle = lab[i], 
     fill = "dD")
  
  ggsave(files[i], width = 8.28, height = 7.33, type = "cairo")
  
}

## SAVE IT AS A GIF
##gifski(files, "prec-d18O-monthly.gif", width = 800, height = 700, loop = TRUE, delay = 0.5)

pnglist = list.files(pattern=paste0("M",".*.png",sep=""))
rl = lapply(pnglist, png::readPNG)
gl = lapply(rl, grid::rasterGrob)
p <- gridExtra::grid.arrange(grobs=gl)

ggsave(plot=p,filename="d18O-odisha-iaea.jpeg",width = 21, height = 29, type = "cairo", device="jpeg")