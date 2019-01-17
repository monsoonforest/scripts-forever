## clean polygons and intersect

library(cleangeo)
library(raster)

x <- shapefile("")

y <- shapefile("")
 
 x1 <- clgeo_Clean(x, errors.only = NULL, strategy = "POLYGONATION",
+ verbose = FALSE)

intersectit <- raster::intersect(x1, y)