## To merge multiple csv rows into one file

library(dplyr)
library(readr)
df <- list.files(full.names = TRUE) %>% 
  lapply(read_csv) %>% 
  bind_rows

write.csv(df, "FILENAME.csv")