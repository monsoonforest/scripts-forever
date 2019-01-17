library(raster)		# loading rasters, mask etc.
library(ggplot2)	# map plots
library(lattice)	# histograms etc.
library(rgdal)		# loading ShapePoly etc.
library(hexbin)		# hxagonal scatter plots.
library(geosphere)		# what does this package do?
library(rasterVis)		# for the level plots (i can see some fog in the forest)


# Round up the value of the highest elevation (the peak)	
# to the nearest hundred
roundUp <- function(x,to=100)
{
  to*(x%/%to + as.logical(x%%to))
}

hist_plot <- function(i) 
{
  z <- maxValue(i)

  d <- roundUp(z)

  bins <- d/100
  
  histogram(i, maxpixels = ncell(i), xlab = 'elevation in m',
   				ylab = 'number of pixels', breaks = bins, 
            		scales=list(x=list(at=c(seq(0, d, by=100)), 
            			limits=c(0,d), tck=c(-1, 0))), 
            				col="dodgerblue", type ="count", title = )
}

dev.print(jpeg, file="filename.jpg", width=1800, height=1200) # getwd() save an open graphic to disk