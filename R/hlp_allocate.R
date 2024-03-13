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
    # Variables to update
    RootC <- PlantC <- NULL
    WoodMRespYr <- RootGRespYr <- FolProdCYr <- FolGRespYr <- NULL
    GDDWoodEff <- NULL
    WoodProdCYr <- WoodGRespYr <- RootProdCYr <- RootMRespYr <- NULL
    NetCBal <- NULL
    # For PnET-CN
    WoodMass <- WoodMassN <- RootMass <- RootMassN <- PlantN <- NULL

    # Some already calculated variables at this time step
    GDDTot <- share$logdt[rstep, GDDTot]
    Tavg <- share$logdt[rstep, Tavg]
    Dayspan <- share$logdt[rstep, Dayspan]


    # Update plant C pool
    PlantC <- share$vars$PlantC + share$vars$NetPsnMo - share$vars$FolGRespMo
    
    # Wood maintenance respiration
    WoodMRespMo <- share$vars$CanopyGrossPsnActMo * vegpar$WoodMRespA
    WoodMRespYr <- share$vars$WoodMRespYr + WoodMRespMo
    # Foliar C production
    FolProdCYr <- share$vars$FolProdCYr + share$vars$FolProdCMo
    # Foliar C growth respiration
    FolGRespYr <- share$vars$FolGRespYr + share$vars$FolGRespMo

    # Update Wood carbon production and growth respiration
    WoodProdCMo <- 0
    WoodGRespMo <- 0
    # Wood production only happens within the growing season
    if (GDDTot >= vegpar$GDDWoodStart) {
        # Growing degree day effect on wood production
        GDDWoodEff <- (GDDTot - vegpar$GDDWoodStart) / 
            (vegpar$GDDWoodEnd - vegpar$GDDWoodStart)
        GDDWoodEff <- max(0, min(1.0, GDDWoodEff))
        delGDDWoodEff <- GDDWoodEff - share$vars$GDDWoodEff
        WoodProdCMo <- share$vars$WoodC * delGDDWoodEff
        # Wood growth respiration is a fraction of wood production
        WoodGRespMo <- WoodProdCMo * vegpar$GRespFrac

        WoodProdCYr <- share$vars$WoodProdCYr + WoodProdCMo
        WoodGRespYr <- share$vars$WoodGRespYr + WoodGRespMo
    }

    # Root C production
    # We first calculate a prorated root production for this month based on the
    # foliar production of this month. Then, we calculate the montly root C
    # production. # TODO: comment incomplete.
    TMult <- exp(0.1 * (Tavg - 7.1)) * 0.68
    RootCAdd <- vegpar$RootAllocA * (Dayspan / 365.0) + 
        vegpar$RootAllocB * share$vars$FolProdCMo
    RootC <- share$vars$RootC + RootCAdd
    
    RootAllocCMo <- min(1.0, ((1.0 / 12.0) * TMult)) * RootC
    RootC <- RootC - RootAllocCMo

    # Root C productioon
    RootProdCMo <- RootAllocCMo / 
        (1.0 + vegpar$RootMRespFrac + vegpar$GRespFrac)
    RootProdCYr <- share$vars$RootProdCYr + RootProdCMo
    
    # Root C maintenance respiration
    RootMRespMo <- RootProdCMo * vegpar$RootMRespFrac
    RootMRespYr <- share$vars$RootMRespYr + RootMRespMo
    
    # Root C growth respiration
    RootGRespMo <- RootProdCMo * vegpar$GRespFrac
    RootGRespYr <- share$vars$RootGRespYr + RootGRespMo
    
    # Update plant C pool
    PlantC <- PlantC - RootCAdd - WoodMRespMo - WoodGRespMo

    # Calculate net C balance
    NetCBal <- share$vars$NetPsnMo - share$vars$SoilRespMo - 
        WoodMRespMo - WoodGRespMo - share$vars$FolGRespMo


    if (model == "pnet-cn") {
        WoodMass <- share$vars$WoodMass + WoodProdCMo / vegpar$CFracBiomass
        WoodMassN <- share$vars$WoodMassN + (
            (WoodProdCMo / vegpar$CFracBiomass) * 
            vegpar$WLPctN * share$vars$NRatio
        )
        
        PlantN <- share$vars$PlantN - (
            (WoodProdCMo / vegpar$CFracBiomass) * 
            vegpar$WLPctN * share$vars$NRatio
        )
        RootMass <- share$vars$RootMass + (RootProdCMo / vegpar$CFracBiomass)
        RootMassN <- share$vars$RootMassN + (
            (RootProdCMo / vegpar$CFracBiomass) * 
            vegpar$RLPctN * share$vars$NRatio
        )
        PlantN <- PlantN - (
            (RootProdCMo / vegpar$CFracBiomass) * 
            vegpar$RLPctN * share$vars$NRatio
        )

        NetCBal <- share$vars$NetPsnMo - WoodMRespMo - WoodGRespMo - 
            share$vars$FolGRespMo - RootMRespMo - RootGRespMo
    }


    # Update variables
    share$vars$RootC <- RootC
    share$vars$PlantC <- PlantC
    
    share$vars$WoodMRespYr <- WoodMRespYr
    share$vars$RootGRespYr <- RootGRespYr
    share$vars$FolProdCYr <- FolProdCYr
    share$vars$FolGRespYr <- FolGRespYr
    
    if (!is.null(GDDWoodEff)) {
        share$vars$GDDWoodEff <- GDDWoodEff
    }
    if (!is.null(WoodProdCYr)) {
        share$vars$WoodProdCYr <- WoodProdCYr
    }
    if (!is.null(WoodGRespYr)) {
        share$vars$WoodGRespYr <- WoodGRespYr
    }
    share$vars$RootProdCYr <- RootProdCYr
    share$vars$RootMRespYr <- RootMRespYr
    share$vars$NetCBal <- NetCBal
    
    # For PnET-CN
    if (model == "pnet-cn") {
        share$vars$WoodMass <- WoodMass
        share$vars$WoodMassN <- WoodMassN
        share$vars$RootMass <- RootMass
        share$vars$RootMassN <- RootMassN
        share$vars$PlantN <- PlantN
    }
}



#' Annual C and/or N allocation
#'
#' @description
#' The following variables are calculated/updated:
#' - BudC
#' - WoodC
#' - PlantC
#' - NPPFolYr
#' - NPPWoodYr
#' - NPPRootYr
#' - FolMassMax (in VegPar)
#' - FolMassMin (in VegPar)
#' - NEP
#' --- For PnET-CN only ---
#'     - PlantN
#'     - FolNCon (in VegPar)
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
    # Variables to update
    BudC <- WoodC <- PlantC <- NULL
    NPPFolYr <- NPPWoodYr <- NPPRootYr <- NULL
    FolMassMax <- FolMassMin <- NULL # in VegPar
    NEP <- NULL
    
    # Save current foliar N for output b/c later vegpar$FolNCon will be updated
    FolNConOld <- vegpar$FolNCon

    # For PnET-CN
    if (model == "pnet-cn") {
        PlantN <- share$vars$PlantN
        FolN <- FolC <- NULL
        NH4 <- share$vars$NH4
        BudN <- NULL
        TotalN <- TotalM <- NULL
        NRatioNit <- 0
    }

    NPPFolYr <- share$vars$FolProdCYr / vegpar$CFracBiomass
    NPPWoodYr <- share$vars$WoodProdCYr / vegpar$CFracBiomass
    NPPRootYr <- share$vars$RootProdCYr / vegpar$CFracBiomass

    AvgDWater <- ifelse(share$vars$DWaterIx > 0, 
        share$vars$DWatertot / share$vars$DWaterIx,
        1
    )

    avgPCBM <- ifelse(share$vars$PosCBalMassIx > 0,
        share$vars$PosCBalMassTot / share$vars$PosCBalMassIx,
        share$vars$FolMass
    )

    EnvMaxFol <- (AvgDWater * avgPCBM) * 
        (1 + (vegpar$FolRelGrowMax * share$vars$LightEffMin))
    SppMaxFol <- avgPCBM * (1 + vegpar$FolRelGrowMax * share$vars$LightEffMin)
    vegpar$FolMassMax <- min(EnvMaxFol, SppMaxFol)
    vegpar$FolMassMin <- vegpar$FolMassMax - 
        vegpar$FolMassMax * (1 / vegpar$FolReten)
    
    BudC <- max(
        0, 
        (vegpar$FolMassMax - share$vars$FolMass) * vegpar$CFracBiomass
    )

    PlantC <- share$vars$PlantC - BudC
    WoodC <- (1 - vegpar$PlantCReserveFrac) * PlantC
    PlantC <- PlantC - WoodC

    if (WoodC < (vegpar$MinWoodFolRatio * BudC)) {
        TotalC <- WoodC + BudC
        WoodC <- TotalC * (
            vegpar$MinWoodFolRatio / (1 + vegpar$MinWoodFolRatio)
        )
        vegpar$FolMassMax <- share$vars$FolMass + BudC / vegpar$CFracBiomass
        vegpar$FolMassMin <- vegpar$FolMassMax - 
            vegpar$FolMassMin * (1 / vegpar$FolReten)
    }

    NEP <- share$vars$TotPsn - share$vars$WoodMRespYr - share$vars$WoodGRespYr - 
        share$vars$FolGRespYr - share$vars$SoilRespYr


    if (model == "pnet-cn") {
        if (PlantN > vegpar$MaxNStore) {
            PlantN <- vegpar$MaxNStore
            NH4 <- NH4 + (PlantN - vegpar$MaxNStore)
        }
        # Calculate NRatio
        NRatio <- 1 + (PlantN / vegpar$MaxNStore) * vegpar$FolNConRange
        if (NRatio < 1) {
            NRatio <- 1
        } else if (NRatio > (1 + vegpar$FolNConRange)) {
            NRatio <- (1 + vegpar$FolNConRange)
        }

        # Calculate Bud N
        BudN <- (BudC / vegpar$CFracBiomass) * vegpar$FLPctN * 
            (1 / (1 - vegpar$FolNRetrans)) * NRatio
        if (BudN > PlantN) {
            if (PlantN < 0) {
                BudC <- BudC * 0.1
                BudN <- BudN * 0.1
            } else {
                BudC <- BudC * (PlantN / BudN)
                BudN <- BudN * (PlantN / BudN)
            }
        }

        # Foliar 
        folnconnew <- (share$vars$FolMass * (vegpar$FolNCon / 100) + BudN) /
            (share$vars$FolMass + (BudC / vegpar$CFracBiomass)) * 100
        # HACK: I don't quite like this b/c it changes the input value
        vegpar$FolNCon <- folnconnew

        PlantN <- PlantN - BudN
        
        # Nitro
        if (NRatio >= 1) {
            nr <- max(0, NRatio - 1 - (vegpar$FolNConRange / 3))
            NRatioNit <- min(1, (nr / (0.6667 * vegpar$FolNConRange))^2)
        }

        if (PlantN > vegpar$MaxNStore) {
            NH4 <- share$vars$NH4 + (PlantN - vegpar$MaxNStore)
            PlantN <- vegpar$MaxNStore
        }

        RootNSinkEff <- sqrt(1 - (PlantN / vegpar$MaxNStore))
        
        # Annual total variable for PnET-CN
        NEP <- share$vars$TotPsn - share$vars$SoilDecRespYr - 
            share$vars$WoodDecRespYr - share$vars$WoodMRespYr - 
            share$vars$WoodGRespYr - 
            share$vars$FolGRespYr - 
            share$vars$RootMRespYr - share$vars$RootGRespYr
            
        FolN <- share$vars$FolMass * vegpar$FolNCon / 100
        FolC <- share$vars$FolMass * vegpar$CFracBiomass

        TotalN <- FolN + share$vars$WoodMassN + share$vars$RootMassN + 
            share$vars$HON + NH4 + share$vars$NO3 + BudN + 
            share$vars$DeadWoodN + PlantN

        TotalM <- (BudC / vegpar$CFracBiomass) + share$vars$FolMass + 
            (share$vars$WoodMass + WoodC / vegpar$CFracBiomass) + 
            share$vars$RootMass + share$vars$DeadWoodM + share$vars$HOM + 
            (PlantC / vegpar$CFracBiomass) + 
            (share$vars$RootC / vegpar$CFracBiomass)
    }

    
    # Update values
    share$vars$BudC <- BudC
    share$vars$WoodC <- WoodC
    share$vars$PlantC <- PlantC
    share$vars$NPPFolYr <- NPPFolYr
    share$vars$NPPWoodYr <- NPPWoodYr
    share$vars$NPPRootYr <- NPPRootYr
    share$vars$NEP <- NEP
    share$vars$FolNConOld <- FolNConOld

    if (model == "pnet-cn") {
        share$vars$NRatio <- NRatio
        share$vars$PlantN <- PlantN
        share$vars$RootNSinkEff <- RootNSinkEff
        share$vars$FolN <- FolN
        share$vars$FolC <- FolC
        share$vars$PlantN <- PlantN
        share$vars$BudN <- BudN
        share$vars$NH4 <- NH4
        share$vars$TotalN <- TotalN
        share$vars$TotalM <- TotalM
        share$vars$NRatioNit <- NRatioNit
        share$vars$NetNMinLastYr <- share$vars$NetNMinYr
    }
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

    AvgDWater <- ifelse(prerow$DWaterIx > 0, 
        prerow$DWatertot / prerow$DWaterIx,
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


