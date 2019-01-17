# Within R

library(raster)		# loading rasters, mask etc.
library(ggplot2)	# map plots
library(lattice)	# histograms etc.
library(rgdal)		# loading ShapePoly etc.
library(hexbin)		# hexagonal scatter plots.
library(geosphere)		# what does this package do?
library(rasterVis)		# for the level plots (i can see some fog in the forest)
library(colorspace)		# changing the theme of the plot rasterTheme()


levelplot(imnsydemraster) # plots the dem in shades of red (low elevn) to white (high elevn) 

levelplot(demraster, contour=TRUE, margins=list(FUN='mean'))

myTheme <- rasterTheme(region=dichromat(terrain.colors(10))) # colorblind friendly plots from library(dichromat)

levelplot(twentyfivekmbufferdem, par.settings=myTheme, contour = TRUE)

dev.print(jpeg, file="filename.jpg", width=1800, height=1200) # getwd() save an open graphic to disk
