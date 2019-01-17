## read more about this and other memory efficient ways of dealing with rasters in Writing functions with the ”raster” package Robert J. Hijmans September 7, 2015

# type this in bash to open it
# xdg-open /home/chintan/documents/work/literature/stas_programming/r-programming/Hijmans-2014-Writingfunctionswiththe”raster”package.pdf



f4 <- function(x, filename, format, ...) 
	{
		out <- raster(x)

		bs <- blockSize(out)

		out <- writeStart(out, filename, overwrite=TRUE)

		for (i in 1:bs$n) 

		{

			v <- getValues(x, row=bs$row[i], nrows=bs$nrows[i] )

			out <- writeValues(out, v, bs$row[i])

		}

		out <- writeStop(out)

		return(out)
	}