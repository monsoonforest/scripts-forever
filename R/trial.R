## PROGRAM TO PLOT THE DISTRIBUTION OF NUTRIENTS AND MAP IN dry-zone AND wet-zone SAVANNAS

## create a variable with a all packages named
packages <- c("raster", "rgdal", "rgeos", "maptools","dplyr", "ncdf4", "ggplot2", "reshape2")

## call all packages using lapply
lapply(packages, library,character.only=TRUE)

## CLASS 1 = 0 TO 100 MM
## CLASS 2 = 100 to 516 mm OF RAINFALL
## CLASS 3 = 516 TO 784 mm
## CLASS 4 = 784 TO 1200 mm
## CLASS 5 = >1200 mm


p1 <- raster("phos-asia-0-100.tif")

p2 <- raster("phos-asia-100-516.tif")
p3 <- raster("phosphorous-516-784mm.tif")
p4 <- raster("phosphorous-784-1200mm.tif")

p5 <- raster("phosphorous-class5.tif")

p1 <- as.data.frame(p1)
p2 <- as.data.frame(p2)
p3 <- as.data.frame(p3)
p4 <- as.data.frame(p4)
p5 <- as.data.frame(p5)

p1[p1==0] <- NA
p2[p2==0] <- NA
p3[p3==0] <- NA
p4[p4==0] <- NA
p5[p5==0] <- NA

p1 <- na.omit(p1)
p2 <- na.omit(p2)
p3 <- na.omit(p3)
p4 <- na.omit(p4)
p5 <- na.omit(p5)

p1 <- melt(p1)
p2 <- melt(p2)
p3 <- melt(p3)
p4 <- melt(p4)
p5 <- melt(p5)

pasia <- rbind(p2, p3, p4)

pasia$continent <- "asia"

cl1 <- raster("clay-asia-0-100.tif")

cl2 <- raster("clay-asia-100-516.tif")
cl3 <- raster("clay-516-784mm.tif")
cl4 <- raster("clay-784-1200mm.tif")

cl5 <- raster("clay-class5.tif")

cl1 <- as.data.frame(cl1)
cl2 <- as.data.frame(cl2)
cl3 <- as.data.frame(cl3)
cl4 <- as.data.frame(cl4)
cl5 <- as.data.frame(cl5)

cl1[cl1==0] <- NA
cl2[cl2==0] <- NA
cl3[cl3==0] <- NA
cl4[cl4==0] <- NA
cl5[cl5==0] <- NA

cl1 <- na.omit(cl1)
cl2 <- na.omit(cl2)
cl3 <- na.omit(cl3)
cl4 <- na.omit(cl4)
cl5 <- na.omit(cl5)

cl1 <- melt(cl1)
cl2 <- melt(cl2)
cl3 <- melt(cl3)
cl4 <- melt(cl4)
cl5 <- melt(cl5)

clasia <- rbind(cl2, cl3, cl4)

clasia$continent <- "asia"

ni1 <- raster("nitro-asia-0-100.tif")

ni2 <- raster("nitro-asia-100-516.tif")
ni3 <- raster("nitrogen-516-784mm.tif")
ni4 <- raster("nitrogen-784-1200mm.tif")

ni5 <- raster("nitrogen-class5.tif")

ni1 <- as.data.frame(ni1)
ni2 <- as.data.frame(ni2)
ni3 <- as.data.frame(ni3)
ni4 <- as.data.frame(ni4)
ni5 <- as.data.frame(ni5)

ni1[ni1==0] <- NA
ni2[ni2==0] <- NA
ni3[ni3==0] <- NA
ni4[ni4==0] <- NA
ni5[ni5==0] <- NA

ni1 <- na.omit(ni1)
ni2 <- na.omit(ni2)
ni3 <- na.omit(ni3)
ni4 <- na.omit(ni4)
ni5 <- na.omit(ni5)

ni1 <- melt(ni1)
ni2 <- melt(ni2)
ni3 <- melt(ni3)
ni4 <- melt(ni4)
ni5 <- melt(ni5)

niasia <- rbind(ni2, ni3, ni4), ni5)

niasia$continent <- "asia"

phosall <- rbind(pafrica, pasia)
nitroall <- rbind(niafrica, niasia)
clall <- rbind(clafrica, clasia)



## function to replace multiple groups in rows
mgsub <- function(pattern, replacement, x, ...) {
  if (length(pattern)!=length(replacement)) {
    stop("pattern and replacement do not have the same length.")
  }
  result <- x
  for (i in 1:length(pattern)) {
    result <- gsub(pattern[i], replacement[i], result, ...)
  }
  result
}

nitroall$variable <- mgsub(c("nitrogen.africa.100.516", "nitrogen.africa.516.784mm", "nitrogen.784.1200mm", "nitro.asia.100.516", "nitrogen.516.784mm"), c("100-516mm","516-784mm", "784-1200mm", "100-516mm", "516-784mm"), nitroall$variable)

phosall$variable <- mgsub(c("phos.africa.100.516", "phosphorous.africa.516.784mm", "phosphorous.784.1200mm", "phos.asia.100.516", "phosphorous.516.784mm"), c("100-516mm","516-784mm", "784-1200mm", "100-516mm", "516-784mm"), phosall$variable)

clall$variable <- mgsub(c("clay.africa.100.516", "clay.africa.516.784mm", "clay.784.1200mm ", "clay.asia.100.516", "clay.516.784mm"), c("100-516mm","516-784mm", "784-1200mm", "100-516mm", "516-784mm"), clall$variable)



phosphorous <- ggplot(phosall, aes(x=variable, y=value, fill=continent)) + geom_boxplot(outlier.shape = NA) + 
scale_x_discrete(limits=c("100-516mm", "516-784mm", "784-1200mm")) + 
scale_y_continuous(limits=c(0, 1000)) +
labs(x="PRECIPITATION ZONE", y="Soil Phosphorous Density g/m2") +
scale_fill_manual(values=wes_palette(n=2, name="Darjeeling2"))


nitrogen <- ggplot(nitroall, aes(x=variable, y=value, fill=continent)) + geom_boxplot(outlier.shape = NA) + 
scale_x_discrete(limits=c("100-516mm", "516-784mm", "784-1200mm")) +
scale_y_continuous(limits=c(0, 800)) +
labs(x="PRECIPITATION ZONE", y="Soil Nitrogen Density g/m2") +
scale_fill_manual(values=wes_palette(n=2, name="Darjeeling2"))



clay <- ggplot(clall, aes(x=variable, y=value, fill=continent)) + geom_boxplot(outlier.shape = NA) + 
scale_x_discrete(limits=c("100-516mm", "516-784mm", "784-1200mm")) +
scale_y_continuous(limits=c(0, 60)) +
labs(x="PRECIPITATION ZONE", y="Soil Clay%") +
scale_fill_manual(values=wes_palette(n=2, name="Darjeeling2"))


ggsave("phosphorous.jpeg", phosphorous, height=15, width=20, unit="cm")


ggplot(x, aes(x=x,y=y)) +
stat_binhex(
        colour = NA,
        aes(fill = cut(..count.., c(-70, 0, 70, 150, 250)))
    ) +
    coord_equal() +
    labs(fill = NULL) +
    scale_fill_brewer(
        palette = "OrRd")