## CODE TO MOSAIC RASTERS IN R

## list the files recursively in R
list <- list.files(pattern=".*2017.*.*Analytic.*\\.tif$$", recursive=T)

## stack the raster as there are spectral bands included
rasters <- lapply(list, stack)

## name the function to use in areas of overlapping rasters
rasters$fun <- mean

## mosaic the raster
mos <- do.call(raster::mosaic, rasters)

## write the raster mosaic
writeRaster(mos, "2017-mosaic.tif", format="GTiff", overwrite=TRUE)
