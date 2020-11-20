plot <- 

ggplot(dat,  aes(y=species, x=group, group=region)) + 
geom_bar(position="stack", stat="identity", aes(fill=region), colour="black") +
theme_ipsum(grid="Y") +
ylab("NUMBER OF SPECIES") + xlab("") +
scale_y_continuous(breaks = c(500, 1000, 1500, 1600)) +
scale_x_discrete(limits=c("butterflies","birds","fish", "reptiles", "terrestrial mammals", "frogs")) +
scale_fill_manual(values=c("#FDE725FF","#31688EFF"), guide=FALSE)