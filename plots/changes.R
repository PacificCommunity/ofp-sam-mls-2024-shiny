# Load biomass data
load("../app/data/other_data.RData")
options(width=120)

# Select current year, all regions
x <- as.data.frame(biomass_dat)
x <- subset(x, year==2018 & area=="All")

# Remove rownames and redundant columns
rownames(x) <- NULL
x$year <- x$area <- x$SBF0 <- NULL

# Format numbers
x$SB <- round(x$SB / 1000, -1)
x$SBSBF0 <- round(100 * x$SBSBF0, 1)

# Calculate change
sb.before <- x$SB[-nrow(x)]
sb.after <- x$SB[-1]
dep.before <- x$SBSBF0[-nrow(x)]
dep.after <- x$SBSBF0[-1]
x$SB.change <- c(0, sb.after - sb.before)
x$SBSBF0.change <- c(0, dep.after - dep.before)

# Describe change
x$sb <- ""
x$sb[x$SB.change >= 300] <- "substantial increase"
x$sb[x$SB.change >= 100 & x$SB.change < 300] <- "increase"
x$sb[x$SB.change >= 50 & x$SB.change < 100] <- "small increase"
x$sb[x$SB.change > -50 & x$SB.change < 50] <- "no change"
x$sb[x$SB.change > -100 & x$SB.change <= -50] <- "small decrease"
x$sb[x$SB.change > -300 & x$SB.change <= -100] <- "decrease"
x$sb[x$SB.change <= -300] <- "substantial decrease"

x$sbsbf0 <- ""
x$sbsbf0[x$SBSBF0.change >= 3] <- "substantial increase"
x$sbsbf0[x$SBSBF0.change >= 1 & x$SBSBF0.change < 3] <- "increase"
x$sbsbf0[x$SBSBF0.change >= 0.5 & x$SBSBF0.change < 1] <- "small increase"
x$sbsbf0[x$SBSBF0.change > -0.5 & x$SBSBF0.change < 0.5] <- "no change"
x$sbsbf0[x$SBSBF0.change > -1 & x$SBSBF0.change <= -0.5] <- "small decrease"
x$sbsbf0[x$SBSBF0.change > -3 & x$SBSBF0.change <= -1] <- "decrease"
x$sbsbf0[x$SBSBF0.change <= -3] <- "substantial decrease"

# Reorder columns
cols <- c("model", "SBSBF0", "SB", "SBSBF0.change", "SB.change", "sbsbf0", "sb")
x <- x[cols]

# Barplot
png("png/changes.png", width=2000, height=2800, res=300)
par(plt=c(0.38, 0.94, 0.12, 0.98))
barplot(rev(x$SBSBF0.change/100), names=rev(x$model), horiz=TRUE, las=1,
        xlab="SB/SBF0 change")
dev.off()
