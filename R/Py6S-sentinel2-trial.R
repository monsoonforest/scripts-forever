# Sentinel 2 Atmospheric Correction in rgee Google Earth Engine in R
# https://github.com/samsammurphy/gee-atmcorr-S2


library(raster)
library(sp)
library(rgee)
library(jsonlite)
library(leaflet)
library(leafem)
library(tidyverse)
library(leaflet)
library(jsonlite)
library(leafem)
library(ggplot2)
library(sf)
library(mapview)
library(remotes)
library(protolite)
library(jqr)
library(geojsonio)
library(V8)
library(satellite)
library(reticulate)
library(lubridate)

Py6S <- import("Py6S")
datetime <- import("datetime")
## https://github.com/samsammurphy/gee-atmcorr-S2/blob/master/bin/atmospheric.py
atmospheric <- py_run_file("/home/csheth/documents/work/from-lemon/scripts-forever/atmospheric.py")

ee_Initialize()

## SOMTHING WRONG WITH GEOMETRY COULD NOT FIX WITH CLI gjf --version
# SBVCR <- st_read("/home/csheth/documents/work/remote-sensing/arunachal/SBVCR/singchung-village-area_fixed.GEOJSON") %>%
#   st_geometry %>%
#   sf_as_ee %>%
#   ee$FeatureCollection$geometry() %>%
#   ee$Geometry$bounds()

# time and place
# Define the time and place that you are looking for.
date <- ee$Date('2018-05-12')
geom <- ee$Geometry$Point(92.4597, 27.1567)


rectangle <- ee$Geometry$Rectangle(92.46966842946372,27.138655578734635,92.6495695525106,27.296195017517935)

# define a collection
col <- ee$
  ImageCollection('COPERNICUS/S2')$
  select("B2", "B3", "B4")


start <- ee$Date("2018-05-11")
end <- ee$Date("2018-05-13")

# filter the collection by date
filter <- col$filterBounds(rectangle)$filterDate(start,end)

# just take the first image
S2 <- filter$first()

Map$setCenter(92.4597, 27.2001, 11)

Map$addLayer(S2,list(
bands=c('B4', 'B3', 'B2'), min=0, max=2500, gamma=c(1.3, 1.3,
1.3)), '2018-05-12')

# metadata
S2info <- S2$getInfo()['properties']
scene_date <- ee_get_date_img(S2)
solar_z <- S2info$properties$MEAN_SOLAR_ZENITH_ANGLE

# top of atmosphere reflectance
toa <- S2$divide(10000)

# atmospeheric constituents from the module atmospheric.py
h2o <- atmospheric$Atmospheric$water(geom, date)$getInfo()
o3 <- atmospheric$Atmospheric$ozone(geom, date)$getInfo()
aot <- atmospheric$Atmospheric$aerosol(geom, date)$getInfo()

# target altitude
SRTM  <- ee$Image('CGIAR/SRTM90_V4') # Shuttle Radar Topography mission covers *most* of the Earth
alt <- SRTM$reduceRegion(reducer = ee$Reducer$mean(),geometry = geom$centroid())$get('elevation')$getInfo()
km <- alt/1000 # i.e. Py6S uses units of kilometers


# 6S object

# The backbone of Py6S is the 6S (i.e. SixS) class. It aPredefinedWavelengthsllows you to define the various input parameters, to run the radiative transfer code and to access the outputs which are required to convert radiance to surface reflectance.
# Instantiate
s <- Py6S$SixS

# Atmospheric constituents
s$atmos_profile <- Py6S$AtmosProfile$UserWaterAndOzone(h2o,o3)
s$aero_profile <- Py6S$AeroProfile$Continental
s$aot550 <- aot

# Earth-Sun-satellite geometry
s$geometry <- Py6S$Geometry$User()
s$geometry$view_z <- 0                           # always NADIR (I think..)
s$geometry$solar_z <- solar_z                     # solar zenith angle
s$geometry$month <- month(scene_date$time_start)  # month and day used for Earth-Sun distance
s$geometry$day <-  day(scene_date$time_start)  # month and day used for Earth-Sun distance
#s$altitudes$set_sensor_satellite_level()

Py6S$Params$altitudes$Altitudes$set_sensor_satellite_level <- 100
Py6S$Params$altitudes$Altitudes$set_target_custom_altitude$altitude <- km


# Spectral Response functions

# Py6S uses the Wavelength class to handle the wavelength(s) associated with a given channel (a.k.a. waveband). This might be a single scalar value (e.g. a central wavelength) or, if known, possibly the spectral response function of the waveband. The Sentinel 2 spectral response functions are provided with Py6S (as well as those of a number of missions). For more details please see the docs or the (comment-rich) source code

## get spacecraft name so as to use the appropriate predefined wavelenths in Py6S

S2info$properties$SPACECRAFT_NAME

## define a spectral response function that returns the wavelength of the selected band
spectralResponseFunction <- function(bandname,...){
	
band_wavelength <- eval(parse(text = paste0("Py6S$Params$PredefinedWavelengths$S2B_MSI_", str_split(bandname, "B")[[1]][2])))

}



# TOA Reflectance to Radiance

# Sentinel 2 data is provided as top-of-atmosphere reflectance. Lets convert this to at-sensor radiance for the atmospheric correction.*

# *You can atmospherically corrected directly from TOA reflectance. However, I suggest radiance for a couple of reasons. Firstly, it is more intuitive.
# Instead of spherical albedo (which I suspect is more of a mathematical convenience than a physical property) you can use solar irradiance,
# transmissivity, path radiance, etc. Secondly, Py6S seems to be more geared towards converting from radiance to SR</sup>

## Converts top of atmosphere reflectance to at-sensor radiance

toa_to_rad <- function(bandname,...){

	# solar exoatmospheric spectral irradiance
	EAI <- eval(parse(text = paste0("S2info$properties$SOLAR_IRRADIANCE_", bandname)))

	solar_angle_correction <- cos(solar_z*pi/180)

	# Earth-Sun distance (from date)
	EarthSunDist <- calcEarthSunDist(date=scene_date$time_start, formula="Spencer" )

	# conversion factor
	multiplier <- EAI*solar_angle_correction/(pi*EarthSunDist^2)

    # at-sensor radiance
    rad <- toa$select(bandname)$multiply(multiplier)

return(rad)

    }



# Radiance to Surface Reflectance

# Reflected sunlight can be described as follows (wavelength dependence is implied):

# $ L = \tau\rho(E_{dir} + E_{dif})/\pi + L_p$

# where L is at-sensor radiance, $\tau$ is transmissivity, $\rho$ is surface reflectance, $E_{dir}$ is direct solar irradiance, $E_{dif}$ is diffuse solar irradiance and $L_p$ is path radiance. There are five unknowns in this equation, 4 atmospheric terms ($\tau$, $E_{dir}$, $E_{dif}$ and $L_p$) and surface reflectance. The 6S radiative transfer code is used to solve for the atmospheric terms, allowing us to solve for surface reflectance.

# $ \rho = \pi(L - L_p) / \tau(E_{dir} + E_{dif}) $


surface_reflectance <- function(bandname,...){

   ## Calculate surface reflectance from at-sensor radiance given waveband name
   
   # run 6S for this waveband
	s$wavelength <- spectralResponseFunction(bandname)
	

    # extract 6S outputs
	Edir <- model$outputs$direct_solar_irradiance             #direct solar irradiance
    Edif <- s$outputs$diffuse_solar_irradiance            #diffuse solar irradiance
    Lp   <- s$outputs$atmospheric_intrinsic_radiance      #path radiance
    absorb  <- s$outputs$trans['global_gas']$upward       #absorption transmissivity
    scatter <- s$outputs$trans['total_scattering']$upward #scattering transmissivity
    tau2 <- absorb*scatter                                #total transmissivity
    
    # radiance to surface reflectance
    rad <- toa_to_rad(bandname)
    ref <- (pi*(rad-Lp))/(tau2*(Edir+Edif))
    
    return(ref)

}


#Atmospheric Correction

# surface reflectance rgb
b <- surface_reflectance('B2')
g <- surface_reflectance('B3')
r <-  surface_reflectance('B4')
ref <- r.addBands(g).addBands(b)

# # all wavebands
# output = S2.select('QA60')
# for band in ['B1','B2','B3','B4','B5','B6','B7','B8','B8A','B9','B10','B11','B12']:
#     print(band)
#     output = output.addBands(surface_reflectance(band))






