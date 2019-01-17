## HOW TO CREATE DUMMY DATA OF GRIDID 1 : 100 FOR 6 SITES EACH GRID OF THE SAME AREA

library(dplyr)

RTLD <- as.data.frame(cbind(rep("RTLD", 100), seq(1:100), 100))
TBLU <- as.data.frame(cbind(rep("TBLU", 100), seq(1:100), 100))
MANR <- as.data.frame(cbind(rep("MANR", 100), seq(1:100), 100))
RTLD <- as.data.frame(cbind(rep("RTLD", 100), seq(1:100), 100))
MLGD <- as.data.frame(cbind(rep("MLGD", 100), seq(1:100), 100))
HSGD <- as.data.frame(cbind(rep("HSGD", 100), seq(1:100), 100)) 
ALXA <- as.data.frame(cbind(rep("ALXA", 100), seq(1:100), 100))


GRIDIDdf <- bind_rows(ALXA, HSGD, MANR, MLGD, RTLD, TBLU)

write.csv(GRIDIDdf, "GRIDID-table.csv")