test <- read.csv("test-census.csv")


# FOR COUNTS OF DEAD OR ALIVE  
sortedtest <- arrange(test, CENSUS_ID, TREE_ID, STATUS)

## Sort the dataset such that the stem which is alive is the first row in the TREE_ID.I IF ALL STEMS ARE DEAD THEN THE FIRSTROW OF THE TREE_ID GROUP WILL BE DEAD
## THIS REMOVES STEMS THAT ARE DEAD IN A TREE THAT IS ALIVE
deadandalivetrees <- sortedtest %>% group_by(CENSUS_ID, TREE_ID) %>% filter(row_number()==1)


## REMOVE ANY DEAD TREES THAT ARE REPEATED IN SUBSEQUENT CENSUS
trialrmdupdead <- deadandalivetrees %>% group_by(CENSUS_ID, TREE_ID, STEM_ID) %>% filter(!(STATUS == "D" & duplicated(STATUS) == "D"))
 

## LIST OF DEAD TREES
deadtrees <- trialrmdupdead %>% group_by(TREE_ID) %>% filter(STATUS == "D")

## BASAL AREA OF ALL TREES
basalarea <- trialrmdupdead %>% mutate(BASAL_AREA = (POM1_GBH)^2/4*pi)

## JOIN BASAL AREA OF DEAD TREES TO DEAD TREES LIST
basalareasdeadtrees <- left_join(deadtrees, basalarea, by="TREE_ID")
	
## KEEP ONLY THE LAST TWO CENSUSES IN THE DEAD TREES LIST
lasttwocensusofdead <- basalareasdeadtrees %>% group_by(TREE_ID) %>% slice(tail(row_number(), 2))


library(dplyr)
library(tidyr)
load("serb.rdata")
raw.dat.long = bind_rows(lapply(raw.dat, function(x) {

  # Select relevant columns
  select(x, id, sp, plot, starts_with("ba."), starts_with("c.")) %>%

    # Convert from wide to long
    gather("type", "value", starts_with("ba."), starts_with("c.")) %>%

    # Separate out the census ID column
    extract(type, c("type", "census"), "(.*)\\.(.*)", convert = T) %>%

    # We actually want the BA from the previous census, because the BA for
    # dead stems in the current census will be 0 or NA!
    mutate(census = ifelse(type == "ba", census + 1, census), id = as.character(id)) %>%

    # Go back to wide
    spread(type, value, convert = T) %>%

    # Get rid of the max census
    filter(census != max(census))
}))

dead.ba.by.plot.census.sp = group_by(raw.dat.long, plot, census, sp) %>%
  filter(c == "DIED") %>%
  summarize(ba = sum(ba, na.rm = T))
print(dead.ba.by.plot.census.sp, n = Inf)