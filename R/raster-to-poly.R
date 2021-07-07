## Raster to polygons conversion in R


setwd("/home/chintan/documents/work/remote_sensing/analysis/dibang-landcover/")

library(raster)
library(maptools)

x <- raster("file.tif")

e <- extent(x)

r <- x > -Inf
# or alternatively
# r <- reclassify(x, cbind(-Inf, Inf, 1))

# convert to polygons (you need to have package 'rgeos' installed for this to work)
pp <- rasterToPolygons(x, dissolve=TRUE)

# look at the results
plot(x)
plot(p, lwd=5, border='red', add=TRUE)
plot(pp, lwd=3, border='blue', add=TRUE)

e <- extent(x)
# coerce to a SpatialPolygons object
p <- as(e, 'SpatialPolygons') 

proj4string(counties.mp) <- "+proj=longlat +datum=WGS84"
 
# write out a new shapefile (but without .prj); the more general
# writeSpatialShape would produce equivalent output
writePolyShape(counties.mp, "counties-maptools")