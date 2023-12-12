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
    # Current time step
    currow <- share$dt[rstep, ]
    # Previous time step
    prerow <- if (rstep == 1) currow else share$dt[rstep - 1, ]

    dayspan <- currow$Dayspan

    # Atmospheric N deposition
    NO3 <- prerow$NO3 + climate_dt[rstep, NO3dep]
    NH4 <- prerow$NH4 + climate_dt[rstep, NH4dep]
    currow$NdepTot <- prerow$NdepTot + climate_dt[rstep, NO3dep] + 
        climate_dt[rstep, NH4dep]

    # Temperature effect on all soil processes
    tEffSoil <- max(currow$Tavg, 1)

    HOM <- prerow$HOM + currow$TotalLitterM
    HON <- prerow$HON + currow$TotalLitterN

    TMult <- (exp(0.1 * (currow$Tavg - 7.1)) * 0.68) * 1;
    WMult <- currow$MeanSoilMoistEff
    KhoAct <- vegpar$Kho * (dayspan / 365)
    DHO <- HOM * (1 - exp(-KhoAct * TMult * WMult))

    GrossNMin <- DHO * (HON / HOM)
    currow$GrossNMinYr <- ifelse(currow$Year == prerow$Year,
        prerow$GrossNMinYr + GrossNMin,
        currow$GrossNMinYr + GrossNMin
    )
    currow$SoilDecResp <- DHO * vegpar$CFracBiomass
    currow$SoilDecRespYr <- ifelse(currow$Year == prerow$Year,
        prerow$SoilDecRespYr + currow$SoilDecResp,
        currow$SoilDecRespYr + currow$SoilDecResp
    )

    # Update HON and HOM
    HON <- HON - GrossNMin
    HOM <- HOM - DHO

    currow$NetCBal <- currow$NetCBal - currow$SoilDecResp

    # Immobilization and net mineralization
    SoilPctN <- (HON / HOM) * 100
    NReten <- (vegpar$NImmobA + vegpar$NImmobB * SoilPctN) / 100
    GrossNImmob <- NReten * GrossNMin
    currow$GrossNImmobYr <- ifelse(currow$Year == prerow$Year,
        prerow$GrossNImmobYr + GrossNImmob,
        currow$GrossNImmobYr + GrossNImmob
    )
    # Update HON and HOM again
    currow$HON <- HON + GrossNImmob
    currow$HOM <- HOM

    # Net mineralization
    NetNMin <- GrossNMin - GrossNImmob

    # Update NH4
    NH4 <- NH4 + NetNMin
    NetNitr <- NH4 * currow$NRatioNit
    NO3 <- NO3 + NetNitr
    NH4 <- NH4 - NetNitr

    # Plant uptake
    RootNSinkStr <- min(prerow$RootNSinkEff * TMult, 0.98)
    PlantNUptake <- (NH4 + NO3) * RootNSinkStr
    if ((PlantNUptake + currow$PlantN) > vegpar$MaxNStore) {
        PlantNUptake <- vegpar$MaxNStore - currow$PlantN
        RootNSinkStr <- PlantNUptake / (NO3 + NH4)
    }

    if (PlantNUptake < 0) {
        PlantNUptake <- 0
        RootNSinkStr <- 0
    }
    currow$PlantN <- currow$PlantN + PlantNUptake
    currow$PlantNUptakeYr <- ifelse(currow$Year == prerow$Year,
        prerow$PlantNUptakeYr + PlantNUptake,
        currow$PlantNUptakeYr + PlantNUptake
    )

    NH4Up <- NH4 * RootNSinkStr
    currow$NH4 <- NH4 - NH4Up
    NO3Up <- NO3 * RootNSinkStr
    currow$NO3 <- NO3 - NO3Up

    currow$NetNMinYr <- ifelse(currow$Year == prerow$Year,
        prerow$NetNMinYr + NetNMin,
        currow$NetNMinYr + NetNMin
    )
    currow$NetNitrYr <- ifelse(currow$Year == prerow$Year,
        prerow$NetNitrYr + NetNitr,
        currow$NetNitrYr + NetNitr
    )

    return(currow)
}