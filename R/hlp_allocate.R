# ******************************************************************************
# Carbon allocation
# 
# Author: Xiaojie Gao
# Date: 2023-08-20
# ******************************************************************************


#' Monthly C and/or N allocation for the PnET model
#' 
#' @description
#' The following variables are calculated/updated:
#' - BudC
#' - WoodC
#' - RootC
#' - PlantC
#' - WoodMRespYr
#' - FolProdCYr
#' - FolGRespYr
#' - GDDWoodEff
#' - WoodProdCYr
#' - WoodGRespYr
#' - RootProdCYr
#' - RootMRespYr
#' - RootGRespYr
#' - NetCBal
#' --- For PnET-CN ---
#'     - WoodMass
#'     - WoodMassN
#'     - RootMass
#'     - RootMassN
#'     - PlantN
#' 
#' @param sitepar A table that contains site-specific variables.
#' @param vegpar A table that contains vegetation-specific variables.
#' @param share The shared object containing intermittent variables.
#' @param rstep current time step
AllocateMon <- function(sitepar, vegpar, share, rstep, model = "pnet-ii") {
    # Current time step
    currow <- share$dt[rstep, ]
    # Previous time step
    prerow <- if (rstep == 1) currow else share$dt[rstep - 1, ]

    if (model %in% c("pnet-ii")) {
        # Since C allocation to bud, wood, and root happens annually, here for
        # the monthly scale, their previous values should be propogated.
        currow$BudC <- prerow$BudC
        currow$WoodC <- prerow$WoodC
        currow$RootC <- prerow$RootC
        currow$RootC <- prerow$RootC
    }

    # Update plant C pool
    if (model == "pnet-cn") {
        currow$PlantC <- currow$PlantC + currow$NetPsnMo - currow$FolGRespMo
    } else {
        currow$PlantC <- prerow$PlantC + currow$NetPsnMo - currow$FolGRespMo
    }
    
    # Wood maintenance respiration
    WoodMRespMo <- currow$CanopyGrossPsnActMo * vegpar$WoodMRespA
    currow$WoodMRespYr <- ifelse(currow$Year == prerow$Year,
        prerow$WoodMRespYr + WoodMRespMo,
        currow$WoodMRespYr + WoodMRespMo
    )
    
    # Foliar C production
    currow$FolProdCYr <- ifelse(currow$Year == prerow$Year,
        prerow$FolProdCYr + currow$FolProdCMo,
        currow$FolProdCYr + currow$FolProdCMo
    )
    # Foliar C growth respiration
    currow$FolGRespYr <- ifelse(currow$Year == prerow$Year, 
        prerow$FolGRespYr + currow$FolGRespMo,
        currow$FolGRespYr + currow$FolGRespMo
    )

    # Update Wood carbon production and growth respiration
    WoodProdCMo <- 0
    WoodGRespMo <- 0
    # Wood production only happens within the growing season
    if (currow$GDDTot >= vegpar$GDDWoodStart) {
        # Growing degree day effect on wood production
        GDDWoodEff <- (currow$GDDTot - vegpar$GDDWoodStart) / 
            (vegpar$GDDWoodEnd - vegpar$GDDWoodStart)
        currow$GDDWoodEff <- max(0, min(1.0, GDDWoodEff))
        delGDDWoodEff <- currow$GDDWoodEff - prerow$GDDWoodEff
        WoodProdCMo <- currow$WoodC * delGDDWoodEff
        # Wood growth respiration is a fraction of wood production
        WoodGRespMo <- WoodProdCMo * vegpar$GRespFrac

        currow$WoodProdCYr <- ifelse(currow$Year == prerow$Year, 
            prerow$WoodProdCYr + WoodProdCMo,
            currow$WoodProdCYr + WoodProdCMo
        )
        currow$WoodGRespYr <- ifelse(currow$Year == prerow$Year,
            prerow$WoodGRespYr + WoodGRespMo,
            currow$WoodGRespYr + WoodGRespMo
        )
    }

    # Root C production
    # We first calculate a prorated root production for this month based on the
    # foliar production of this month. Then, we calculate the montly root C
    # production. # TODO: comment incomplete.
    TMult <- exp(0.1 * (currow$Tavg - 7.1)) * 0.68
    RootCAdd <- vegpar$RootAllocA * (currow$Dayspan / 365.0) + 
        vegpar$RootAllocB * currow$FolProdCMo
    
    currow$RootC <- prerow$RootC + RootCAdd
    
    RootAllocCMo <- min(1.0, ((1.0 / 12.0) * TMult)) * currow$RootC
    currow$RootC <- currow$RootC - RootAllocCMo

    # Root C productioon
    RootProdCMo <- RootAllocCMo / 
        (1.0 + vegpar$RootMRespFrac + vegpar$GRespFrac)
    
    currow$RootProdCYr <- ifelse(currow$Year == prerow$Year,
        prerow$RootProdCYr + RootProdCMo,
        currow$RootProdCYr + RootProdCMo
    )
    
    # Root C maintenance respiration
    RootMRespMo <- RootProdCMo * vegpar$RootMRespFrac
    currow$RootMRespYr <- ifelse(currow$Year == prerow$Year,
        prerow$RootMRespYr + RootMRespMo,
        currow$RootMRespYr + RootMRespMo
    )
    # Root C growth respiration
    RootGRespMo <- RootProdCMo * vegpar$GRespFrac
    currow$RootGRespYr <- ifelse(currow$Year == prerow$Year,
        prerow$RootGRespYr + RootGRespMo,
        currow$RootGRespYr + RootGRespMo
    )
    
    # Update plant C pool
    currow$PlantC <- currow$PlantC - RootCAdd - WoodMRespMo - WoodGRespMo

    # Calculate net C balance
    currow$NetCBal <- currow$NetPsnMo - currow$SoilRespMo - 
        WoodMRespMo - WoodGRespMo - currow$FolGRespMo

    if (model == "pnet-cn") {
        # These values only change once a year, should be passed along steps
        
        if (currow$DOY >= prerow$DOY) {
            currow$NRatio <- prerow$NRatio
            currow$RootNSinkEff <- prerow$RootNSinkEff
            currow$NRatioNit <- prerow$NRatioNit

            currow$WoodMass <- prerow$WoodMass + (WoodProdCMo / vegpar$CFracBiomass)
            currow$WoodMassN <- prerow$WoodMassN +
                ((WoodProdCMo / vegpar$CFracBiomass) * vegpar$WLPctN * currow$NRatio)

            currow$RootMass <- prerow$RootMass + (RootProdCMo / vegpar$CFracBiomass)
            currow$RootMassN <- prerow$RootMassN +
                ((RootProdCMo / vegpar$CFracBiomass) * vegpar$RLPctN * currow$NRatio)

            PlantN <- prerow$PlantN -
                ((WoodProdCMo / vegpar$CFracBiomass) * vegpar$WLPctN * currow$NRatio)
            currow$PlantN <- PlantN -
                ((RootProdCMo / vegpar$CFracBiomass) * vegpar$RLPctN * currow$NRatio)

            currow$NetCBal <- currow$NetPsnMo - WoodMRespMo - WoodGRespMo -
                currow$FolGRespMo - RootMRespMo - RootGRespMo
        } else {
            currow$WoodMass <- prerow$WoodMass + (WoodProdCMo / vegpar$CFracBiomass)
            currow$WoodMassN <- prerow$WoodMassN +
                ((WoodProdCMo / vegpar$CFracBiomass) * vegpar$WLPctN * currow$NRatio)

            currow$RootMass <- prerow$RootMass + (RootProdCMo / vegpar$CFracBiomass)
            currow$RootMassN <- prerow$RootMassN +
                ((RootProdCMo / vegpar$CFracBiomass) * vegpar$RLPctN * currow$NRatio)

            PlantN <- currow$PlantN -
                ((WoodProdCMo / vegpar$CFracBiomass) * vegpar$WLPctN * currow$NRatio)
            currow$PlantN <- PlantN -
                ((RootProdCMo / vegpar$CFracBiomass) * vegpar$RLPctN * currow$NRatio)

            currow$NetCBal <- currow$NetPsnMo - WoodMRespMo - WoodGRespMo -
                currow$FolGRespMo - RootMRespMo - RootGRespMo
        }

        
    }

    return(currow)
}


#' Annual C and/or N allocation
#'
#' @description
#' The following variables are calculated/updated:
#' - BudC
#' - WoodC
#' - RootC
#' - PlantC
#' - NPPFolYr
#' - NPPWoodYr
#' - NPPRootYr
#' - FolMassMax (in VegPar)
#' - FolMassMin (in VegPar)
#' - NEP
#' --- For PnET-CN only ---
#'     - WoodMass
#'     - WoodMassN
#'     - RootMass
#'     - RootMassN
#'     - FolNCon (in VegPar)
#'     - PlantN
#'     - NH4
#'     - NRatio
#'     - RootNSinkEff
#'     - FolN
#'     - FolC
#'     - TotalN
#'     - TotalM
#'
#' @param sitepar A table that contains site-specific variables.
#' @param vegpar A table that contains vegetation-specific variables.
#' @param share The shared object containing intermittent variables.
#' @param rstep current time step
AllocateYr <- function(sitepar, vegpar, share, rstep, model = "pnet-ii") {
    # Current time step
    currow <- share$dt[rstep, ]
    # Previous time step
    prerow <- if (rstep == 1) currow else share$dt[rstep - 1, ]

    currow$NPPFolYr <- currow$FolProdCYr / vegpar$CFracBiomass
    currow$NPPWoodYr <- currow$WoodProdCYr / vegpar$CFracBiomass
    currow$NPPRootYr <- currow$RootProdCYr / vegpar$CFracBiomass

    AvgDWater <- ifelse(currow$DwaterIx > 0, 
        currow$Dwatertot / currow$DwaterIx,
        1
    )

    avgPCBM <- ifelse(currow$PosCBalMassIx > 0,
        currow$PosCBalMassTot / currow$PosCBalMassIx,
        currow$FolMass
    )

    EnvMaxFol <- (AvgDWater * avgPCBM) * 
        (1 + (vegpar$FolRelGrowMax * share$LightEffMin))
    SppMaxFol <- avgPCBM * (1 + vegpar$FolRelGrowMax * share$LightEffMin)
    vegpar$FolMassMax <- min(EnvMaxFol, SppMaxFol)
    vegpar$FolMassMin <- vegpar$FolMassMax - 
        vegpar$FolMassMax * (1 / vegpar$FolReten)
    
    currow$BudC <- max(
        0, 
        (vegpar$FolMassMax - currow$FolMass) * vegpar$CFracBiomass
    )
    
    currow$PlantC <- currow$PlantC - currow$BudC
    currow$WoodC <- (1 - vegpar$PlantCReserveFrac) * currow$PlantC
    currow$PlantC <- currow$PlantC - currow$WoodC

    if (currow$WoodC < (vegpar$MinWoodFolRatio * currow$BudC)) {
        TotalC <- currow$WoodC + currow$BudC
        currow$WoodC <- TotalC * (
            vegpar$MinWoodFolRatio / (1 + vegpar$MinWoodFolRatio)
        )
        vegpar$FolMassMax <- currow$FolMass + currow$BudC / vegpar$CFracBiomass
        vegpar$FolMassMin <- vegpar$FolMassMax - 
            vegpar$FolMassMin * (1 / vegpar$FolReten)
    }

    currow$NEP <- currow$TotPsn - currow$WoodMRespYr - currow$WoodGRespYr - 
        currow$FolGRespYr - currow$SoilRespYr


    if (model == "pnet-cn") {
        if (currow$PlantN > vegpar$MaxNStore) {
            currow$PlantN <- vegpar$MaxNStore
            currow$NH4 <- currow$NH4 + (currow$PlantN - vegpar$MaxNStore)
        }
        # Calculate NRatio
        NRatio <- 1 + (currow$PlantN / vegpar$MaxNStore) * vegpar$FolNConRange
        if (NRatio < 1) {
            NRatio <- 1
        } else if (NRatio > (1 + vegpar$FolNConRange)) {
            NRatio <- (1 + vegpar$FolNConRange)
        }

        # Calculate Bud N
        BudN <- (currow$BudC / vegpar$CFracBiomass) * vegpar$FLPctN * 
            (1 / (1 - vegpar$FolNRetrans)) * NRatio
        if (BudN > currow$PlantN) {
            if (currow$PlantN < 0) {
                BudC <- currow$BudC * 0.1
                BudN <- BudN * 0.1
            } else {
                BudC <- currow$BudC * (currow$PlantN / BudN)
                BudN <- BudN * (currow$PlantN / BudN)
            }
        }

        # Foliar 
        folnconnew <- (currow$FolMass * (vegpar$FolNCon / 100) + BudN) /
            (currow$FolMass + (currow$BudC / vegpar$CFracBiomass)) * 100
        vegpar$FolNCon <- folnconnew

        PlantN <- currow$PlantN - BudN
        
        # Nitro
        NRatioNit <- 0
        if (NRatio >= 1) {
            nr <- max(0, NRatio - 1 - (vegpar$FolNConRange / 3))
            NRatioNit <- min(1, (nr / (0.6667 * vegpar$FolNConRange))^2)
        }
        currow$NRatioNit <- NRatioNit

        if (PlantN > vegpar$MaxNStore) {
            NH4 <- currow$NH4 + (PlantN - vegpar$MaxNStore)
            PlantN <- vegpar$MaxNStore
        }

        # Update variables
        currow$NRatio <- NRatio
        currow$PlantN <- PlantN
        currow$RootNSinkEff <- sqrt(1 - (PlantN / vegpar$MaxNStore))
        
        # Annual total variable for PnET-CN
        currow$NEP <- currow$TotPsn - currow$SoilDecRespYr - 
            currow$WoodDecRespYr - currow$WoodMRespYr - currow$WoodGRespYr - 
            currow$FolGRespYr - currow$RootMRespYr - currow$RootGRespYr
            
        currow$FolN <- currow$FolMass * vegpar$FolNCon / 100

        currow$FolC <- currow$FolMass * vegpar$CFracBiomass

        currow$TotalN <- currow$FolN + currow$WoodMassN + currow$RootMassN + 
            currow$HON + currow$NH4 + currow$NO3 + currow$BudN + 
            currow$DeadWoodN + currow$PlantN

        currow$TotalM <- (currow$BudC / vegpar$CFracBiomass) + currow$FolMass + 
            (currow$WoodMass + currow$WoodC / vegpar$CFracBiomass) + 
            currow$RootMass + currow$DeadWoodM + currow$HOM + 
            (currow$PlantC / vegpar$CFracBiomass) + 
            (currow$RootC / vegpar$CFracBiomass)
        
        share$NetNMinLastYr <- currow$NetNMinYr
    }

    return(currow)
}





AllocateYrPre <- function(sitepar, vegpar, share, rstep, model = "pnet-ii") {
    # B/c we start allocation in the first month of every year, here the
    # variables updated from last year are stored in the `prerow`.

    # Current time step
    currow <- share$dt[rstep, ]
    # Previous time step
    prerow <- if (rstep == 1) currow else share$dt[rstep - 1, ]

    # Inherit some variables
    # currow$BudC <- prerow$BudC
    # currow$WoodC <- prerow$WoodC
    # currow$RootC <- prerow$RootC
    # currow$PlantC <- prerow$PlantC

    currow$NPPFolYr <- prerow$FolProdCYr / vegpar$CFracBiomass
    currow$NPPWoodYr <- prerow$WoodProdCYr / vegpar$CFracBiomass
    currow$NPPRootYr <- prerow$RootProdCYr / vegpar$CFracBiomass

    if (model == "pnet-cn") {
        currow$PlantN <- prerow$PlantN
        currow$BudN <- prerow$BudN
        # currow$NH4 <- prerow$NH4
        # currow$NRatioNit <- prerow$NRatioNit
    }

    AvgDWater <- ifelse(prerow$DwaterIx > 0, 
        prerow$Dwatertot / prerow$DwaterIx,
        1
    )

    avgPCBM <- ifelse(prerow$PosCBalMassIx > 0,
        prerow$PosCBalMassTot / prerow$PosCBalMassIx,
        prerow$FolMass
    )

    EnvMaxFol <- (AvgDWater * avgPCBM) * 
        (1 + (vegpar$FolRelGrowMax * share$LightEffMin))
    SppMaxFol <- avgPCBM * (1 + vegpar$FolRelGrowMax * share$LightEffMin)
    vegpar$FolMassMax <- min(EnvMaxFol, SppMaxFol)
    vegpar$FolMassMin <- vegpar$FolMassMax - 
        vegpar$FolMassMax * (1 / vegpar$FolReten)
    
    currow$BudC <- max(
        0, 
        (vegpar$FolMassMax - prerow$FolMass) * vegpar$CFracBiomass
    )
    
    currow$PlantC <- currow$PlantC - currow$BudC
    currow$WoodC <- (1 - vegpar$PlantCReserveFrac) * currow$PlantC
    currow$PlantC <- currow$PlantC - currow$WoodC

    if (currow$WoodC < (vegpar$MinWoodFolRatio * currow$BudC)) {
        TotalC <- currow$WoodC + currow$BudC
        currow$WoodC <- TotalC * (
            vegpar$MinWoodFolRatio / (1 + vegpar$MinWoodFolRatio)
        )
        vegpar$FolMassMax <- currow$FolMass + currow$BudC / vegpar$CFracBiomass
        vegpar$FolMassMin <- vegpar$FolMassMax - 
            vegpar$FolMassMin * (1 / vegpar$FolReten)
    }

    currow$NEP <- prerow$TotPsn - prerow$WoodMRespYr - prerow$WoodGRespYr - 
        prerow$FolGRespYr - prerow$SoilRespYr


    if (model == "pnet-cn") {
        if (currow$PlantN > vegpar$MaxNStore) {
            currow$PlantN <- vegpar$MaxNStore
            currow$NH4 <- prerow$NH4 + (prerow$PlantN - vegpar$MaxNStore)
        }

        # Calculate NRatio
        NRatio <- 1 + (currow$PlantN / vegpar$MaxNStore) * vegpar$FolNConRange
        if (NRatio < 1) {
            NRatio <- 1
        } else if (NRatio > (1 + vegpar$FolNConRange)) {
            NRatio <- (1 + vegpar$FolNConRange)
        }

        # Calculate Bud N
        BudN <- (currow$BudC / vegpar$CFracBiomass) * vegpar$FLPctN * 
            (1 / (1 - vegpar$FolNRetrans)) * NRatio
        if (BudN > currow$PlantN) {
            if (currow$PlantN < 0) {
                BudC <- currow$BudC * 0.1
                BudN <- BudN * 0.1
            } else {
                BudC <- currow$BudC * (currow$PlantN / BudN)
                BudN <- BudN * (currow$PlantN / BudN)
            }
        }
        currow$BudN <- BudN

        # Foliar 
        folnconnew <- (prerow$FolMass * (vegpar$FolNCon / 100) + BudN) /
            (prerow$FolMass + (currow$BudC / vegpar$CFracBiomass)) * 100
        vegpar$FolNCon <- folnconnew

        PlantN <- currow$PlantN - BudN
        
        # Nitro
        NRatioNit <- 0
        if (NRatio >= 1) {
            nr <- max(0, NRatio - 1 - (vegpar$FolNConRange / 3))
            NRatioNit <- min(1, (nr / (0.6667 * vegpar$FolNConRange))^2)
        }
        currow$NRatioNit <- NRatioNit

        if (PlantN > vegpar$MaxNStore) {
            NH4 <- currow$NH4 + (PlantN - vegpar$MaxNStore)
            PlantN <- vegpar$MaxNStore
        }

        # Update variables
        currow$NRatio <- NRatio
        currow$PlantN <- PlantN
        currow$RootNSinkEff <- sqrt(1 - (PlantN / vegpar$MaxNStore))
        
        # Annual total variable for PnET-CN
        currow$NEP <- prerow$TotPsn - prerow$SoilDecRespYr - 
            prerow$WoodDecRespYr - prerow$WoodMRespYr - prerow$WoodGRespYr - 
            prerow$FolGRespYr - prerow$RootMRespYr - prerow$RootGRespYr
            
        currow$FolN <- prerow$FolMass * vegpar$FolNCon / 100

        currow$FolC <- prerow$FolMass * vegpar$CFracBiomass

        currow$TotalN <- currow$FolN + prerow$WoodMassN + prerow$RootMassN + 
            prerow$HON + prerow$NH4 + prerow$NO3 + currow$BudN + 
            prerow$DeadWoodN + currow$PlantN

        currow$TotalM <- (currow$BudC / vegpar$CFracBiomass) + prerow$FolMass + 
            (prerow$WoodMass + currow$WoodC / vegpar$CFracBiomass) + 
            prerow$RootMass + prerow$DeadWoodM + prerow$HOM + 
            (currow$PlantC / vegpar$CFracBiomass) + 
            (currow$RootC / vegpar$CFracBiomass)
        
        share$NetNMinLastYr <- currow$NetNMinYr
    }

    return(currow)
}


