
## fire list is the list of rasters for which you need to extract data
firelist <- list.files(pattern = ".*.*\\.tif$$", recursive = F)

poly <- readShapePoly("")

zonalfunction <- function(x,...){
r <- raster(paste(x))

## sum will give the sum of pixels of the raster r contained by the polygon poly
ex <- extract(r, poly, fun=sum, na.rm=TRUE, df=TRUE)
}

l <- lapply(firelist, zonalfunction)

df <- as.data.frame(l)

#write to a CSV file
write.csv(df, file = "burned-area-counts.csv")


