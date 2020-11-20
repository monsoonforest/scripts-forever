## clean polygons and intersect

library(cleangeo)
library(raster)
library(rgdal)

x <- readOGR("")

y <- readOGR("")
 
x1 <- clgeo_Clean(x, errors.only = NULL, strategy = "POLYGONATION", verbose = FALSE)

intersectit <- raster::intersect(x1, y)

writeOGR(intersectit, dsn="intersect.GeoJSON", layer="intersectit", driver="GeoJSON")

