## list the rasters in the directory
listofrasters <- list.files(pattern = ".tif$$")

## function to count cells in each raster class
cellcount <- function(x,...){
  
  ## call each item of the list as a raster OR create a raster of each item in the list
  r <- raster(paste(x))
  
  ## j,k,m,n gives the cell counts for each class of raster r
  j <- sum(r[]==2)
  k <- sum(r[]==3)
  m <- sum(r[]==4)
  n <- sum(r[]==5)
  
  ## concatenate the data from j,k,m,n
  datacounts <- c(j,k,m,n)
  
  ## set dimnames this is then modified as a column with row values of the raster classes that were counted above
  dimnames <- list(rasterclass = c(2,3,4,5))
  
  ## create a matrix of the same
  mat <- matrix(datacounts, ncol=1, nrow=4, dimnames=dimnames)
  
  ##create a data frame of the cell counts
  countdf <-  as.data.frame(as.table(mat))
  
  ## drop the useless column
  countdf <- subset(countdf, select=-Var2)
}

## apply the function to your list of raster names
countlist <- lapply(listofrasters, cellcount)

## rename each list entry to the same raster name for which cell counts were calculated
  for (i in 1:length(countlist)){
    colnames(countlist[[i]])[1] <- paste(listofrasters[i])  
  }
  