library(FLR4MFCL)
library(areaplot)

Diag20 <- "01_Diag2020"
Diag23 <- "15_Diag2023"

dir.create("png", showWarnings=FALSE)

# Read growth from Shiny
load("../app/data/other_data.RData")
growth <- as.data.frame(sel_dat)
growth <- growth[growth$model %in% c(Diag20, Diag23),]
growth <- growth[growth$fishery == 1,]
growth$fishery <- growth$value <- growth$sd_length <- NULL
growth$fishery_name <- growth$region <- growth$group <- NULL
growth$tag_recapture_group <- growth$tag_recapture_name <- NULL
rownames(growth) <- NULL

# Read otoliths from Shiny
load("../app/data/oto_dat.RData")
oto <- oto_dat
oto$year <- oto$month <- oto$fishery <- oto$species <- NULL

# Plot settings
col.obs <- "lightgray"
col.2020 <- "lightsalmon"
col.2023 <- "steelblue"
alpha.area <- 0.2
alpha.point <- 0.5
lwd <- 3

png("png/growth.png", width=1800, height=1400, res=200)
# otoliths
plot(oto, pch=16, axes=FALSE, ann=FALSE, col=adjustcolor(col.obs, alpha.point),
     xlim=c(0,41), ylim=c(0, 186), xaxs="i", yaxs="i")
axis(1)
axis(2, las=1)
box()
title(xlab="Age class (quarters)")
title(ylab="Length (cm)")
# growth
confplot(growth[growth$model==Diag20, -c(1,3)], add=TRUE,
         col=adjustcolor(col.2020, alpha.area))
lines(length~age, growth, subset=model==Diag20, col=col.2020, lwd=lwd)
confplot(growth[growth$model==Diag23, -c(1,3)], add=TRUE,
         col=adjustcolor(col.2023, alpha.area))
lines(length~age, growth, subset=model==Diag23, col=col.2023, lwd=lwd)
# legend
legend("topleft", c("Diag2020","Diag2023"), lwd=3, col=c(col.2020,col.2023),
       bty="n", inset=0.02, y.intersp=1.5)

dev.off()
