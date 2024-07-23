library(data.table)
library(ggplot2)

load("../app/data/fishery_map.RData")
load("../app/data/other_data.RData")

biomass_dat$model <- basename(biomass_dat$model)

dir.create("png", showWarnings=FALSE)

# Number of models and regions
sb_units <- 1000
all_models <- unique(biomass_dat$model)
nmodels <- length(all_models)
nregions <- length(unique(fishery_map$region))

get_model_colours <- function(all_model_names, chosen_model_names){
  nmodels <- length(all_model_names)
  very.rich.colors <-
    colorRampPalette(c("darkblue", "royalblue", "seagreen", "limegreen",
                       "gold", "darkorange", "red", "darkred"))
  all_cols <- c(very.rich.colors(nmodels-1), "black")
  names(all_cols) <- all_model_names
  model_cols <- all_cols[as.character(chosen_model_names)]
  return(model_cols)
}

# Spawning potential - plot_sb
models <- all_models
areas <- "All"
ylab <- paste0(
  "Spawning potential (mt; ",
  format(sb_units, big.mark=",", trim=TRUE, scientific=FALSE), "s)")
pdat <- biomass_dat[model %in% models & area %in% areas]
model_cols <- get_model_colours(all_model_names=all_models,
                                chosen_model_names=models)
p <- ggplot(pdat, aes(x=year, y=SB/sb_units))
p <- p + geom_line(aes(colour=model), linewidth=0.75)
p <- p + scale_colour_manual("Model", values=model_cols)
p <- p + facet_wrap(~area, nrow=2)
p <- p + ylim(c(0, NA))
p <- p + xlab("Year") + ylab(ylab)
p <- p + theme_bw()

png("png/biomass.png", width=2400, height=1600, res=300)
print(p)
dev.off()
