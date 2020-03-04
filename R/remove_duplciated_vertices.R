library(rgdal)


lakeslist <- list.files(pattern=".*.*\\.gpkg$$", recursive = TRUE)


## REMOVE HOLES FUNCTION
remove.holes <- function(j) {
			  jp <- slot(j, "polygons")
			    holes <- lapply(jp, function(j) sapply(methods::slot(j, "Polygons"), methods::slot, "hole"))
			    res <- lapply(1:length(jp), function(i) methods::slot(jp[[i]], "Polygons")[!holes[[i]]])
			    IDs <- row.names(j)
			  j.fill <- sp::SpatialPolygons(lapply(1:length(res), function(i)
			                                sp::Polygons(res[[i]], ID=IDs[i])), 
			  						        proj4string=sp::CRS(sp::proj4string(j)))
			  methods::slot(j.fill, "polygons") <- lapply(methods::slot(j.fill, "polygons"), 
			                maptools::checkPolygonsHoles)   
			  methods::slot(j.fill, "polygons") <- lapply(methods::slot(j.fill, "polygons"), "comment<-", NULL)   
			    pids <- sapply(methods::slot(j.fill, "polygons"), function(j) methods::slot(j, "ID"))
			    j.fill <- sp::SpatialPolygonsDataFrame(j.fill, data.frame(row.names=pids, ID=1:length(pids)))	   
			  return( j.fill )	   
}



removeduplicatevertices <- function(x,...){

		l <- readOGR(x)

		## REMOVE ALL HOLES IN THE LAKE
		lake <- remove.holes(l)


for (i in 1:length(lake)) {


		## CREATE A DATAFRAME OF THE COORDS
		df <- as.data.frame(lake@polygons[[i]]@Polygons[[1]]@coords)

		## CREATE A LIST OF DUPLICATE ROWS
		dupli <- df[duplicated(df) | duplicated(df, fromLast=TRUE),]

		## REMOVE FIRST AND LAST ROW OF THE ABOVE DATAFRAME TO NOT EXCLUDE THE POINT WHERE THE POLYGON CLOSES

		## REMOVE FIRST ROW
		dupliwithout1st <- dupli[-1,]

		## REMOVE LAST ROW
		allduplicates <- dupliwithout1st[-nrow(dupliwithout1st),]

		if(dim(allduplicates)[1] > 1){

		## KEEP ONLY ONE ENTRY OF THE DUPLICATES
        onesetduplicaterows <- allduplicates[!duplicated(allduplicates[,c('V1', 'V2')]),]

        ## CREATE A VECTOR OF THE ROWNAMES OF THE DUPLICATES
        rownamesofduplicates <- as.numeric(rownames(allduplicates))

        ##  OBTAIN THE DIFFERENCE BETWEEN EACH PAIR OF NUMBERS THIS IS THE LENGTH OF BETWEEN EACH DUPLICATE PAIR AND THE NEXT DUPLICATE PAIR
        diffduplicates <- rownamesofduplicates[-1] - rownamesofduplicates[-length(rownamesofduplicates)]

        ## RETAIN ONLY THOSE NUMBERS WHICH ARE THE LENGTH BETWEEN DUPLICATE PAIRS
        lengthbetweenduplicates <- diffduplicates[seq(1,length(diffduplicates),2)]

        ## CREATE A DATAFRAME FOR THE START VALUE OF THE SEQUENCE AND THE LENGTH TO DELETE
        info <- data.frame(start=as.numeric(rownames(onesetduplicaterows)), len=lengthbetweenduplicates)

        ## SINCE THE BOUNDARY RINGS/LOOPS ARE  ATLEAST 4 COORDINATES IN LENGTH CREATE A SEQ OF NUMBERS BETWEEN FIRST AND LAST NUMBER
        rowstoremove <- (sequence(info$len) + rep(info$start-1, info$len))

        ## REMOVE THE ABOVE ROWS FROM THE MAIN COORDS DF
		newcoordsdf <- df[!(rownames(df) %in% rowstoremove),]

		## CONVERT TO A MATRIX
		newcoords <- as.matrix(newcoordsdf)

		## SET THE NEW COORDS MATRIX TO THE LAKE COORDS MATRIX
		lake@polygons[[i]]@Polygons[[1]]@coords <- newcoords
	}


}

		filename <- paste0(unlist(strsplit(paste0(x),"[.]"))[1], "-no_holes_no_loops.gpkg")

		writeOGR(obj=lake, dsn=filename, layer=paste0(x), driver="GPKG")


}


lapply(lakeslist, removeduplicatevertices)




	currently stuck at the point if there are no duplicates or loops along the boundary. how to do a conditional function to run. if order df is empty then run if not run





for(i in 1:dim(duplicates)[1]){
print(duplicates[i,])

}
