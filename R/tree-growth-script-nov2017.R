## SCRIPT TO CALCULATE PERCENTAGE INCREMENT IN TREE GIRTH ACROSS SEASONS

## FORMULA :


			 	 (DBM2 - DBM1)
% INCREMENT  =	--------------- X 100
					  ING


WHERE, 
DBM = DENDROBAND MEASUREMENT IN MEASUREMENT
ING = INITIAL GIRTH IN CM BASED ON WHICH DENDROBAND WAS MADE
DBM1 OR DBM2 NUMBER DEPENDS ON THE CENSUS NUMBER

	## create a list of the packages
	packages <- c("ggplot2", "dplyr", "tidyr", "reshape2")

	## load all packages in one go
	lapply(X = packages, FUN = library, character.only = TRUE)

	## create a dataframe of the full mannanur dataset
	fulldf <- as.data.frame(read.csv("nstr_mannanur_adulttrees-dband-census1to9.csv"))

	## create a subset of the dataframe of only the census number, tree number, pno, ing and dbm
	treenumdf <- fulldf[, c("cno", "dat", "tno", "pno", "ingcm", "dbmmm")]

	## make the initial growth in mm
	treenumdf$initialgrowthmm <- treenumdf$ing*10

	## reorder the columns
	treenumdf <- treenumdf[, c(1,2,3,4,5,7,6)]

	colnames(treenumdf)
	[1] "cno"             "dat"             "tno"             "pno"            
	[5] "ingcm"           "initialgrowthmm" "dbmmm"

	## create a new columnn called tree id by merging the tree number and pno columne
	treenumdf$treeid <- paste(treenumdf$tno, treenumdf$pno, sep="-")

	## reorder the columns
	treenumdf <- treenumdf[, c(1,2,3,4,8,5,6,7)]

	## create a variable called drops
	drops <- c("tno", "pno", "ingcm")

	## drop the columns we don't need
	treenumdf <- treenumdf[, !(names(treenumdf) %in% drops)]

	## good to convert the data frame as a numeric
	treenumdf[, c(1,4,5)] <- sapply(treenumdf[, c(1,4,5)], as.numeric)

	## check class of all the columns
	sapply(treenumdf, class)
	sapply(treenumdf, mode)


	## Create separate data frames of the each census
	cen1 <- filter(treenumdf, cno==1)
	cen2 <- filter(treenumdf, cno==2)
	cen3 <- filter(treenumdf, cno==3)
	cen4 <- filter(treenumdf, cno==4)
	cen5 <- filter(treenumdf, cno==5)
	cen6 <- filter(treenumdf, cno==6)
	cen7 <- filter(treenumdf, cno==7)
	cen8 <- filter(treenumdf, cno==8)
	cen9 <- filter(treenumdf, cno==9)

	head(cen1)
	  cno        dat treeid initialgrowthmm dbm-mm
	1   1 27/12/2014    2-a             625  22.01
	2   1 27/12/2014    3-a             240   4.14
	3   1 27/12/2014    5-a             334  13.57
	4   1 27/12/2014    6-a             623   4.24
	5   1 27/12/2014    7-a             935  19.26
	6   1 27/12/2014    8-a             455  14.83

	drops <- "initialgrowthmm"

	## drops initial growth mm column from cen2 to cen9 except cen1
	cen2 <- cen2[, !(names(cen2) %in% drops)]
	cen3 <- cen3[, !(names(cen3) %in% drops)]
	cen4 <- cen4[, !(names(cen4) %in% drops)]
	cen5 <- cen5[, !(names(cen5) %in% drops)]
	cen6 <- cen6[, !(names(cen6) %in% drops)]
	cen7 <- cen7[, !(names(cen7) %in% drops)]
	cen8 <- cen8[, !(names(cen8) %in% drops)]
	cen9 <- cen9[, !(names(cen9) %in% drops)]

	## rename the column header in all census to represent the name of the month
	colnames(cen1)[5] <- "dbm-mm-dec2014"
	colnames(cen2)[4] <- "dbm-mm-march2015"
	colnames(cen3)[4] <- "dbm-mm-june2015"
	colnames(cen4)[4] <- "dbm-mm-sep2015"
	colnames(cen5)[4] <- "dbm-mm-dec2015"
	colnames(cen6)[4] <- "dbm-mm-march2016"
	colnames(cen7)[4] <- "dbm-mm-aug2016"
	colnames(cen8)[4] <- "dbm-mm-dec2016"
	colnames(cen9)[4] <- "dbm-mm-april2017"

	## join all the data
	joineddata <- full_join(cen1, cen2, by="treeid")
	joineddata <- full_join(joineddata, cen3, by="treeid")
	joineddata <- full_join(joineddata, cen4, by="treeid")
	joineddata <- full_join(joineddata, cen5, by="treeid")
	joineddata <- full_join(joineddata, cen6, by="treeid")
	joineddata <- full_join(joineddata, cen7, by="treeid")
	joineddata <- full_join(joineddata, cen8, by="treeid")
	joineddata <- full_join(joineddata, cen9, by="treeid")

	## check for duplicates better to use a code than manual
	View(joineddata)

	## remove rows matching this value.... looks suspicious
	joineddata <- joineddata[-grep("1123-a", joineddata$treeid),]

	## remove cno from the dataset
	dband2k1417 <- joineddata[, -grep("cno", colnames(joineddata))]

	## remove dat from the dataset
	dband2k1417 <- dband2k1417[, -grep("dat", colnames(dband2k1417))]

	## calculate the change in growth for all columns
	dband2k1417$chngdec14mrch15 <- ((dband2k1417[,4]-dband2k1417[,3])/dband2k1417[,2])*100
	dband2k1417$chngmrch15jn15 <- ((dband2k1417[,5]-dband2k1417[,4])/dband2k1417[,2])*100
	dband2k1417$chngjn15sep15 <- ((dband2k1417[,6]-dband2k1417[,5])/dband2k1417[,2])*100
	dband2k1417$chngsep15dec15 <- ((dband2k1417[,7]-dband2k1417[,6])/dband2k1417[,2])*100
	dband2k1417$chngdec15mrch16 <- ((dband2k1417[,8]-dband2k1417[,7])/dband2k1417[,2])*100
	dband2k1417$chngmrch16aug16 <- ((dband2k1417[,9]-dband2k1417[,8])/dband2k1417[,2])*100
	dband2k1417$chngaug16dec16 <- ((dband2k1417[,10]-dband2k1417[,9])/dband2k1417[,2])*100
	dband2k1417$chngdec16apr17 <- ((dband2k1417[,11]-dband2k1417[,10])/dband2k1417[,2])*100

	## subset the columns
	plotchng <- select(dband2k1417, treeid, initialgrowthmm, chngdec14mrch15, chngdec14mrch15, 
		chngmrch15jn15, chngjn15sep15, chngsep15dec15, chngdec15mrch16, chngmrch16aug16, 
		chngaug16dec16, chngdec16apr17)





df <- plotchng %>%
     mutate(class = cut(initialgrowthmm, breaks = c(200, 400, 600, 800, 1300), 
     	labels =c("200-400","400-600", "600-800", "800-1300"), include.lowest = TRUE))

df1 <- melt(df)
df1 <- df1[-grep("initialgrowthmm", df1$variable),]

colrs <- c("#e66101", "#fdb863", "#b2abd2", "#5e3c99")

ggplot(df1, aes(variable, value)) + 
geom_bar(aes(fill=factor(class, levels = c("200-400","400-600", "600-800", "800-1300"))), stat="identity") + 
scale_fill_manual("Girth-Class in cm",values=colrs, labels=c("20-40","40-60", "60-80", "80-130"))

ggplot(data = df1, aes(x = variable, y = value)) + 
  geom_point(aes(color = factor(class)), size=0.01) +
  geom_boxplot(aes(fill=NA))


ggplot(df1, aes(variable, value)) + 
geom_bar(aes(fill=factor(class, levels = c("200-400","400-600", "600-800", "800-1300"))), stat="identity") + 

finalplot <- ggplot(na.omit(df1), aes(variable, value)) + 
geom_bar(aes(fill=factor(class, levels = c("200-400","400-600", "600-800", "800-1300"))), 
stat="identity", position=position_dodge()) +
scale_fill_manual("Girth-Class in cm",values=colrs, labels=c("20-40","40-60", "60-80", "80-130")) +
xlab("Month") + ylab("Percentage-Growth") + 
scale_x_discrete(labels=c("December2014-March2015", "March-June2015", 
	"June-September2015", "September-December2015", "December2015-March2016", "March-August2016", 
	"August-December2016", "December2016-April2017")) + theme(axis.text.x = element_text(size=9, angle=45))




censuslist <- list(cen1, cen2, cen3, cen4, cen5, cen6,cen7, cen8,cen9)
treeslist <- lapply(censuslist, nrow)
treeslist <- as.data.frame(unlist(treeslist))
treeslist$year <- c("dec-'14", "mrch-'15", "june-'15", "sep-'15", "dec-'15", "mrch-'16", "aug-'16", "dec-'16", "april-'17")
treeslist$id <- seq.int(nrow(treeslist))
colnames(treeslist)[1] <- "trees"
ggsave(filename = "/home/csheth/documents/work/other/LEMON/nstr-analysis/mannanur-trees-per-census-plot.jpeg", plot = jnkplot, width=25, height=15, unit = "cm")
