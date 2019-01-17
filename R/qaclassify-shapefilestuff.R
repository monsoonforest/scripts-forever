##########!!!!!!!!!!!! QACLASSIFY RASTER STUFF AND SOME SHAPEFILE STUFF


# Ceate a raster of Landsat 8's quality assessment bands.
qaraster <- raster("/home/chintan/documents/work/remote_sensing/data/landsat/P135R040/LC81350402015206LGN00/LC81350402015206LGN00_BQA.TIF")


# confLayers Logical. Return one layer per class classified by confidence levels, i.e. cloud:low, cloud:med, cloud:high.
	# save the file to disk with correct scene name

qaclassesfile <- function(qar)	{

		qaclasses <- classifyQA(img = qar, type =c("cloud", "cirrus", "snow", "water"), 
				confLayers =TRUE)

		writeRaster(qaclasses, filename ="/home/chintan/documents/work/remote_sensing/analysis/dibang-landcover/L8-qualasses-img/LC81350402015206LGN00_QAclasses.TIF", 
				format ="GTiff", overwrite =TRUE)

	}



# open the shapefile from which the ROI is to be worked upon. in this case its a merged shp of dibang valley districts
dibang <- readShapePoly("/home/chintan/documents/work/remote_sensing/analysis/dibang-landcover/shapefiles/dibangvalley-corrected-utm47.shp")


# set the correct projection of the shapefile
proj4string(dibang) <- "+proj=utm +zone=47 +datum=WGS84 +units=m +no_defs + ellps=WGS84 +towgs84=0,0,0"


# proj4string only rewrites the projection on file it does not reproject/warp 
#	the shapefile
dibang <- spTransform(dibang, CRS("++proj=utm +zone=47 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"))