## MERGE ALL CSVS INTO A SINGLE TABLE

df <- list.files(path="/home/csheth/documents/work/gis/arunachal/AP-digitization/electoral-roll-2020/15/MotherRoll/English/Integrated/1", pattern = ".*.*\\.csv$$", recursive = TRUE, full.names = TRUE) %>% 
   lapply(read_csv) %>% bind_rows