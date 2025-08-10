# ******************************************************************************
# Decomp routine in PnET-CN
# 
# Author: Xiaojie Gao
# Date: 2023-10-09
# ******************************************************************************


#' The Decomp module in PnET-CN
#'
#' @description
#' The following variables are calculated/updated:
#'   - NO3
#'   - NH4
#'   - NdepTot
#'   - GrossNMinYr
#'   - SoilDecResp
#'   - SoilDecRespYr
#'   - NetCBal
#'   - GrossNImmobYr
#'   - HON
#'   - HOM
#'   - PlantN
#'   - PlantNUptakeYr
#'   - NetNMinYr
#'   - NetNitrYr
#'
#' @param climate_dt A table that contains monthly climate data.
#' @param sitepar A table that contains site-specific variables.
#' @param vegpar A table that contains vegetation-specific variables.
#' @param share The shared object containing intermittent variables.
#' @param rstep current time step
Decomp <- function(climate_dt, sitepar, vegpar, share, rstep) {
    # Variables to update
    NO3 <- NH4 <- NdepTot <- NULL
    GrossNMinYr <- NULL
    SoilDecResp <- SoilDecRespYr <- NULL
    NetCBal <- NULL
    GrossNImmobYr <- NULL
    HON <- HOM <- NULL
    PlantN <- PlantNUptakeYr <- NULL
    NetNMin <- NetNitrYr <- NULL

    # Some already calculated variables at this time step
    Dayspan <- share$logdt[rstep, Dayspan]
    Tavg <- share$logdt[rstep, Tavg]
    DOY <- share$logdt[rstep, DOY]
    # Number of days in this year
    NumYrDays <- yday(paste0(share$logdt[rstep, Year], "-12-31"))

    # Atmospheric N deposition
    NO3 <- share$vars$NO3 + climate_dt[rstep, NO3dep]
    NH4 <- share$vars$NH4 + climate_dt[rstep, NH4dep]
    NdepTot <- share$vars$NdepTot + climate_dt[rstep, NO3dep] + 
        climate_dt[rstep, NH4dep]

    # Temperature effect on all soil processes
    tEffSoil <- max(Tavg, 1)
    TMult <- (exp(0.1 * (Tavg - 7.1)) * 0.68) * 1;
    WMult <- share$vars$MeanSoilMoistEff

    # Add litter to the humus pool
    HOM <- share$vars$HOM + share$vars$TotalLitterM
    HON <- share$vars$HON + share$vars$TotalLitterN

    # Humus dynamics
    KhoAct <- vegpar$Kho * (Dayspan / NumYrDays)
    DHO <- HOM * (1 - exp(-KhoAct * TMult * WMult))
    
    GrossNMin <- DHO * (HON / HOM)
    GrossNMinYr <- share$vars$GrossNMinYr + GrossNMin

    SoilDecResp <- DHO * vegpar$CFracBiomass
    SoilDecRespYr <- share$vars$SoilDecRespYr + SoilDecResp

    # Update HON and HOM
    HOM <- HOM - DHO
    HON <- HON - GrossNMin

    NetCBal <- share$vars$NetCBal - SoilDecResp

    # Immobilization and net mineralization
    SoilPctN <- (HON / HOM) * 100
    NReten <- (vegpar$NImmobA + vegpar$NImmobB * SoilPctN) / 100
    GrossNImmob <- NReten * GrossNMin
    GrossNImmobYr <- share$vars$GrossNImmobYr + GrossNImmob
    
    # Update HOM again
    HON <- HON + GrossNImmob

    # Net mineralization
    NetNMin <- GrossNMin - GrossNImmob

    # Update NH4
    NH4 <- NH4 + NetNMin
    NetNitr <- NH4 * share$vars$NRatioNit
    NO3 <- NO3 + NetNitr
    NH4 <- NH4 - NetNitr

    # Plant uptake
    RootNSinkStr <- min(share$vars$RootNSinkEff * TMult, 0.98)
    PlantNUptake <- (NH4 + NO3) * RootNSinkStr
    if ((PlantNUptake + share$vars$PlantN) > vegpar$MaxNStore) {
        PlantNUptake <- vegpar$MaxNStore - share$vars$PlantN
        RootNSinkStr <- PlantNUptake / (NO3 + NH4)
    }

    if (PlantNUptake < 0) {
        PlantNUptake <- 0
        RootNSinkStr <- 0
    }
    PlantN <- share$vars$PlantN + PlantNUptake
    PlantNUptakeYr <- share$vars$PlantNUptakeYr + PlantNUptake

    NH4Up <- NH4 * RootNSinkStr
    NH4 <- NH4 - NH4Up
    NO3Up <- NO3 * RootNSinkStr
    NO3 <- NO3 - NO3Up

    NetNMinYr <- share$vars$NetNMinYr + NetNMin
    NetNitrYr <- share$vars$NetNitrYr + NetNitr


    # Update values
    if (!is.null(NO3)) {
        share$vars$NO3 <- NO3
    }
    if (!is.null(NH4)) {
        share$vars$NH4 <- NH4
    }
    if (!is.null(NdepTot)) {
        share$vars$NdepTot <- NdepTot
    }
    if (!is.null(GrossNMinYr)) {
        share$vars$GrossNMinYr <- GrossNMinYr
    }
    if (!is.null(GrossNImmobYr)) {
        share$vars$GrossNImmobYr <- GrossNImmobYr
    }
    if (!is.null(SoilDecResp) && !is.null(SoilDecRespYr)) {
        share$vars$SoilDecResp <- SoilDecResp
        share$vars$SoilDecRespYr <- SoilDecRespYr
    }
    if (!is.null(NetCBal)) {
        share$vars$NetCBal <- NetCBal
    }
    if (!is.null(HON) && !is.null(HOM)) {
        share$vars$HON <- HON
        share$vars$HOM <- HOM
    }
    if (!is.null(PlantN) && !is.null(PlantNUptake)) {
        share$vars$PlantN <- PlantN
        share$vars$PlantNUptake <- PlantNUptake
        share$vars$PlantNUptakeYr <- PlantNUptakeYr
    }
    if (!is.null(NetNMin) && !is.null(NetNitrYr)) {
        share$vars$NetNMin <- NetNMin
        share$vars$NetNMinYr <- NetNMinYr
        share$vars$NetNitrYr <- NetNitrYr
    }

}