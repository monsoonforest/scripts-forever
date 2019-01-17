# Library
library(dygraphs)
library(xts)          # To make the convertion data-frame / xts format
library(tidyverse)
library(lubridate)
library(RPostgreSQL)
 

pw <- {"rainbow"}
drv <- dbDriver("PostgreSQL") 

con <- dbConnect(drv, dbname = "test", 

host = "127.0.0.1", 

port = 5432, 

user = "postgres", password = pw)

flfm <- dbReadTable(con,c("flfm"))
dbExistsTable(con, "flfm")


freshdrymass <- flfm %>% select(fresh.weight.measure.date, leaf.fresh.mass, leaf.dry.mass) %>% group_by(fresh.weight.measure.date) %>%
summarise(leaf.fresh.mass = mean(leaf.fresh.mass), leaf.dry.mass=mean(leaf.dry.mass))

 
# Then you can create the xts format, and thus use dygraph
don1=xts(x = freshdrymass$leaf.fresh.mass, order.by = freshdrymass$fresh.weight.measure.date)
don2=xts(x=freshdrymass$leaf.dry.mass, order.by=freshdrymass$fresh.weight.measure.date)

don <- cbind(don1, don2)

widg = dygraph(don) %>%
  dyOptions(labelsUTC = TRUE, fillGraph=TRUE, fillAlpha=0.1, drawGrid = FALSE) %>%
  dyRangeSelector() %>%
  dySeries("leaf-fresh-mass-g", label = "leaf-fresh-mass-g", color= "green") %>%
    dySeries("leaf-dry-mass-g", label = "leaf-dry-mass-g", color = "brown") %>%
  dyCrosshair(direction = "vertical") %>%
  dyHighlight(highlightCircleSize = 5, highlightSeriesBackgroundAlpha = 0.2, hideOnMouseOut = FALSE)  %>%
  dyRoller(rollPeriod = 1)