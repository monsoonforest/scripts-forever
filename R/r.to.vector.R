## RASTER TO POLYGONS CONVERSION FROM A LIST OF RASTERS

packages <- c("raster", "rgdal", "sp", "satellite","maptools", "XML", "RJSONIO", "rgeos")

lapply(X = packages, FUN = library, character.only=TRUE)

## list your rasters
lakes <- list.files(pattern = ".*lakes.*\\.tif$$", recursive = FALSE)



gdal_polygonizeR <- function(x, outshape=NULL, gdalformat = 'ESRI Shapefile',
                             pypath=NULL, readpoly=TRUE, quiet=TRUE) 
{
  if (isTRUE(readpoly)) require(rgdal)
  if (is.null(pypath)) {
    pypath <- Sys.which('gdal_polygonize.py')
  }
  if (!file.exists(pypath)) stop("Can't find gdal_polygonize.py on your system.")
  owd <- getwd()
  on.exit(setwd(owd))
  setwd(dirname(pypath))
  if (!is.null(outshape)) {
    outshape <- sub('\\.shp$', '', outshape)
    f.exists <- file.exists(paste(outshape, c('shp', 'shx', 'dbf'), sep='.'))
    if (any(f.exists))
      stop(sprintf('File already exists: %s',
                   toString(paste(outshape, c('shp', 'shx', 'dbf'),
                                  sep='.')[f.exists])), call.=FALSE)
  } else outshape <- tempfile()
  if (is(x, 'Raster')) {
    require(raster)
    writeRaster(x, {f <- tempfile(fileext='.tif')})
    rastpath <- normalizePath(f)
  } else if (is.character(x)) {
    rastpath <- normalizePath(x)
  } else stop('x must be a file path (character string), or a Raster object.')
  system2('python', args=(sprintf('"%1$s" "%2$s" -f "%3$s" "%4$s.shp"',
                                  pypath, rastpath, gdalformat, outshape)))
  if (isTRUE(readpoly)) {
    shp <- readOGR(dirname(outshape), layer = basename(outshape), verbose=!quiet)
    return(shp)
  }
  return(NULL)
}
	

rasterToPolygons <- function (x, fun = NULL, n = 4, na.rm = TRUE, digits = 12, dissolve = FALSE) 
{
    stopifnot(n %in% c(4, 8, 16))
    if (nlayers(x) > 1) {
        if (!is.null(fun)) {
            stop("you cannot supply a \"fun\" argument when \"x\" has multiple layers")
        }
    }
    if (!fromDisk(x) & !inMemory(x)) {
        xyv <- xyFromCell(x, 1:ncell(x))
        xyv <- cbind(xyv, NA)
    }
    else if (!(na.rm) | inMemory(x) | canProcessInMemory(x)) {
        xyv <- cbind(xyFromCell(x, 1:ncell(x)), getValues(x))
        x <- clearValues(x)
        if (na.rm) {
            nas <- apply(xyv[, 3:ncol(xyv), drop = FALSE], 1, 
                function(x) all(is.na(x)))
            xyv <- xyv[!nas, , drop = FALSE]
        }
        if (!is.null(fun)) {
            if (nrow(xyv) > 0) {
                xyv <- subset(xyv, fun(xyv[, 3]))
            }
        }
    }
    else {
        tr <- blockSize(x)
        xyv <- matrix(ncol = 3, nrow = 0)
        nl <- nlayers(x)
        for (i in 1:tr$n) {
            start <- cellFromRowCol(x, tr$row[i], 1)
            end <- start + tr$nrows[i] * ncol(x) - 1
            xyvr <- cbind(xyFromCell(x, start:end), getValues(x, 
                row = tr$row[i], nrows = tr$nrows[i]))
            if (na.rm) {
                if (nl > 1) {
                  nas <- apply(xyvr[, 3:ncol(xyvr), drop = FALSE], 
                    1, function(x) all(is.na(x)))
                }
                else {
                  nas <- is.na(xyvr[, 3])
                }
                xyvr <- xyvr[!nas, , drop = FALSE]
            }
            if (nrow(xyvr) > 0) {
                if (!is.null(fun)) {
                  xyvr <- subset(xyvr, fun(xyvr[, 3, drop = FALSE]))
                }
                rownames(xyvr) <- NULL
                xyv <- rbind(xyv, xyvr)
            }
        }
    }
    colnames(xyv) <- c("x", "y", names(x))
    if (nrow(xyv) == 0) {
        warning("no values in selection")
        return(NULL)
    }
    cr <- .getPolygons(xyv[, 1:2, drop = FALSE], res(x), n)
    cr <- round(cr, digits = digits)
    sp <- lapply(1:nrow(cr), function(i) Polygons(list(Polygon(matrix(cr[i, 
        ], ncol = 2))), i))
    sp <- SpatialPolygons(sp, proj4string = crs(x))
    sp <- SpatialPolygonsDataFrame(sp, data.frame(xyv[, 3:ncol(xyv), 
        drop = FALSE]), match.ID = FALSE)
    if (dissolve) {
        if (!requireNamespace("rgeos")) {
            warning("package rgeos is not available. Cannot dissolve")
        }
        else {
            sp <- aggregate(sp, names(sp))
        }
    }
    sp
}

## for loop
convertraster <- function(x,...){
for (i in 1:length(x)) {

r <- raster(paste0(x[i]))

## ONLY CONVERT RASTER OF VALUE 1 TO POLYGONS
polyall <-	gdal_polygonizeR(r, outshape=NULL, gdalformat = 'ESRI Shapefile',
                             pypath=NULL, readpoly=TRUE, quiet=TRUE )
poly <- polyall[polyall$DN==1,]

## ASSIGN PROJECTION
proj4string(poly) <- "+proj=utm +zone=46 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"

## CHANGE FIELD NAME
names(poly) <- "value"

filepath <- paste0("poly_", unlist(strsplit(basename(x[i]),"\\."))[1])

writePolyShape(poly,filepath)	

}

}

convertraster(lakes)
