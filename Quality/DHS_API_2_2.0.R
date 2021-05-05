
install.packages("plyr")
install.packages("RJSONIO")
install.packages("tidyverse")
install.packages("readxl")

library(readxl)
library(plyr)
library(RJSONIO)
# Import full indicator list 
json_file <- fromJSON("http://api.dhsprogram.com/rest/dhs/indicators?&f=json")
json_data <- lapply(json_file$Data, function(x) { unlist(x) })
ind_full <- as.data.frame(do.call("rbind", json_data),stringsAsFactors=FALSE)
View(ind_full)

# Extract the DHS program indicators relevant to HEFPI
# setwd("C:/Users/wb500886/WBG/Sven Neelsen - World Bank/MEASURE UHC DATA/RAW DATA/Recode VII/external")
setwd("C:/Users/Guan/OneDrive/DHS/MEASURE UHC DATA/RAW DATA/Recode VII/external")
require(RJSONIO)


# Import DHS Selected Comparable Indicator data for each survey
json_file <- fromJSON("http://api.dhsprogram.com/rest/dhs/data?breakdown=national&indicatorIds=RH_ANCS_W_BLP,
RH_ANCS_W_BLS,RH_ANCC_W_IRN,RH_ANCP_W_SKP,RH_TTIJ_W_PRT,RH_ANCS_W_URN,RH_DELA_C_CSC,
CN_BRFI_C_1HR,RH_DELP_C_DHF,FP_CUSM_W_MOD,FP_NADM_W_UNT,FP_NADM_W_PDS,FP_NADM_W_PDM,
AN_NUTS_W_BMI,AN_NUTS_W_OBS,AN_NUTS_W_OWT,CH_VACC_C_BCG,CH_VACC_C_DP1,CH_VACC_C_DP2,
CH_VACC_C_DP3,CH_VACC_C_BAS,CH_VACC_C_MSL,CH_VACC_C_OP1,CH_VACC_C_OP2,CH_VACC_C_OP3,
CH_ARIS_C_ARI,CH_DIAR_C_DIA,CH_DIAT_C_RHF,CH_DIFP_C_LMR,ML_FEVR_C_FEV,CH_DIAT_C_ORS,
CN_NUTS_C_WA2,CN_NUTS_C_HA2,ML_NETC_C_ITN,RH_ANCN_W_N4P,RH_ANCT_W_TL4,RH_DELA_C_SKP,
FP_NADM_W_TDT,CH_DIAT_C_ADV,CH_ARIS_C_ADV&lang=en&f=json&apiKey=apiKey=AWXWBG-900001&perpage=30000")



# Unlist the JSON file entries
json_data <- lapply(json_file$Data, function(x) { unlist(x) })

# Convert JSON input to a data frame
APIdata <- as.data.frame(do.call("rbind", json_data),stringsAsFactors=FALSE)
View(APIdata)

#Rename vars consistent with DHS microdataset

ind<-read_excel("C:/Users/Guan/OneDrive/DHS/MEASURE UHC DATA/DHS guidelines - Guan.xlsx", 
  sheet = "Codebook",
  range = cell_cols("D:E"), skip = 1)

DHS <- merge(APIdata, ind, by.x=c("IndicatorId"),
                    by.y=c("Variable name DHS"))

View(DHS)

DHS<-rename(DHS, c("Variable name"="varname_my","IndicatorId"="varname_DHS","Value"="value_DHS"))
names(DHS) <- tolower(names(DHS))

#by indicator choose the preferred ones? (same indicator sample different)

library(haven)
write_dta(DHS, "DHS.dta")

unique(DHS$ispreferred)

