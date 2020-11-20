tifs <- list.files(pattern = "\\.tif$$", recursive = FALSE)


for(i in 1:length(tifs)){

r <- raster(tifs[i])

name <- paste0(strsplit(basename(filename(r)), "[.]")[[1]][1], ".nc")

writeRaster(r, name, format="CDF")
}


var_names <- c('precipitation-mm')


for (var_name in var_names) {

  # Create raster stack

 ncffiles <- list.files(pattern = "\\.nc$$", recursive = FALSE)

  x <- stack(ncffiles)

  # Name each layer

  writeRaster(x = x, 
              filename = paste0(var_name, '_out.nc'),
              overwrite = TRUE, 
              format = 'CDF')
}

