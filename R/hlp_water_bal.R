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
        # TODO: clean the comment
        # Tavew <- Tavg
        # if (Tavg < 1) {
        #     Tavew <- 1
        # }
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

#' The Water Balance module
#' 
#' @description
#' The following variables are calculated/updated:
#' - SnowPack (in SitePar)
#' - Water
#' - DWater
#' - Dwatertot
#' - DwaterIx
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
#' 
#' @param climate_dt A table that contains monthly climate data.
#' @param sitepar A table that contains site-specific variables.
#' @param vegpar A table that contains vegetation-specific variables.
#' @param share The shared object containing intermittent variables.
#' @param rstep current time step
Waterbal <- function(climate_dt, sitepar, vegpar, share, rstep, 
    model = "pnet-ii"
) {
    # Current time step
    currow <- share$dt[rstep, ]
    # Previous time step
    prerow <- if (rstep == 1) currow else share$dt[rstep - 1, ]

    # Precipitation input and snow/rain partitioning
    prec <- climate_dt[rstep, Prec]

    # Evaporation
    Evap <- prec * vegpar$PrecIntFrac
    # Remaining precipitation
    precrem <- prec - Evap

    # Snow fraction
    SnowFrac <- CalSnowFraction(currow$Tavg)
    # Potential snow pack
    pot_snow_pack <- sitepar$SnowPack + precrem * SnowFrac
    # Snow melt
    SnowMelt <- CalSnowMelt(pot_snow_pack, currow$Tavg, currow$Dayspan)
    # Actual snow pack
    sitepar$SnowPack <- pot_snow_pack - SnowMelt

    # Potential water input
    pot_waterin <- SnowMelt + precrem * (1 - SnowFrac)
    # Fast flow
    FastFlow <- vegpar$FastFlowFrac * pot_waterin
    # Actual water input
    waterin <- pot_waterin - FastFlow
    # Daily average water input
    waterind <- waterin / currow$Dayspan

    # Transpiration
    # Potential transpiration
    CanopyGrossPsnMG <- currow$CanopyGrossPsn * 1000 * 44 / 12
    # TODO: this thing can be calculated at once globally
    WUE <- vegpar$WUEconst / currow$VPD
    # Potential transpiration
    # TODO: why divide by 10000?
    PotTransd <- CanopyGrossPsnMG / WUE / 10000
    Trans <- 0
    if (PotTransd > 0) {
        TotSoilMoistEff <- 0
        currow$Water <- prerow$Water
        for (wday in 1:currow$Dayspan) {
            currow$Water <- currow$Water + waterind
            Transd <- ifelse(currow$Water >= PotTransd / vegpar$f,
                PotTransd, 
                currow$Water * vegpar$f
            )
            currow$Water <- currow$Water - Transd
            Trans <- Trans + Transd
            TotSoilMoistEff <- TotSoilMoistEff + (
                min(currow$Water, sitepar$WHC) / 
                sitepar$WHC
            ) ^ (1.0 + vegpar$SoilMoistFact)
        }
        currow$MeanSoilMoistEff <- min(1, TotSoilMoistEff / currow$Dayspan)

        # Water stress
        currow$DWater <- Trans / (PotTransd * currow$Dayspan)
        # Annual water stress
        currow$Dwatertot <- ifelse(currow$Year == prerow$Year, 
            prerow$Dwatertot + (currow$DWater * currow$Dayspan),
            currow$Dwatertot + (currow$DWater * currow$Dayspan)
        )
        # TODO: Annual xxx
        currow$DwaterIx <- ifelse(currow$Year == prerow$Year,
            prerow$DwaterIx + currow$Dayspan,
            currow$DwaterIx + currow$Dayspan
        )
    } else {
        currow$DWater <- 1
        currow$Water <- prerow$Water + waterin
        currow$MeanSoilMoistEff <- 1
        
        currow$Dwatertot <- ifelse(currow$Year == prerow$Year, 
            prerow$Dwatertot,
            currow$Dwatertot
        )
        currow$DwaterIx <- ifelse(currow$Year == prerow$Year,
            prerow$DwaterIx,
            currow$DwaterIx
        )
    }

    if (model == "pnet-cn") {
        # Calculate actural ozone effect and NetPsn with drought stress
        if (climate_dt$O3[rstep] > 0 && currow$CanopyGrossPsn > 0) {
            CanopyDO3 <- ifelse(currow$WUEO3Eff == 0,
                # No O3 effect on WUE (assumes no stomatal imparement)
                currow$CanopyDO3Pot + 
                    (1 - currow$CanopyDO3Pot) * (1 - currow$DWater),
                # Reduce the degree to which drought offsets O3 (assumes
                # stomatal imparement in proportion to effects on psn)
                currow$CanopyDO3Pot + 
                    (1 - currow$CanopyDO3Pot) * 
                    (1 - currow$DWater / currow$CanopyDO3Pot)
            )
            currow$DroughtO3Frac <- currow$CanopyDO3Pot / CanopyDO3
        } else {
            CanopyDO3 <- 1
            currow$DroughtO3Frac <- 1
        }
    }

    if (sitepar$WaterStress == 0) {
        currow$DWater <- 1
    }

    # Canopy gross photosynthesis with water stress
    CanopyGrossPsnAct <- currow$CanopyGrossPsn * currow$DWater
    # Accumulate to monthly
    currow$CanopyGrossPsnActMo <- CanopyGrossPsnAct * currow$Dayspan
    currow$GrsPsnMo <- currow$CanopyGrossPsnActMo
    # Net canopy photosynthesis with water stress
    currow$NetPsnMo <- (CanopyGrossPsnAct - 
        (currow$DayResp + currow$NightResp) * currow$FolMass) * currow$Dayspan

    # If current water amount is bigger than site capacity, drain rest
    if (currow$Water > sitepar$WHC) {
        currow$Drainage <- currow$Water - sitepar$WHC
        currow$Water <- sitepar$WHC
    }

    # Update variables
    currow$Drainage <- currow$Drainage + FastFlow
    if (model == "pnet-cn") {
        currow$FracDrain <- currow$Drainage / (currow$Water + prec)
    }
    currow$TotTrans <- ifelse(currow$Year == prerow$Year,
        prerow$TotTrans + Trans,
        currow$TotTrans + Trans
    )
    currow$TotPsn <- ifelse(currow$Year == prerow$Year,
        prerow$TotPsn + currow$NetPsnMo,
        currow$TotPsn + currow$NetPsnMo
    )
    currow$TotDrain <- ifelse(currow$Year == prerow$Year,
        prerow$TotDrain + currow$Drainage,
        currow$TotDrain + currow$Drainage
    )
    currow$TotPrec <- ifelse(currow$Year == prerow$Year,
        prerow$TotPrec + prec,
        currow$TotPrec + prec
    )
    currow$TotEvap <- ifelse(currow$Year == prerow$Year,
        prerow$TotEvap + Evap,
        currow$TotEvap + Evap
    )
    currow$TotGrossPsn <- ifelse(currow$Year == prerow$Year,
        prerow$TotGrossPsn + currow$GrsPsnMo,
        currow$TotGrossPsn + currow$GrsPsnMo
    )
    currow$ET <- Trans + Evap
    currow$TotWater <- ifelse(currow$Year == prerow$Year,
        prerow$TotWater + currow$Water,
        currow$TotWater + currow$Water
    )

    return(currow)
}
