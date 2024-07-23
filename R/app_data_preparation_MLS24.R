#------------------------------------------------------------------
# Preparing the data for the app.
# Basic approach is to go through the 'basedir' model folder
# and hoover out the data we need.
#------------------------------------------------------------------

# Packages
# It may be advisable to use a version of FLR4MFCL that matches the MFCL runs,
# to ensure that the movement matrices are being read in correctly (from / to)
library(FLR4MFCL)
library(data.table)

# Helper functions
source("read_length_fit_file.R")

# Model folder
basedir <- "C:/StockAssessment/2024/MLS/models_run/"
#basedir <- "C:/StockAssessment/2024/MLS/model_runs79/"
#Retro folder
#basedir <- "C:/StockAssessment/2024/model_runsRetro/"

#jitter folder
#basedir <- "C:/StockAssessment/2024/model_runs24_2/"

#basedir <- "//penguin/assessments/mls/2024/model_runs/stepwiseEffortProj/"
#basedir <- "//penguin/assessments/mls/2024/model_runs/stepwise/"
#
#basedir <- "d:/bet2023Stepwise/stepwiseFull"
#basedir <- "d:/bet2023Stepwise/stepwiseEveryLittleStep"

#frqfile <- "MLSe79.frq"
frqfile <- "MLSe.frq"
#age_lengthfile <- "bet.age_length"

# Specify models to plot
models <-  "C:/StockAssessment/2024/MLS/models_run/"
#models <-  "C:/StockAssessment/2024/MLS/model_runs79/"
#Jitter models
#models <- "C:/StockAssessment/2024/model_runs24_2/"
#models <- "C:/StockAssessment/2024/model_runsRetro/"

models <- sort(list.dirs(models, full.names=FALSE, recursive=FALSE))

#models <- dir(basedir, pattern="temporary_tag_report$", recursive=TRUE)
#models <- dirname(models)

# Fisheries
index_fisheries <- 15

# Output folder
dir.create("../app/data", showWarnings=FALSE)

# Generate the fishery map
source("fishery_map_MLS24.R")
# Load the fishery map - assumed to be the same for all models
load("../app/data/fishery_map.RData")

#------------------------------------------------------------------
# Data checker
# Each model folder needs to have the following files:
# *.tag
# length.fit
# weight.fit
# temporary_tag_report
# *.frq
# test_plot_output
# *.par
# *.rep
# Optional:
# *.age_length

needed_files <- c("length.fit", "weight.fit", 
                  frqfile, "test_plot_output")
for (model in models){
  model_files <- dir(file.path(basedir, model))
  # Also check for a par and rep
  parfiles <- model_files[grep(".par$", model_files)]
  if(length(parfiles) == 0){
    cat("Missing par file in model '", model, "'. Dropping model.\n", sep="")
    models <- models[!(models %in% model)]
  }
  repfiles <- model_files[grep("par.rep$", model_files)]
  if(length(repfiles) == 0){
    cat("Missing rep file in model '", model, "'. Dropping model.\n", sep="")
    models <- models[!(models %in% model)]
  }
  if(!all(needed_files %in% model_files)){
    missing_file <- needed_files[!(needed_files %in% model_files)]
    cat("Missing files in model '", model, "': ",
        paste(missing_file, collapse=", "), ". Dropping model.\n", sep="")
    models <- models[!(models %in% model)]
  }
}

#------------------------------------------------------------------
# Otolith data - read once instead of n times
# 'here' is an integer pointing to the first model dir containing *.age_length
#here <- match(TRUE, file.exists(file.path(basedir, models, age_lengthfile)))
#if(!is.na(here))
#{
#  cat("** Reading otoliths\n")
#  cat("Processing", age_lengthfile, "... ")
#  oto_dat <- read.MFCLALK(file.path(basedir, models[here], age_lengthfile),
#                          file.path(basedir, models[here], "length.fit"))
#  oto_dat <- ALK(oto_dat)
#  oto_dat <- data.frame(year=rep(oto_dat$year, oto_dat$obs),
#                        month=rep(oto_dat$month, oto_dat$obs),
#                        fishery=rep(oto_dat$fishery, oto_dat$obs),
#                        species=rep(oto_dat$species, oto_dat$obs),
#                        age=rep(oto_dat$age, oto_dat$obs),
#                        length=rep(oto_dat$length, oto_dat$obs))
#  oto_dat <- type.convert(oto_dat, as.is=TRUE)
#  save(oto_dat, file="../app/data/oto_dat.RData")
#  cat("done\n\n")
#}
# oto_dat.RData is only created if *.age_length was found in some model dir

#------------------------------------------------------------------
# Data for length composition plots
# This involves going through the length.fit files and processing the data
# The function to read and process the data is here:

cat("** Length composition stuff\n")
lfits_dat <- lapply(models, function(x){
  cat("Processing model: ", x, "\n", sep="")
  filename <- file.path(basedir, x, "length.fit")
  read_length_fit_file(filename, model_name=x)})
lfits_dat <- rbindlist(lfits_dat)
# Bring in the fishery map
lfits_dat <- merge(lfits_dat, fishery_map)

# Save it in the app data directory
save(lfits_dat, file="../app/data/lfits_dat.RData")

#------------------------------------------------------------------
# Data for weight composition plots
# This involves going through the weight.fit files and processing the data
# The function to read and process the data is here:

cat("\n** Weight composition stuff\n")
wfits_dat <- lapply(models, function(x){
  cat("Processing model: ", x, "\n", sep="")
  filename <- file.path(basedir, x, "weight.fit")
  read_length_fit_file(filename, model_name=x)})
wfits_dat <- rbindlist(wfits_dat)
# Bring in the fishery map
wfits_dat <- merge(wfits_dat, fishery_map)

# Save it in the app data directory
save(wfits_dat, file="../app/data/wfits_dat.RData")

#------------------------------------------------------------------
# General stuff including stock recruitment, SB and SBSBF0 data.

cat("\n** General stuff\n")
srr_dat <- list()
srr_fit_dat <- list()
rec_dev_dat <- list()
biomass_dat <- list()
sel_dat <- list()
growth_dat <- list()
m_dat <- list()
mat_age_dat <- list()
mat_length_dat <- list()
cpue_dat <- list()
status_tab_dat <- list()

for (model in models){
  cat("Model: ", model, "\n", sep="")
  final_rep <- finalRep(file.path(basedir, model))
  rep <- read.MFCLRep(final_rep)
  
  # SRR stuff
  adult_biomass <- as.data.table(
    adultBiomass(rep))[, c("year", "season", "area", "value")]
  recruitment <- as.data.table(
    popN(rep)[1,])[, c("year", "season", "area", "value")]
  setnames(adult_biomass, "value", "sb")
  setnames(recruitment, "value", "rec")
  pdat <- merge(adult_biomass, recruitment)
  pdat[, c("year", "season") := .(as.numeric(year), as.numeric(season))]
  srr_dat[[model]] <- pdat
  
  # Get the BH fit
  # Need to pick a suitable max SB
  # Sum over areas and assume annualised (mean over years)
  # pdattemp <- pdat[, .(sb=sum(sb)), by=.(year, season)]
  # pdattemp <- pdattemp[, .(sb=mean(sb)), by=.(year)]
  # max_sb <- max(pdattemp$sb) * 1.2 # Just add another 20% on
  max_sb <- 20e6 # Just pick a massive number and then trim using limits
  sb <- seq(0, max_sb, length=100)
  # Extract the BH params and make data.frame of predicted recruitment
  # Note that this is predicted ANNUAL recruitment, given a SEASONAL SB
  # The data in the popN that we take recruitment from is SEASONAL
  # There is then some distribution
  params <- c(srr(rep)[c("a", "b")])
  bhdat <- data.frame(sb=sb, rec=(sb*params[1]) / (params[2]+sb))
  srr_fit_dat[[model]] <- bhdat
  
  # Get the rec devs
  final_par <- finalPar(file.path(basedir, model))
  first_year <- firstYear(file.path(basedir, model))
  par <- read.MFCLPar(final_par, first.yr=first_year)
  rdat <- as.data.table(
    region_rec_var(par))[, c("year", "season", "area", "value")]
  rdat[, c("year", "season") := .(as.numeric(year), as.numeric(season))]
  rdat[, "ts" := .(year + (season-1)/4 + 1/8)]
  rec_dev_dat[[model]] <- rdat
  
  # Get SBSBF0 and SB - mean over seasons
  sbsbf0_region <- as.data.table(SBSBF0(rep, combine_areas=FALSE))
  sbsbf0_all <- as.data.table(SBSBF0(rep, combine_areas=TRUE))
  sbsbf0dat <- rbindlist(list(sbsbf0_region, sbsbf0_all))
  setnames(sbsbf0dat, "value", "SBSBF0")
  
  sb_region <- as.data.table(SB(rep, combine_areas=FALSE))
  sb_all <- as.data.table(SB(rep, combine_areas=TRUE))
  sbdat <- rbindlist(list(sb_region, sb_all))
  setnames(sbdat, "value", "SB")
  
  sbf0_region <- as.data.table(SBF0(rep, combine_areas=FALSE))
  sbf0_all <- as.data.table(SBF0(rep, combine_areas=TRUE))
  sbf0dat <- rbindlist(list(sbf0_region, sbf0_all))
  setnames(sbf0dat, "value", "SBF0")
  
  sbdat <- data.table(sbdat, SBF0=sbf0dat$SBF0, SBSBF0=sbsbf0dat$SBSBF0)
  sbdat <- sbdat[, c("year","area","SB","SBF0","SBSBF0")]
  sbdat[area=="unique", area := "All"] # change in place, data.table for the win
  sbdat[, year := as.numeric(year)]
  biomass_dat[[model]] <- sbdat
  
  # Selectivity by age class (in quarters)
  sel <- as.data.table(sel(rep))[, .(age, unit, value)]
  sel[, c("age", "unit") := .(as.numeric(age), as.numeric(unit))]
  setnames(sel, "unit", "fishery")
  # Bring in lengths
  mean_laa <- c(aperm(mean_laa(rep), c(4,1,2,3,5,6)))
  sd_laa <- c(aperm(sd_laa(rep), c(4,1,2,3,5,6)))
  # Order sel for consecutive ages
  setorder(sel, fishery, age)
  nfisheries <- length(unique(sel$fishery))
  sel$length <- rep(mean_laa, nfisheries)
  sel$sd_length <- rep(sd_laa, nfisheries)
  sel[, c("length_upper", "length_lower") :=
        .(length + 1.96*sd_length, length - 1.96*sd_length)]
  sel_dat[[model]] <- sel
  
  # Natural mortality
  m <- m_at_age(rep)
  m <- data.table(age=1:length(m), m=m)
  m_dat[[model]] <- m
  
  # Maturity in the par files
  # Needs the lfits_dat to have been generated above
  modeltemp <- model
  lfittemp <- lfits_dat[model == modeltemp]
  lenbin <- sort(unique(lfittemp$length))
  # Length
  mat_length <- data.table(length = lenbin, mat = mat_at_length(par))
  mat_length_dat[[model]] <- mat_length
  # Age
  mat_age <- mat(par)
  mat_age <- data.table(age = 1:length(mat_age), mat = mat_age)
  mat_age_dat[[model]] <- mat_age
  
  # CPUE obs and pred - noting that this information is
  # only applicable for some models
  cpue <- as.data.table(cpue_obs(rep))
  cpue_pred <- as.data.table(cpue_pred(rep))
  setnames(cpue, "value", "cpue_obs")
  cpue[, cpue_pred := cpue_pred$value]
  setnames(cpue, "unit", "fishery")
  cpue[, ts := .(as.numeric(year) + (as.numeric(season)-1)/4)]
  # Trim out only the index fisheries
  cpue <- cpue[fishery %in% index_fisheries]
  cpue[, fishery := as.numeric(fishery)] # for merging with fishery_map
  # Transform by taking exp()
  cpue[, c("cpue_obs", "cpue_pred") := .(exp(cpue_obs), exp(cpue_pred))]
  cpue_dat[[model]] <- cpue
  
  # Summary table
  sbsbf0 <- as.numeric(SBSBF0(rep))
  sbsbf0recent <- as.numeric(SBSBF0recent(rep))
  status_tab <- data.table(
    "Final SB/SBF0instant" = tail(sbsbf0, 1),
    "Final SB/SBF0recent" = tail(sbsbf0recent, 1),
    "SB/SBF0 (2012)" = as.numeric(SBSBF0(rep)[,"2012"]),
    #    "Final SB/SBF0latest" = tail(sbsbf0latest, 1),    
    MSY = MSY(rep),
    BMSY=BMSY(rep),
    FMSY=FMSY(rep))
  status_tab_dat[[model]] <- status_tab
}

srr_dat <- rbindlist(srr_dat, idcol="model")
srr_fit_dat <- rbindlist(srr_fit_dat, idcol="model")
rec_dev_dat <- rbindlist(rec_dev_dat, idcol="model")
biomass_dat <- rbindlist(biomass_dat, idcol="model")
m_dat <- rbindlist(m_dat, idcol="model")
mat_age_dat <- rbindlist(mat_age_dat, idcol="model")
mat_length_dat <- rbindlist(mat_length_dat, idcol="model")
sel_dat <- rbindlist(sel_dat, idcol="model")
sel_dat <- merge(sel_dat, fishery_map)
cpue_dat <- rbindlist(cpue_dat, idcol="model")
status_tab_dat <- rbindlist(status_tab_dat, idcol="Model")

# Look at difference - better for evaluating fit?
# Don't do this for the annual data
cpue_dat[, diff := .(cpue_obs - cpue_pred)]
# Scale by total catchability by fishery and model
cpue_dat[, scale_diff := diff / mean(cpue_obs, na.rm=TRUE),
         by=.(model, fishery)]

save(status_tab_dat, cpue_dat, mat_age_dat, mat_length_dat,
     biomass_dat, srr_dat, srr_fit_dat, rec_dev_dat, sel_dat, m_dat,
     file="../app/data/other_data.RData")

#-----------------------------------

# Likelihood table
cat("\n** Likelihood table\n")
ll_tab_dat <- list()
for (model in models){
  cat("Model: ", model, "\n", sep="")
  # Load the likelihood and par files
  ll <- read.MFCLLikelihood(file.path(basedir, model, "test_plot_output")) 
  final_par <- finalPar(file.path(basedir, model))
  first_year <- firstYear(file.path(basedir, model))
  par <- read.MFCLParBits(final_par, first.yr=first_year)  # ParBits is fast
  # Get LL summary
  ll_summary <- summary(ll)
  row.names(ll_summary) <- ll_summary$component
  # Build data.table with correct names
  lldf <- data.table(
    Npar = n_pars(par),
    ObjFun = obj_fun(par),
    CPUE = ll_summary["cpue", "likelihood"],
    Length = ll_summary["length_comp", "likelihood"],
    Weight = ll_summary["weight_comp", "likelihood"],
    Age = ll_summary["age", "likelihood"],
    Tags = ll_summary["tag_data", "likelihood"],
    Recruitment = ll_summary["bhsteep", "likelihood"],
    Effort_devs = ll_summary["effort_dev", "likelihood"],
    Catchability_devs = ll_summary["catchability_dev", "likelihood"],
    Total = ll_summary["total", "likelihood"],
    Penalties = NA_real_,  # calculate after this loop
    Gradient = max_grad(par)
  )
  # If the Shiny app includes results from models older than MFCL 2.1.0.0,
  # then we need to correct the ObjFun calculation
  final_rep <- finalRep(file.path(basedir, model))
  ver <- grep("MULTIFAN-CL version number", readLines(final_rep), value=TRUE)
  ver <- gsub(".*: ", "", ver)
  if(numeric_version(ver) < numeric_version("2.1.0.0"))
    lldf[, ObjFun := -ObjFun]  # before 2.1.0.0, the objfun was backwards
  ll_tab_dat[[model]] <- lldf
}

ll_tab_dat <- rbindlist(ll_tab_dat, idcol="Model")
ll_tab_dat[, Catchability_devs := NULL]     # all zeroes
ll_tab_dat[CPUE == 0, CPUE := Effort_devs]  # use Effort_devs when CPUE is 0
ll_tab_dat[, Effort_devs := NULL]
# Combine recruitment with other Penalties - BET was different to YFT initially
ll_tab_dat[, Penalties := ObjFun - Total + Recruitment]
ll_tab_dat[, Recruitment := NULL]
# Don't combine Recruitment with other Penalties - BET was different to YFT initially
# ll_tab_dat[, Penalties := ObjFun - Total]
ll_tab_dat[, Total := NULL]  # intermediate calculations, includes Recruitment

save(ll_tab_dat, file="../app/data/ll_tab_data.RData")

#-----------------------------------
