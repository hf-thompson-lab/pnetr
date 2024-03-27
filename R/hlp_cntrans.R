# ******************************************************************************
# CNTrans routine in PnET-CN
# 
# Author: Xiaojie Gao
# Date: 2023-10-09
# ******************************************************************************

#' Calculate root turnover rate (Aber et al 1997).
#' 
#' @param vegpar The vegetation parameter object.
#' @param netNmin Last year's N mineralization.
#' @param dayspan Current month's number of days.
#' @param BiomLossFrac Biome loss fraction due to disturbance
#'
#' @return Root turnover rate.
CalRootTurnoverRate <- function(vegpar, netNmin, dayspan, BiomLossFrac) {
    # Root turnover
    RootTurnover <- vegpar$RootTurnoverA - (vegpar$RootTurnoverB * netNmin) +
        (vegpar$RootTurnoverC * netNmin^2)
    
    # Max is 2.5, min is 0.1
    if (RootTurnover > 2.5) {
        RootTurnover <- 2.5
    } else if (RootTurnover < 0.1) {
        RootTurnover <- 0.1
    }

    RootTurnover <- RootTurnover * (dayspan / 365)

    if (RootTurnover < BiomLossFrac) {
        RootTurnover <- BiomLossFrac
    }

    return(RootTurnover)
}


#' CNTrans routine in PnET-CN
#' 
#' @description 
#' The following variables are calculated/updated:
#'   - HOM
#'   - HON
#'   - RootMass
#'   - RootMassN
#'   - WoodMass
#'   - WoodMassN
#'   - WoodDecResp
#'   - WoodDecRespYr
#'   - DeadWoodM
#'   - DeadWoodN
#'   - NetCBal
#'   - PlantN
#'   - FolLitM
#'   - FolMass
#'   - PlantC
#'   - TotalLitterM
#'   - TotalLitterMYr
#'   - TotalLitterN
#'   - TotalLitterNYr
#' 
#' @param climate_dt A table that contains monthly climate data.
#' @param sitepar A table that contains site-specific variables.
#' @param vegpar A table that contains vegetation-specific variables.
#' @param share The shared object containing intermittent variables.
#' @param rstep current time step
CNTrans <- function(climate_dt, sitepar, vegpar, share, rstep) {
    # Variables to update
    HOM <- share$vars$HOM
    HON <- share$vars$HON
    RootMass <- RootMassN <- NULL 
    WoodMass <- WoodMassN <- WoodDecResp <- WoodDecRespYr <- NULL
    DeadWoodM <- DeadWoodN <- NULL
    NetCBal <- NULL
    PlantN <- FolLitM <- FolMass <- PlantC <- NULL
    TotalLitterM <- TotalLitterMYr <- TotalLitterN <- TotalLitterNYr <- NULL

    # Some already calculated variables at this time step
    Dayspan <- share$logdt[rstep, Dayspan]
    DOY <- share$logdt[rstep, DOY]

    # Check for disturbance year
    BiomLossFrac <- 0
    RemoveFrac <- 0
    if (DOY > 335 && length(sitepar$distyear) > 0) {
        for (i in 1:length(sitepar$distyear)) {
            if (climate_dt[rstep, Year] == sitepar$distyear[i]) {
                BiomLossFrac <- sitepar$distintensity[i]
                RemoveFrac <- sitepar$distremove[i]
                HOM <- HOM * (1 - sitepar$distsoilloss[i])
                HON <- HON * (1 - sitepar$distsoilloss[i])
            }
            break
        }
    }

    # Root turnover rate
    RootTurnover <- CalRootTurnoverRate(
        vegpar, 
        share$vars$NetNMinLastYr, 
        Dayspan,
        BiomLossFrac
    )

    # Root litter mass and N
    RootLitM <- share$vars$RootMass * RootTurnover
    RootLitN <- RootLitM * (share$vars$RootMassN / share$vars$RootMass)
    # Update current root litter mass and N
    RootMass <- share$vars$RootMass - RootLitM
    RootMassN <- share$vars$RootMassN - RootLitN


    # Wood litter mass and N
    if (BiomLossFrac > 0) {
        WoodLitM <- share$vars$WoodMass * BiomLossFrac * (1 - RemoveFrac)
        WoodLitN <- share$vars$WoodMassN * BiomLossFrac * (1 - RemoveFrac)
        # Update wood litter mass and N
        WoodMass <- share$vars$WoodMass * (1 - BiomLossFrac)
        WoodMassN <- share$vars$WoodMassN * (1 - BiomLossFrac)
    } else {
        WoodLitM <- share$vars$WoodMass * vegpar$WoodTurnover * 
            (Dayspan / 365)
        WoodLitN <- share$vars$WoodMassN * vegpar$WoodTurnover * 
            (Dayspan / 365)
        # Update wood litter mass and N
        WoodMass <- share$vars$WoodMass - WoodLitM
        WoodMassN <- share$vars$WoodMassN - WoodLitN
    }

    # Update dead wood
    DeadWoodM <- share$vars$DeadWoodM + WoodLitM
    DeadWoodN <- share$vars$DeadWoodN + WoodLitN

    # Wood mass loss
    WoodMassLoss <- DeadWoodM * vegpar$WoodLitLossRate * 
        (Dayspan / 365)
    # Wood transfer
    WoodTransM <- WoodMassLoss * (1 - vegpar$WoodLitCLoss)
    
    WoodDecResp <- (WoodMassLoss - WoodTransM) * vegpar$CFracBiomass
    WoodDecRespYr <- share$vars$WoodDecRespYr + WoodDecResp

    WoodTransN <- (WoodMassLoss / DeadWoodM) * DeadWoodN
    
    DeadWoodM <- DeadWoodM - WoodMassLoss
    DeadWoodN <- DeadWoodN - WoodTransN

    # Update NetCBal
    NetCBal <- share$vars$NetCBal - WoodDecResp

    # Foliar N loss
    FolNLoss <- share$vars$FolLitM * (vegpar$FolNCon / 100)
    Retrans <- FolNLoss * vegpar$FolNRetrans
    PlantN <- share$vars$PlantN + Retrans
    FolLitN <- FolNLoss - Retrans
    FolLitM <- share$vars$FolLitM
    
    if (BiomLossFrac > 0) {
        FolLitM <- FolLitM + (share$vars$FolMass * BiomLossFrac)
        FolLitN <- FolLitN + (share$vars$FolMass * BiomLossFrac *
            (VegPar$FolNCon / 100))
        FolMass <- share$vars$FolMass * (1 - BiomLossFrac)
        PlantC <- share$vars$PlantC * (1 - BiomLossFrac)
        PlantN <- PlantN + (vegpar$MaxNStore - PlantN) * BiomLossFrac
    }

    TotalLitterM <- FolLitM + RootLitM + WoodTransM
    TotalLitterN <- FolLitN + RootLitN + WoodTransN

    # Agriculture, this is not in Aber et al 1997
    if (climate_dt[rstep, DOY] >= sitepar$agstart && 
        climate_dt[rstep, DOY] < sitepar$agstop
    ) {
        TotalLitterM <- TotalLitterM * (1 - sitepar$agrem)
        TotalLitterN <- TotalLitterN * (1 - sitepar$agrem)
        WoodMass <- WoodMass * (1 - sitepar$agrem * (Dayspan / 365))
        WoodMassN <- WoodMassN * (1 - sitepar$agrem * (Dayspan / 365))
    }

    TotalLitterMYr <- share$vars$TotalLitterMYr + TotalLitterM
    TotalLitterNYr <- share$vars$TotalLitterNYr + TotalLitterN


    # Update values
    if (!is.null(HOM)) {
        share$vars$HOM <- HOM
    }
    if (!is.null(HON)) {
        share$vars$HON <- HON
    }
    if (!is.null(RootMass) && !is.null(RootMassN)) {
        share$vars$RootMass <- RootMass
        share$vars$RootMassN <- RootMassN
    }
    if (!is.null(WoodMass) && !is.null(WoodMassN)) {
        share$vars$WoodMass <- WoodMass
        share$vars$WoodMassN <- WoodMassN
    }
    if (!is.null(WoodDecResp) && !is.null(WoodDecRespYr)) {
        share$vars$WoodDecResp <- WoodDecResp
        share$vars$WoodDecRespYr <- WoodDecRespYr
    }
    if (!is.null(DeadWoodM) && !is.null(DeadWoodN)) {
        share$vars$DeadWoodM <- DeadWoodM
        share$vars$DeadWoodN <- DeadWoodN
    }
    if (!is.null(NetCBal)) {
        share$vars$NetCBal <- NetCBal
    }
    if (!is.null(PlantN)) {
        share$vars$PlantN <- PlantN
    }
    if (!is.null(FolLitM)) {
        share$vars$FolLitM <- FolLitM
    }
    if (!is.null(FolMass)) {
        share$vars$FolMass <- FolMass
    }
    if (!is.null(PlantC)) {
        share$vars$PlantC <- PlantC
    }
    if (!is.null(TotalLitterM) && !is.null(TotalLitterMYr)) {
        share$vars$TotalLitterM <- TotalLitterM
        share$vars$TotalLitterMYr <- TotalLitterMYr
    }
    if (!is.null(TotalLitterN) && !is.null(TotalLitterNYr)) {
        share$vars$TotalLitterN <- TotalLitterN
        share$vars$TotalLitterNYr <- TotalLitterNYr
    }
    
}