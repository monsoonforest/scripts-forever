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

## CALL THE NC FILE AS A BRICK
prec <-  brick("precipitation-mm_out.nc")

## CREATE A VARIABLE OF THE GEOGRAPHICAL ROI 
e <- as(extent(86, 98, 20, 30), 'SpatialPolygons')

## SET THE CRS TO WHAT WAS IN THE BRICK
crs(e) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

## CROP THE BRICK TO THE EXTENTS
neindia_prec <- crop(prec, e)

## CONVERT THE NC FILE TO A DATAFRAME
neindia_prec_daily <- as.data.frame(neindia_prec, xy = TRUE, na.rm = TRUE)

## SET NAMES TO VARIABLES IN THE DF
neindia_prec_daily <- set_names(neindia_prec_daily, c("lon", "lat", str_c("D", 120:180)))

## MAP THE BORDERS
map <- ne_countries(scale = 50, returnclass = "sf") %>% st_cast("MULTILINESTRING")

## CROP THE BORDERS TO THE ROI
map <- st_crop(map, xmin = 86, xmax = 98, ymin = 20, ymax = 30) 

# dev.new()
# plot(map)

## CREATE A VARIBALE OF CLASS "character" TO HOLD VALUES OF THE DATES IN THE DATAFRAME THE DOY IS FROM 120 - 180 FOR THE YEAR 1981
## SO CREATE CHARACTERS FROM DOY 120-180 IN THE YEAR 1981. %d IS date and %B is MONTH 
lab <- as_date(120:180, "1998-01-01") %>% format("%d %B")

## VARIABLE WITH A LIST OF BREAKS FOR THE CATEGORICALLY DIVIDE THE DATASET
ct <- c(0, 40, 80, 120, 160, 200, 240, 280, 320)

## CATEGORICALLY DIVIDE THE DATASET
neindia_prec_daily_cat <- mutate_at(neindia_prec_daily, 3:63, cut, breaks = ct)

## CREATE A TIME STEP FROM D120 TO D180
time_step <- str_c("D", 120:180)

## NAME THE FILES USING THE STRINGS
files <- str_c("D", str_pad(120:180, 3, "left", "0"), ".png")

## EXPORT PLOTS FOR EACH DAY FROM D120 TO D180
for(i in 1:61){
 ggplot(neindia_prec_daily_cat) + 
         geom_raster(aes_string("lon", "lat", fill = time_step[i])) +
         geom_sf(data = map,
                 colour = "grey50", size = 0.2) +
  coord_sf(expand = FALSE) +
  scale_fill_manual(values = col_spec(9), drop = FALSE) +
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
   labs(title = "Daily precipitation from May - June 1998", 
     subtitle = lab[i], 
     fill = "mm/day")
  
  ggsave(files[i], width = 8.28, height = 7.33, type = "cairo")
  
}

## SAVE IT AS A GIF
gifski(files, "prec-daily.gif", width = 800, height = 700, loop = FALSE, delay = 0.2)

