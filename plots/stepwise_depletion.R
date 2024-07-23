library(data.table)
library(ggplot2)

load("../app/data/fishery_map.RData")
load("../app/data/other_data.RData")

biomass_dat$model <- basename(biomass_dat$model)

dir.create("png", showWarnings=FALSE)

# Number of models and regions
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

# Depletion - plot_sbsbf0
models <- all_models
areas <- "All"
pdat <- biomass_dat[model %in% models & area %in% areas, ]
model_cols <- get_model_colours(all_model_names=all_models,
                                chosen_model_names=models)
p <- ggplot(pdat, aes(x=year, y=SBSBF0))
p <- p + geom_line(aes(colour=model), linewidth=0.75)
p <- p + scale_colour_manual("Model", values=model_cols)
p <- p + facet_wrap(~area, nrow=2)
p <- p + xlab("Year") + ylab("SB/SBF=0")
p <- p + ylim(c(0, 1))
p <- p + theme_bw()
p <- p + geom_hline(aes(yintercept=0.2), linetype=2)

png("png/depletion.png", width=2400, height=1600, res=300)
print(p)
dev.off()
