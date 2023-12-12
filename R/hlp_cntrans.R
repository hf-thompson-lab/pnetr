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
    # Current time step
    currow <- share$dt[rstep, ]
    # Previous time step
    prerow <- if (rstep == 1) currow else share$dt[rstep - 1, ]

    # Number of days in the month
    dayspan <- currow$Dayspan

    # Check for disturbance year
    BiomLossFrac <- 0
    RemoveFrac <- 0
    if (climate_dt[rstep, DOY] > 335) {
        
        for (i in 1:length(sitepar$distyear)) {
            if (climate_dt[rstep, Year] == sitepar$distyear[i]) {
                BiomLossFrac <- sitepar$distintensity[i]
                RemoveFrac <- sitepar$distremove[i]
                currow$HOM <- prerow$HOM * (1 - sitepar$distsoilloss[i])
                currow$HON <- prerow$HON * (1 - sitepar$distsoilloss[i])
            }
            break
        }
    }

    # Root turnover rate
    RootTurnover <- CalRootTurnoverRate(vegpar, 
        share$NetNMinLastYr, 
        dayspan,
        BiomLossFrac
    )

    # Root litter mass and N
    RootLitM <- currow$RootMass * RootTurnover
    RootLitN <- RootLitM * (currow$RootMassN / currow$RootMass)
    # Update current root litter mass and N
    currow$RootMass <- currow$RootMass - RootLitM
    currow$RootMassN <- currow$RootMassN - RootLitN

    if (BiomLossFrac > 0) {
        WoodLitM <- currow$WoodMass * BiomLossFrac * (1 - RemoveFrac)
        WoodLitN <- currow$WoodMassN * BiomLossFrac * (1 - RemoveFrac)
        # Update wood litter mass and N
        currow$WoodMass <- currow$WoodMass * (1 - BiomLossFrac)
        currow$WoodMassN <- currow$WoodMassN * (1 - BiomLossFrac)
    } else {
        WoodLitM <- currow$WoodMass * vegpar$WoodTurnover * 
            (dayspan / 365)
        WoodLitN <- currow$WoodMassN * vegpar$WoodTurnover * 
            (dayspan / 365)
        # Update wood litter mass and N
        currow$WoodMass <- currow$WoodMass - WoodLitM
        currow$WoodMassN <- currow$WoodMassN - WoodLitN
    }

    # Update dead wood
    DeadWoodM <- prerow$DeadWoodM + WoodLitM
    DeadWoodN <- prerow$DeadWoodN + WoodLitN

    # Wood mass loss
    WoodMassLoss <- DeadWoodM * vegpar$WoodLitLossRate * 
        (dayspan / 365)
    # Wood transfer
    WoodTransM <- WoodMassLoss * (1 - vegpar$WoodLitCLoss)
    
    currow$WoodDecResp <- (WoodMassLoss - WoodTransM) * vegpar$CFracBiomass
    currow$WoodDecRespYr <- ifelse(currow$Year == prerow$Year,
        prerow$WoodDecRespYr + currow$WoodDecResp,
        currow$WoodDecRespYr + currow$WoodDecResp
    )
    WoodTransN <- (WoodMassLoss / DeadWoodM) * DeadWoodN
    
    currow$DeadWoodM <- DeadWoodM - WoodMassLoss
    currow$DeadWoodN <- DeadWoodN - WoodTransN

    # Update NetCBal
    currow$NetCBal <- currow$NetCBal - currow$WoodDecResp

    # Foliar N loss
    FolNLoss <- currow$FolLitM * (vegpar$FolNCon / 100)
    Retrans <- FolNLoss * vegpar$FolNRetrans
    currow$PlantN <- currow$PlantN + Retrans
    FolLitN <- FolNLoss - Retrans

    if (BiomLossFrac > 0) {
        currow$FolLitM <- currow$FolLitM + (currow$FolMass * BiomLossFrac)
        FolLitN <- FolLitN + (currow$FolMass * BiomLossFrac *
            (VegPar$FolNCon / 100))
        currow$FolMass <- currow$FolMass * (1 - BiomLossFrac)
        currow$PlantC <- currow$PlantC * (1 - BiomLossFrac)
        currow$PlantN <- currow$PlantN + (vegpar$MaxNStore - currow$PlantN) *
            BiomLossFrac
    }

    currow$TotalLitterM <- currow$FolLitM + RootLitM + WoodTransM
    currow$TotalLitterN <- FolLitN + RootLitN + WoodTransN

    # Agriculture, this is not in Aber et al 1997
    if (climate_dt[rstep, DOY] >= sitepar$agstart && 
        climate_dt[rstep, DOY] < sitepar$agstop
    ) {
        currow$TotalLitterM <- currow$TotalLitterM * (1 - sitepar$agrem)
        currow$TotalLitterN <- currow$TotalLitterN * (1 - sitepar$agrem)
        currow$WoodMass <- currow$WoodMass * (1 - sitepar$agrem * 
            (dayspan / 365))
        currow$WoodMassN <- currow$WoodMassN * (1 - sitepar$agrem * 
            (dayspan / 365))
    }

    currow$TotalLitterMYr <- ifelse(currow$Year == prerow$Year,
        prerow$TotalLitterMYr + currow$TotalLitterM,
        currow$TotalLitterMYr + currow$TotalLitterM
    )
    currow$TotalLitterNYr <- ifelse(currow$Year == prerow$Year,
        prerow$TotalLitterNYr + currow$TotalLitterN,
        currow$TotalLitterNYr + currow$TotalLitterN
    )


    return(currow)
}