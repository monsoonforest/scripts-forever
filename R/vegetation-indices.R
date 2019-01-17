LANDSAT8
NIR  = B5
RED = B4
BLUE = B2

EVI = G * ((NIR - RED)/(NIR + (C1 * RED) - (C2 * BLUE) + L))
For the standard MODIS EVI product, G= 2.5, L = 1, C1 = 6, and C2 = 7.5.

EVI <- function(BLUE, RED, NIR, ...) {
	2.5 * ((NIR - RED)/(NIR + (6 * RED) - (7.5 * BLUE) + 1))
}

data <- data.frame(x, trace_0, trace_1, trace_2)

p <- plot_ly(data, x = ~x, y = ~trace_0, name = 'trace 0', type = 'scatter', mode = 'lines') %>%
  add_trace(y = ~trace_1, name = 'trace 1', mode = 'lines+markers') %>%
  add_trace(y = ~trace_2, name = 'trace 2', mode = 'markers')


##plot EVI and NDVi vs. elevation in Pakke

setwd("home/csheth/documents/work/remote-sensing/data/landsat8/LC81360412015325LGN00/qgis-dos/")

## Load packages
packages <- c("raster", "plotly", "broom", "gridExtra", "rgdal", "lattice", "dplyr", "ggplot2", "reshape2", "gtable", "grid")
lapply(X = packages, FUN = library, character.only=TRUE)

list.files()

##This will list files that match the wildcard .* ... .* which is RT and the file ending with .tif \\.tif$
rasters <- list.files(pattern=".*RT.*\\.tif$")

##EVI function based on above
EVI <- function(BLUE, RED, NIR, ...) {
	2.5 * ((NIR - RED)/(NIR + (6 * RED) - (7.5 * BLUE) + 1))
}
##remove bands which are not required
rastname <- rasters[-c(1,2,10,11)]

##create a raster stack
imgstack <- stack(rastname)	

##boundary file of pakke in utm46
pakkebound <- readOGR("/home/csheth/documents/work/remote-sensing/arunachal/AP-digitization/Digitization/Arunachal_Shapefiles/Protected_Area_Shapes/Pakke_Tiger_Reserve/pakke-boundary-corrected-csheth2017-utm46.shp")

##create a stack of the images within the bounds of pakke
pakkejnk <- crop(imgstack, extent(pakkebound))
pakkeimgstack <- mask(pakkejnk, pakkebound)

##subset the bands for the EVI calculation
eviblue <- pakkeimgstack[[2]]
evired <- pakkeimgstack[[4]]
evinir <- pakkeimgstack[[5]]

##Calculate the EVI
pakkeEVI <- EVI(eviblue, evired, evinir) 

## plot the 432 image stack
dev.new()
plotRGB(pakkeimgstack, 4,3,2, stretch='lin')

##on a new plot device plot the EVI
dev.new()
plot(pakkeEVI)

## DEM for comparing the EVI and Elevn
pakkedem <- raster("/home/csheth/documents/work/remote-sensing/data/landsat8/LC81360412015325LGN00/qgis-dos/pakke-dem-utm46.tif")

## plot the DEM with terrain colours
plot(pakkedem, col = topo.colors(20))

utm <- "+proj=utm +zone=46 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"

##Create the DEM for Pakke in DecDeg
##pakkedemjnk <- crop(dem, extent(pakkebounddec))
##pakkedem <- mask(pakkedemjnk, pakkebounddec)

## project it into UTM using utm vector, keeping res as 30
##pakkedemutm <- projectRaster(pakkedem, crs=utm, res=30)

## Create 50k random spatial points
randmlocs <- spsample(pakkebound, n=50000, type='random')

##plots both pakke boundary and random locations
plot(pakkebound)
points(randmlocs, cex=0.1)

## create a data frame of the random locations
randmlocsdf <- data.frame(randmlocs)

		head(randmlocsdf)
##		    	 x       y
##		1 469950.2 2992805
##		2 487908.6 2997505
##		3 472478.4 2998160
##		4 468855.9 2998012
##		5 485822.6 3004256
##		6 469200.5 2998164

## Set an ID column for each random location
randmlocsdf$ID <- seq.int(nrow(randmlocsdf))

		head(randmlocsdf)
##				 x       y      ID
##		1 469950.2 2992805  1
##		2 487908.6 2997505  2
##		3 472478.4 2998160  3
##		4 468855.9 2998012  4
##		5 485822.6 3004256  5
##		6 469200.5 2998164  6

## Extract the DEM elevation data to the random points list
randmlocselevn <- extract(pakkedem, randmlocs, method="simple")

## Create a data frame of the data
randmlocselevndf <- data.frame(randmlocselevn)

		head(randmlocselevndf)
##			randmlocselevn
##		1              285
##		2             1093
##		3              461
##		4              508
##		5             1616
##		6              769

## Create a raster brick of the Slope and aspect layers
slopeaspbrick <- terrain(pakkedem, opt=c('slope', 'aspect'), unit='degrees')

	slopeaspbrick
##	class       : RasterBrick 
##	dimensions  : 1128, 1778, 2005584, 2  (nrow, ncol, ncell, nlayers)
##	resolution  : 28.14931, 28.14931  (x, y)
##	extent      : 460764.2, 510813.7, 2979485, 3011237  (xmin, xmax, ymin, ymax)
##	coord. ref. : +proj=utm +zone=46 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 
##	data source : in memory
##	names       :     slope,    aspect 
##	min values  :         0,         0 
##	max values  :  73.51684, 360.00000 

## Create a data.frame of the extracted terrain data at each of the random points.
data <- data.frame(coordinates(randmlocs), randmlocsdf$ID, extract(slopeaspbrick, randmlocs))

		head(data)
##		         x       y randmlocsdf.ID      slope    aspect
##		1 469950.2 2992805              1 16.7266329 304.15969
##		2 487908.6 2997505              2  0.7195932 225.00000
##		3 472478.4 2998160              3 42.3208370 125.47272
##		4 468855.9 2998012              4 30.2287005 255.43424
##		5 485822.6 3004256              5 31.3533716  46.18119
##		6 469200.5 2998164              6 29.4886283 285.01836

## Do the same for the EVI and DEM data rasters
datadem <- data.frame(coordinates(randmlocs), randmlocsdf$ID, extract(pakkedem, randmlocs))
dataEVI <- data.frame(coordinates(randmlocs), randmlocsdf$ID, extract(pakkeEVI, randmlocs))

		head(datadem)
##		         x       y ranlocsdf.ID extract.pakkedem..ranlocs.
##		1 469950.2 2992805            1                        285
##		2 487908.6 2997505            2                       1093
##		3 472478.4 2998160            3                        461
##		4 468855.9 2998012            4                        508
##		5 485822.6 3004256            5                       1616
##		6 469200.5 2998164            6                        769
		head(dataEVI)
##		         x       y ranlocsdf.ID extract.pakkeEVI..ranlocs.
##		1 469950.2 2992805            1                  0.5751707
##		2 487908.6 2997505            2                  0.3024059
##		3 472478.4 2998160            3                  0.6378933
##		4 468855.9 2998012            4                  0.2909276
###		5 485822.6 3004256            5                  0.3698372
##		6 469200.5 2998164            6                  0.2634048

## Rename the columns properly
names(data) <- c("x", "y", "ID", "slope", "aspect")
names(datadem) <- c("x", "y", "ID", "Elevn")
names(dataEVI) <- c("x", "y", "ID", "EVI")

## Merge only the terrain dataset
terraindata <- merge(x=data, y=datadem[,c("ID", "Elevn")], by="ID")

		head(terraindata)
##		  ID        x       y      slope    aspect Elevn
##		1  1 469950.2 2992805 16.7266329 304.15969   285
##		2  2 487908.6 2997505  0.7195932 225.00000  1093
##		3  3 472478.4 2998160 42.3208370 125.47272   461
##		4  4 468855.9 2998012 30.2287005 255.43424   508
##		5  5 485822.6 3004256 31.3533716  46.18119  1616
##		6  6 469200.5 2998164 29.4886283 285.01836   769

## merge the EVi data to the terrain dataset
eviterraindata <- merge(x=terraindata, y=dataEVI[,c("ID", "EVI")], by="ID")
		head(eviterraindata)
##		         ID        x       y        slope       aspect Elevn           EVI
##		1         1 469950.2 2992805 1.672663e+01 3.041597e+02   285  0.5751706668
##		2         2 487908.6 2997505 7.195932e-01 2.250000e+02  1093  0.3024059060
##		3         3 472478.4 2998160 4.232084e+01 1.254727e+02   461  0.6378933095
##		4         4 468855.9 2998012 3.022870e+01 2.554342e+02   508  0.2909276270
##		5         5 485822.6 3004256 3.135337e+01 4.618119e+01  1616  0.3698372372
##		6         6 469200.5 2998164 2.948863e+01 2.850184e+02   769  0.2634047586


## OMIT ALL NA VALUES
eviterraindata <- na.omit(eviterraindata)

nrow(eviterraindata)

## DOUBLE Y PLOTS 

"
## PLOT the datasets
p1 <- ggplot(eviterraindata, aes(Elevn, EVI)) + geom_smooth(color="green") + theme_bw() + scale_y_continuous( name= "Enhanced Vegetation Index")
p2 <- ggplot(eviterraindata, aes(Elevn, aspect)) + geom_smooth(color="blue") + scale_y_continuous(name="aspect") +theme_bw() %+replace% theme(panel.background = element_rect(fill=NA))

# extract gtable
g1 <- ggplot_gtable(ggplot_build(p1))
g2 <- ggplot_gtable(ggplot_build(p2))

# overlap the panel of 2nd plot on that of 1st plot
pp <- c(subset(g1$layout, name == "panel", se = t:r))
g <- gtable_add_grob(g1, g2$grobs[[which(g2$layout$name == "panel")]], pp$t, 
    pp$l, pp$b, pp$l)

# axis tweaks
ia <- which(g2$layout$name == "axis-l")
ga <- g2$grobs[[ia]]
ax <- ga$children[[2]]
ax$widths <- rev(ax$widths)
ax$grobs <- rev(ax$grobs)
ax$grobs[[1]]$x <- ax$grobs[[1]]$x - unit(1, "npc") + unit(0.15, "cm")
g <- gtable_add_cols(g, g2$widths[g2$layout[ia, ]$l], length(g$widths) - 1)
g <- gtable_add_grob(g, ax, pp$t, length(g$widths) - 1, pp$b)

# draw it
grid.draw(g)


##METHOD 2

ay <- list( tickfont = list(color ="red"), overlaying = "y", side = "right", title = "slope")

e <- loess(EVI ~ Elevn, data = eviterraindata)
s <- loess(slope ~ Elevn, data = eviterraindata)


 p <- plot_ly(eviterraindata, x = ~Elevn) %>%
 add_lines(y = ~fitted(loess(EVI ~ Elevn)), name="EVI", line=list(shape="spline")) %>%
 add_lines(y = ~fitted(loess(slope ~ Elevn)), name="slope", yaxis="y2", line=list(shape="spline")) %>%
 layout(
     title = "EVI and Slope vs. Elevation", yaxis2 = ay,
     xaxis = list(title="Elevation in meters")
   )

 add_ribbons(data = augment(e),
              ymin = ~.fitted - 1.96 * .se.fit,
              ymax = ~.fitted + 1.96 * .se.fit,
              line = list(color = 'rgba(7, 164, 181, 0.05)'),
              fillcolor = 'rgba(7, 164, 181, 0.2)',
              name = "Standard Error") %>%
 add_ribbons(data = augment(s),
              ymin = ~.fitted - 1.96 * .se.fit,
              ymax = ~.fitted + 1.96 * .se.fit,
              line = list(color = 'rgba(255, 179, 0, 0.05)'),
              fillcolor = 'rgba(7, 164, 181, 0.2)',
              name = "Standard Error") %>%


## Issues with the plotting two curves on the same y axis
## problem is i can't tell if the points being plotted for slope and EVI are
## the same locations. Meaning from the plot there is no way to tell if
## the slope value and EVI value are from the same corresponding elevation point.
## to do that the data will have to be transposed into long, to check the values
## of the 'dependent variables' vs. Elevation. Or simply put the same location 
## needs to be checked for all variable.
## double plots look great like in the Amazon paper but it has to accurately 
## represent the values on the ground?....
 "


elevevi <- ggplot(eviterraindata, aes(Elevn, EVI)) + 
            geom_point(size=0.09, alpha=0.08, color="red") + 
            geom_smooth() + 
            scale_x_discrete(limits=c(200, 600,1000, 1400, 1800, 2000))

elevslope <- ggplot(eviterraindata, aes(Elevn, slope)) + 
              geom_point(size=0.09, alpha=0.08, color="red") + 
              geom_smooth(color="green") +
              scale_x_discrete(limits=c(200, 600,1000, 1400, 1800, 2000))

elevaspect <- ggplot(eviterraindata, aes(Elevn, aspect)) + 
                geom_point(size=0.09, alpha=0.08, color="red") + 
                  geom_smooth(color="purple") +
                  scale_x_discrete(limits=c(200, 600,1000, 1400, 1800, 2000))

slopeevi <- ggplot(eviterraindata, aes(slope, EVI)) + 
              geom_point(size=0.09, alpha=0.08, color="red") + 
              geom_smooth(color="gold2")

aspectevi <- ggplot(eviterraindata, aes(aspect, EVI)) + 
              geom_point(size=0.09, alpha=0.08, color="red") + 
                geom_smooth(color="slateblue4")

grid.arrange(elevevi, elevslope, elevaspect, slopeevi, aspectevi, nrow=3, ncol=2)
