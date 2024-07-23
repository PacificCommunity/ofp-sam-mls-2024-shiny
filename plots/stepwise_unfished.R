library(data.table)
library(ggplot2)

load("../app/data/other_data.RData")

dir.create("png", showWarnings=FALSE)

# Number of models and regions
sb_units <- 1000
all_models <- unique(biomass_dat$model)
nmodels <- length(all_models)

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

# Unfished biomass - plot_sbf0
models <- all_models
areas <- "All"
ylab <- paste0("Unfished biomass (mt; ",
               format(sb_units, big.mark=",", trim=TRUE, scientific=FALSE),
               "s)")
pdat <- biomass_dat[model %in% models & area %in% areas]
model_cols <- get_model_colours(all_model_names=all_models,
                                chosen_model_names=models)
p <- ggplot(pdat, aes(x=year, y=SBF0/sb_units))
p <- p + geom_line(aes(colour=model), linewidth=1)
p <- p + scale_colour_manual("Model", values=model_cols)
p <- p + facet_wrap(~area, nrow=2)
p <- p + ylim(c(0, NA))
p <- p + xlab("Year") + ylab(ylab)
p <- p + theme_bw()

png("png/stepwise_unfished.png", width=2400, height=1600, res=300)
print(p)
dev.off()
