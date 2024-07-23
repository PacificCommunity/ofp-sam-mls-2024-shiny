load("../app/data/other_data.RData")  # srr_dat

dir.create("png", showWarnings=FALSE)

x <- as.data.frame(srr_dat)
x <- x[x$model == "15_Diag2023",]
x$sb <- NULL
x$rec <- x$rec / 1e6
rownames(x) <- NULL
names(x)[names(x) == "season"] <- "quarter"
names(x)[names(x) == "area"] <- "region"

# 1  Total annual recruitment time series

x.tot.yr <- aggregate(rec~year, x, sum)
x.tot.yr$rec <- x.tot.yr$rec / 4  # avg quarterly instead of total annual

png("png/recruitment_trend.png", width=1600, height=1600, res=200)
plot(rec~year, x.tot.yr, ylim=c(0,1000))
abline(h=mean(x$rec), lty=3)
fm <- loess(rec~year, x.tot.yr)
lines(fm$fitted~fm$x, lwd=3)
dev.off()

# 2  Average annual recruitment by region

png("png/recruitment_region.png", width=1600, height=1600, res=200)
x.avg.reg <- aggregate(rec~year+region, x, sum)  # total in year:region
x.avg.reg <- aggregate(rec~region, x.avg.reg, mean)
x.avg.reg$prop <- 100 * proportions(x.avg.reg$rec)
barplot(x.avg.reg$prop, names=x.avg.reg$region, xlab="region",
        ylab="recruitment (%)")
dev.off()
