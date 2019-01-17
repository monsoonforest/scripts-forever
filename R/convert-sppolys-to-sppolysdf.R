## converting SpatialPolygons to SpatialPolygonsDataFrame and then saving to disk


seasiaroi1 <- as(seasiaroi, "SpatialPolygonsDataFrame")


writeOGR(obj=seasiaroi1, dsn="analysis/savanna-ratnam-book/maps/shapefiles/", layer="seasia-ratnambook", driver="ESRI Shapefile")