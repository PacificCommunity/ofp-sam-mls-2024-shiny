# Fishery map MLS 2024

# Combining information from labels.tmp and Table 1 from the assessment report (fisheries),
# and also from flags in the doitall (grouping of release groups)

fishery_map <- data.frame(
  fishery_name=c("01.LL.JP.1",
                 "02.LL.JP.2", 
                 "03.LL.JP.3",
                 "04.LL.JP.4", 
                 "05.LL.TW.4",
                 "06.LL.AU.2", 
                 "07.LL.AU.3",
                 "08.LL.NZ.3",
                 "09.Rec.AU.3",
                 "10.Rec.NZ.3",
                 "11.LL.ALL.1",
                 "12.LL.ALL.2",
                 "13.LL.ALL.3",
                 "14.LL.ALL.4",
                 "15.Index.1_4"))
fishery_map$fishery <- 1:nrow(fishery_map)
fishery_map$region <- rep(1, 15) #c(1,2,3,4,4,3,4,4,3,3,1,2,3,4,1)

# Grouping
fishery_map$group <- "Index"
fishery_map$group[c(1, 11)] <- "LL.1"
fishery_map$group[c(2, 12)] <- "LL.2"
fishery_map$group[c(3, 13)] <- "LL.3"
fishery_map$group[c(4, 5, 14)] <- "LL.4"
fishery_map$group[c(6)] <- "LL.AU"
fishery_map$group[c(7, 8)] <- "LL.AU.NZ"
fishery_map$group[c(9)] <- "Rec.AU"
fishery_map$group[c(10)] <- "Rec.NZ"

save(fishery_map, file="../app/data/fishery_map.RData")
