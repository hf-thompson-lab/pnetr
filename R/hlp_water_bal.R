# ******************************************************************************
# Water balance
# 
# Author: Xiaojie Gao
# Date: 2023-08-20
# ******************************************************************************


# Calculate snow fraction of precipitation
CalSnowFraction <- function(Tavg) {
    snow_frac <- -1
    if (Tavg > 2) {
        snow_frac <- 0
    } else if (Tavg < -5) {
        snow_frac <- 1
    } else {
        snow_frac <- (Tavg - 2) / -7
    }
    return(snow_frac)
}

# Calculate snow melt
CalSnowMelt <- function(SnowPack, Tavg, Dayspan) {
    if (SnowPack > 0) {
        Tavew <- max(1, Tavg)
        snow_melt <- 0.15 * Tavew * Dayspan
        if (snow_melt > SnowPack) {
            snow_melt <- SnowPack
        }
    } else {
        snow_melt <- 0
    }
    
    return(snow_melt)
}

# Calculate snow fractiona and snow melt at daily time scale
CalSnowFracMeltDaily <- function(Tavg, Tmin, pot_snow_pack) {
    SnowTCrit <- -6
    snow_melt <- 0

    if (Tavg < 1) {
        Tavg <- 1
    }
    if (Tmin > SnowTCrit) {
        snow_frac <- 0
        snow_melt <- 0.15 * Tavg
    } else {
        snow_frac <- 1
    }

    return(list(snow_frac = snow_frac, snow_melt = snow_melt))
}

#' The Water Balance module
#' 
#' @description
#' The following variables are calculated/updated:
#' - SnowPack (in SitePar)
#' - Water
#' - DWater
#' - DWatertot
#' - DWaterIx
#' - MeanSoilMoistEff
#' - CanopyGrossPsnActMo
#' - GrsPsnMo
#' - NetPsnMo
#' - Drainage
#' - TotTrans
#' - TotPsn
#' - TotDrain
#' - TotPrec
#' - TotEvap
#' - TotGrossPsn
#' - ET
#' ---- For PnET-CN
#' - CanopyDO3Pot
#' 
#' @param climate_dt A table that contains monthly climate data.
#' @param sitepar A table that contains site-specific variables.
#' @param vegpar A table that contains vegetation-specific variables.
#' @param share The shared object containing intermittent variables.
#' @param rstep current time step
Waterbal <- function(climate_dt, sitepar, vegpar, share, rstep, 
    model = "pnet-ii"
) {
    # Variables to update
    SnowPack <- NULL
    Water <- TotWater <- DWater <- DWatertot <- DWaterIx <- NULL
    MeanSoilMoistEff <- NULL
    CanopyGrossPsnActMo <- GrsPsnMo <- NetPsnMo <- TotPsn <- TotGrossPsn <- NULL
    Drainage <- TotTrans <- TotDrain <- TotPrec <- TotEvap <- ET <- NULL

    if (model == "pnet-cn") {
        CanopyDO3 <- DroughtO3Frac <- NULL
        FracDrain <- NULL
    }

    # Some already caculated variables at this time step
    Tavg <- share$logdt[rstep, Tavg]
    Tmin <- share$logdt[rstep, Tmin]
    Dayspan <- share$logdt[rstep, Dayspan]
    VPD <- share$logdt[rstep, VPD]
    DayResp <- share$logdt[rstep, DayResp]
    NightResp <- share$logdt[rstep, NightResp]


    # Precipitation input and snow/rain partitioning
    prec <- climate_dt[rstep, Prec]
    # Evaporation
    Evap <- prec * vegpar$PrecIntFrac
    # Remaining precipitation
    precrem <- prec - Evap

    if (Dayspan > 1) {
        # Snow fraction
        SnowFrac <- CalSnowFraction(Tavg)
        # Potential snow pack
        pot_snow_pack <- sitepar$SnowPack + precrem * SnowFrac
        # Snow melt
        SnowMelt <- CalSnowMelt(pot_snow_pack, Tavg, Dayspan)
    } else {
        SnowFracMelt <- CalSnowFracMeltDaily(Tavg, Tmin)
        # Snow fraction
        SnowFrac <- SnowFracMelt$snow_frac
        # Potential snow pack
        pot_snow_pack <- sitepar$SnowPack + precrem * SnowFrac
        # Snow melt
        SnowMelt <- SnowFracMelt$snow_melt
        if (pot_snow_pack > 0) {
            if (SnowMelt > pot_snow_pack) {
                SnowMelt <- pot_snow_pack
            }
        } else {
            SnowMelt <- 0
        }
    }
    # Actual snow pack
    sitepar$SnowPack <- pot_snow_pack - SnowMelt

    # Potential water input
    pot_waterin <- SnowMelt + precrem * (1 - SnowFrac)
    # Fast flow
    FastFlow <- vegpar$FastFlowFrac * pot_waterin
    # Actual water input
    waterin <- pot_waterin - FastFlow
    # Daily average water input
    waterind <- waterin / Dayspan

    # Transpiration
    # Potential transpiration
    CanopyGrossPsnMG <- share$vars$CanopyGrossPsn * 1000 * 44 / 12
    # TODO: this thing can be calculated at once globally
    WUE <- vegpar$WUEconst / VPD
    # Potential transpiration
    # TODO: why divide by 10000?
    PotTransd <- CanopyGrossPsnMG / WUE / 10000
    Trans <- 0
    if (PotTransd > 0) {
        TotSoilMoistEff <- 0
        Water <- share$vars$Water
        for (wday in 1:Dayspan) {
            Water <- Water + waterind
            Transd <- ifelse(Water >= PotTransd / vegpar$f,
                PotTransd, 
                Water * vegpar$f
            )
            Water <- Water - Transd
            Trans <- Trans + Transd
            TotSoilMoistEff <- TotSoilMoistEff + (
                min(Water, sitepar$WHC) / 
                sitepar$WHC
            ) ^ (1.0 + vegpar$SoilMoistFact)
        }
        MeanSoilMoistEff <- min(1, TotSoilMoistEff / Dayspan)

        # Water stress
        DWater <- Trans / (PotTransd * Dayspan)
        # Annual water stress
        DWatertot <- share$vars$DWatertot + (DWater * Dayspan)
        # TODO: Annual xxx
        DWaterIx <- share$vars$DWaterIx + Dayspan
    } else {
        DWater <- 1
        Water <- share$vars$Water + waterin
        MeanSoilMoistEff <- 1
        
        DWatertot <- share$vars$DWatertot
        DWaterIx <- share$vars$DWaterIx
    }

    if (model == "pnet-cn") {
        # Calculate actural ozone effect and NetPsn with drought stress
        if (climate_dt$O3[rstep] > 0 && share$vars$CanopyGrossPsn > 0) {
            CanopyDO3 <- ifelse(share$vars$WUEO3Eff == 0,
                # No O3 effect on WUE (assumes no stomatal imparement)
                share$vars$CanopyDO3Pot + 
                    (1 - share$vars$CanopyDO3Pot) * (1 - share$vars$DWater),
                # Reduce the degree to which drought offsets O3 (assumes
                # stomatal imparement in proportion to effects on psn)
                share$vars$CanopyDO3Pot + 
                    (1 - share$vars$CanopyDO3Pot) * 
                    (1 - share$vars$DWater / share$vars$CanopyDO3Pot)
            )
            DroughtO3Frac <- share$vars$CanopyDO3Pot / CanopyDO3
        } else {
            CanopyDO3 <- 1
            DroughtO3Frac <- 1
        }
    }

    if (sitepar$WaterStress == 0) {
        DWater <- 1
    }

    # Canopy gross photosynthesis with water stress
    CanopyGrossPsnAct <- share$vars$CanopyGrossPsn * DWater
    # Accumulate to monthly
    CanopyGrossPsnActMo <- CanopyGrossPsnAct * Dayspan
    GrsPsnMo <- CanopyGrossPsnActMo
    # Net canopy photosynthesis with water stress
    NetPsnMo <- (CanopyGrossPsnAct - (DayResp + NightResp) * 
        share$vars$FolMass) * Dayspan

    # If current water amount is bigger than site capacity, drain rest
    if (Water > sitepar$WHC) {
        Drainage <- Water - sitepar$WHC
        Water <- sitepar$WHC
    } else {
        Drainage <- 0
    }


    TotPsn <- share$vars$TotPsn + NetPsnMo
    TotTrans <- share$vars$TotTrans + Trans
    TotGrossPsn <- share$vars$TotGrossPsn + GrsPsnMo
    
    Drainage <- Drainage + FastFlow
    TotDrain <- share$vars$TotDrain + Drainage
    TotPrec <- share$vars$TotPrec + prec
    TotEvap <- share$vars$TotEvap + Evap
    ET <- Trans + Evap

    TotWater <- share$vars$TotWater + Water


    # Update variables
    share$vars$Water <- Water
    share$vars$TotWater <- TotWater
    share$vars$DWater <- DWater
    share$vars$DWatertot <- DWatertot
    share$vars$DWaterIx <- DWaterIx
    
    share$vars$MeanSoilMoistEff <- MeanSoilMoistEff
    share$vars$CanopyGrossPsnActMo <- CanopyGrossPsnActMo
    share$vars$GrsPsnMo <- GrsPsnMo
    share$vars$NetPsnMo <- NetPsnMo
    share$vars$TotPsn <- TotPsn
    share$vars$TotGrossPsn <- TotGrossPsn
    
    share$vars$Drainage <- Drainage
    share$vars$TotTrans <- TotTrans
    share$vars$TotDrain <- TotDrain
    share$vars$TotPrec <- TotPrec
    share$vars$TotEvap <- TotEvap
    share$vars$ET <- ET
    
    if (model == "pnet-cn") {
        if (!is.null(CanopyDO3)) {
            share$vars$CanopyDO3 <- CanopyDO3
        }
        if (!is.null(DroughtO3Frac)) {
            share$vars$DroughtO3Frac <- DroughtO3Frac
        }
        
        share$vars$FracDrain <- Drainage / (Water + prec)
    }

}
