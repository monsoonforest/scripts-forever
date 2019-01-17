rhoB3 <- (LsatB3 + 0.313276768)
rhoBand3 <- 0.031920656*rhoB3
writeRaster(rhoBand3, "BAND3_ATCOR.tiff", "GTiff")
Band4 <- raster("BAND4.tif")
LsatB4 <- (31.5/255)*Band4
rhoB4 <- (LsatB4 + 0.220715922)
rhoBand4 <- 0.045307107*rhoB4
writeRaster(rhoBand4, "BAND4_ATCOR.tiff", "GTiff")
stack_raster <- stack(rhoBand4, rhoBand3, rhoBand2)
plotRGB(stack_raster, r=rhoBand4, g=rhoBand3, b=rhoBand2, stretch='hist')
writeRaster(stack_raster, "432_ATCOR.tif", "GTiff")