###set working directory
setwd("")   

###aquire data file with botanical names to checked
dat<-read.csv("")        

###Package Taxonstand requires internet access while running functions
library(Taxonstand)      
###

###function TPL runs checks with ThePlantList
taxon_check<-TPL(dat$"column with botanical names", corr=T)       ####can take awhile to run. 

###Species that were not detected by TPL. Check spelling mistakes.
taxon_check$Taxon[taxon_check$Taxonomic.status==""]               

###adds Family based on lastest APG classification
dat$family<-taxon_check$family[match(dat$"column with botanical names", taxon_check$Taxon)]  

##adds accepted name with authority based on theplantlist.org
dat$accepted_name<-paste(taxon_check$New.Genus, taxon_check$New.Species, taxon_check$New.Authority[match(dat$"column with botanical names", taxon_check$Taxon)]) 


