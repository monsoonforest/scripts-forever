# Sentinel 2 Atmospheric Correction in rgee Google Earth Engine in R
# https://github.com/samsammurphy/gee-atmcorr-S2


library(raster)
library(sp)
library(rgee)
library(jsonlite)
library(leaflet)
library(leafem)
library(tidyverse)
library(leaflet)
library(jsonlite)
library(leafem)
library(ggplot2)
library(sf)
library(mapview)
library(remotes)
library(protolite)
library(jqr)
library(geojsonio)
library(V8)
library(satellite)
library(reticulate)
library(lubridate)

ee_Initialize()

## SOMTHING WRONG WITH GEOMETRY COULD NOT FIX WITH CLI gjf --version
# SBVCR <- st_read("/home/csheth/documents/work/remote-sensing/arunachal/SBVCR/singchung-village-area_fixed.GEOJSON") %>%
#   st_geometry %>%
#   sf_as_ee %>%
#   ee$FeatureCollection$geometry() %>%
#   ee$Geometry$bounds()

# time and place
# Define the time and place that you are looking for.
date <- ee$Date('2018-05-12')
geom <- ee$Geometry$Point(92.4597, 27.1567)


rectangle <- ee$Geometry$Rectangle(92.46966842946372,27.138655578734635,92.6495695525106,27.296195017517935)

# define a collection
col <- ee$
  ImageCollection('COPERNICUS/S2')$
  select("B2", "B3", "B4")


start <- ee$Date("2018-05-11")
end <- ee$Date("2018-05-13")

# filter the collection by date
filter <- col$filterBounds(rectangle)$filterDate(start,end)

# just take the first image
S2 <- filter$first()

Map$setCenter(92.4597, 27.2001, 11)

Map$addLayer(S2,list(
bands=c('B4', 'B3', 'B2'), min=0, max=2500, gamma=c(1.3, 1.3,
1.3)), '2018-05-12')

# metadata
S2info <- S2$getInfo()['properties']
scene_date <- ee_get_date_img(S2)
