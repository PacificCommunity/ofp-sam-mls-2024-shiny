# ofp-sam-mls-2024-shiny
Shiny app for MLS 2024 assessment


## Stepwise

This compares

* 00_Diag2019 (catch error model used in 2019)
* 01_NewMFCL (catch error model using new mfcl)
* 02_CatchCond (diagnostic 2019 converted to catch condition model)
* 03_NewCPUE (adding the new cpue 1979-2017 using operational data from JP and TW. include vessel id like a random effect, s(hbf), year and month
* 04_NewData (adding new data until 2022 using TP aproach)
* 05_Samples10_strata (remove data with less than 10 samples per strata)
* 06_5cm_bins (change of the lenght bins from 6cm to 5cm)
* 07_NatMortality (Lorenzen max age 15)
* 08_Maturity (new maturity provided by CSIRO)
* 09_LW (new LW relationship provided by Jed)
* 10_NewGrowth (new growth parameters provided by CSIRO)

