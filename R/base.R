# ******************************************************************************
# Common libraries and functions of the project
# 
# Author: Xiaojie Gao
# Date: 2023-08-20
# ******************************************************************************
# library(data.table)

.datatable.aware <- TRUE

#' Calculate reslized respiration per unit mass.
#' 
#' @param BaseFolResp Base foliar respiration rate.
#' @param RespQ10 The Q10 parameter.
#' @param T Temperature.
#' @param PsnTOpt Optimum temperature for photosynthesis.
#' @param TimeLen The length of time, e.g, day length or night length.
#'
#' @return Realized respiration per unit mass.
CalRealizedResp <- function(BaseFolResp, RespQ10, T, PsnTOpt, TimeLen) {
    pwr <- (T - PsnTOpt) / 10
    resp <- BaseFolResp * RespQ10^pwr * TimeLen * 12 / 1e9
    return(resp)
}

YearInit <- function(share) {
    # Reset these values
    share$vars$LightEffMin <- 1
    share$vars$GDDTot <- 0
    share$vars$WoodMRespYr <- 0
    share$vars$SoilRespYr <- 0
    share$vars$TotTrans <- 0
    share$vars$TotPsn <- 0
    share$vars$TotGrossPsn <- 0
    share$vars$TotDrain <- 0
    share$vars$TotPrec <- 0
    share$vars$TotEvap <- 0
    share$vars$FolProdCYr <- 0
    share$vars$WoodProdCYr <- 0
    share$vars$RootProdCYr <- 0
    share$vars$WoodMRespYr <- 0
    share$vars$RootMRespYr <- 0
    share$vars$FolGRespYr <- 0
    share$vars$WoodGRespYr <- 0
    share$vars$RootGRespYr <- 0
    share$vars$GDDFolEff <- 0
    share$vars$GDDWoodEff <- 0
    share$vars$PosCBalMassTot <- 0
    share$vars$PosCBalMassIx <- 0
    share$vars$DWatertot <- 0
    share$vars$DWaterIx <- 0

    # For PnET-CN
    share$vars$NDrainYr <- 0
    share$vars$NetNMinYr <- 0
    share$vars$GrossNMinYr <- 0
    share$vars$PlantNUptakeYr <- 0
    share$vars$GrossNImmobYr <- 0
    share$vars$TotalLitterMYr <- 0
    share$vars$TotalLitterNYr <- 0
    share$vars$NetNitrYr <- 0
    share$vars$LightEffMin <- 1
    share$vars$SoilDecRespYr <- 0
    share$vars$WoodDecRespYr <- 0
    share$vars$NetNMinLastYr <- share$vars$NetNMinYr
    share$vars$NdepTot <- 0.0

    share$glb$O3Effect <- numeric(50)
}
