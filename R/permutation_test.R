(ggplot(accuracy,aes(dataset,accuracy))
    + geom_boxplot()
    + stat_sum(colour="darkgray",alpha=0.5)
    + scale_size(breaks=1:2, range=c(3,6))
)



set.seed(101) ## for reproducibility
nsim <- 1000
res <- numeric(nsim) ## set aside space for results
for (i in 1:nsim) {
    ## standard approach: scramble response value
    perm <- sample(nrow(accu))
    bdat <- transform(accu,accuracy=accuracy[perm])
    ## compute & store difference in means; store the value
    res[i] <- mean(bdat[bdat$dataset=="RapidEye","accuracy"])-
        mean(bdat[bdat$dataset=="PlanetScope","accuracy"])
}
obs <- mean(accu[accu$dataset=="RapidEye","accuracy"])-
    mean(accu[accu$dataset=="PlanetScope","accuracy"])
## append the observed value to the list of results
res <- c(res,obs)


hist(res,col="gray",las=1,main="")

abline(v=obs,col="red")

(tt <- t.test(accuracy~dataset,data=accu,var.equal=TRUE))



sum(abs(null - mean(null)) >= abs(obs - mean(null))) / length(null)