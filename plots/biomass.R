library(FLR4MFCL)

dir.create("png", showWarnings=FALSE)

# Read biomass from Shiny
if(!exists("biomass"))
  load("../app/data/other_data.RData")
biomass <- as.data.frame(biomass_dat)
biomass <- biomass[biomass$model == "15_Diag2023",]
names(biomass)[names(biomass) == "area"] <- "region"
biomass <- biomass[biomass$region %in% as.character(1:5),]
biomass$SB <- biomass$SB / 1e3
biomass$SBF0 <- biomass$SBF0 / 1e3
biomass$model <- NULL
rownames(biomass) <- NULL

# 1  Bcurrent by region (Shiny)
b.cur.reg <- aggregate(SB~region, biomass, sum, subset=year==2021)
b.cur.reg$prop <- 100 * proportions(b.cur.reg$SB)
ns <- sum(b.cur.reg$prop[c(1,5)])
eq <- sum(b.cur.reg$prop[c(2:4)])

png("png/biomass_region.png", width=1600, height=1600, res=200)
par(mfrow=c(1,2))
barplot(b.cur.reg$prop, names=b.cur.reg$region, main="Biomass by region",
        ylab="Proportion of biomass (%)")
barplot(c(ns, eq), names=c("NorthSouth", "Equatorial"),
        main="Biomass by region group")
dev.off()

# 2a  B time series (Shiny)
b.ts <- aggregate(SB~year, biomass, sum)

# 2b B time series (Repfile)
if(!exists("rep", mode="S4"))
  rep <- read.MFCLRep(finalRep("z:/yft/2023/model_runs/diagnostic"))
# adult
adult <- as.data.frame(adultBiomass(rep))
adult$age <- adult$unit <- adult$iter <- NULL
adult$data <- adult$data / 1e6
names(adult) <- c("year", "quarter", "region", "value")
adult.ts <- aggregate(value~year+quarter, adult, sum)  # sum over regions
adult.ts <- aggregate(value~year, adult.ts, mean)      # average over quarters
# total
total <- as.data.frame(totalBiomass(rep))
total$age <- total$unit <- total$iter <- NULL
total$data <- total$data / 1e6
names(total) <- c("year", "quarter", "region", "value")
total.ts <- aggregate(value~year+quarter, total, sum)  # sum over regions
total.ts <- aggregate(value~year, total.ts, mean)      # average over quarters

add_grid <- function()
{
  abline(h=1:12, col="gray", lty=3);
  abline(v=seq(1950,2020,by=10), col="gray", lty=3)
}
png("png/biomass_ts.png", width=1600, height=2400, res=200)
plot(total.ts, type="l", panel.first=add_grid(), ylim=c(0,13), ylab="biomass",
     yaxs="i", lwd=2)
lines(adult.ts, lwd=2, col=2)
dev.off()

bio <- data.frame(year=total.ts$year, total=total.ts$value, adult=adult.ts$value)
