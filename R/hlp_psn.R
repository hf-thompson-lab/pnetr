# ******************************************************************************
# Photosynthetic processes
# 
# Author: Xiaojie Gao
# Date: 2023-08-20
# ******************************************************************************


CalDTemp <- function(Tday, Tmin, PsnTOpt, PsnTMin, GDDTot, GDDFolEnd, Dayspan) {
    PsnTMax <- PsnTOpt + (PsnTOpt - PsnTMin)
    DTemp <- ((PsnTMax - Tday) * (Tday - PsnTMin)) / 
        (((PsnTMax - PsnTMin) / 2.0)^2)
    
    DTemp <- sapply(1:length(DTemp), function(i) {
        if ((Tmin[i] < 6) & (DTemp[i] > 0) & (GDDTot[i] >= GDDFolEnd)) {
            DTemp_new <- max(
                0, 
                DTemp[i] * (1.0 - ((6.0 - Tmin[i]) / 6.0) * (Dayspan[i] / 30.0))
            )
            return(DTemp_new)
        } else {
            return(DTemp[i])
        }
    })
    
    return(DTemp)
}

# CO2 effect on photosynthesis. Introduced in PnET-CN
CalCO2effectPsn <- function(Ca, vegpar) {
    # Leaf internal/external CO2
    CiCaRatio <- (-0.075 * vegpar$FolNCon) + 0.875
    # Ci at present (350 ppm) CO2
    Ci350 <- 350 * CiCaRatio
    # Ci at RealYear CO2 level
    CiElev <- Ca * CiCaRatio
    Arel350 <- 1.22 * ((Ci350 - 68) / (Ci350 + 136))
    ArelElev <- 1.22 * ((CiElev - 68) / (CiElev + 136))
    DelAmax <- 1 + ((ArelElev - Arel350) / Arel350)

    return(list(
        DelAmax = DelAmax,
        Ci350 = Ci350,
        CiElev = CiElev
    ))
}

# Calculate CO2 effect on conductance and set slope and intercept for A-gs
# relationship
CalCO2effectConductance <- function(Ca, DelAmax, CiElev, Ci350) {
    if (sitepar$CO2gsEffect == 1) {
        Delgs <- DelAmax / ((Ca - CiElev) / (350 - Ci350))
        DWUE <- 1 + (1 - Delgs)
        gsSlope <- (-1.1309 * DelAmax) + 1.9762
        gsInt <- (0.4656 * DelAmax) - 0.9701
    } else {
        DWUE <- 1
        gsSlope <- (-0.6157 * DelAmax) + 1.4582
        gsInt <- (0.4974 * DelAmax) - 0.9893
    }
    return(list(
        DWUE = DWUE,
        gsSlope = gsSlope,
        gsInt = gsInt
    ))
}


#' The Photosynthesis module
#' 
#' @description
#' The following variables are calculated/updated:
#' - DTemp
#' - GrossAmax
#' - PosCBalMass
#' - LAI
#' - CanopyNetPsn
#' - CanopyGrossPsn
#' - PosCBalMassTot
#' - PosCBalMassIx
#' - LightEffMin (in Share)
#' 
#' @param climate_dt A table that contains monthly climate data.
#' @param sitepar A table that contains site-specific variables.
#' @param vegpar A table that contains vegetation-specific variables.
#' @param share The shared object containing intermittent variables.
#' @param rstep current time step
Photosynthesis <- function(climate_dt, sitepar, vegpar, share, rstep, 
    model = "pnet-ii"
) {
    # Current time step
    currow <- share$dt[rstep, ]
    # Previous time step
    prerow <- if (rstep == 1) currow else share$dt[rstep - 1, ]

    # No leaves, no photosynthesis
    if (currow$FolMass <= 0) {
        currow$PosCBalMassTot <- ifelse(currow$Year == prerow$Year,
            prerow$PosCBalMassTot,
            currow$PosCBalMassTot
        )
        currow$PosCBalMassIx <- ifelse(currow$Year == prerow$Year,
            prerow$PosCBalMassIx,
            currow$PosCBalMassIx
        )
        currow$CanopyNetPsn <- 0
        currow$CanopyGrossPsn <- 0
        currow$LAI <- 0
        currow$DayResp <- 0
        currow$NightResp <- 0

        return(currow)
    }

    # Calculate temperature effect
    currow$DTemp <- CalDTemp(
        currow$Tday, currow$Tmin, vegpar$PsnTOpt, vegpar$PsnTMin, 
        currow$GDDTot, vegpar$GDDFolEnd, currow$Dayspan
    )
    
    

    if (model == "pnet-cn") {
        CO2Psn <- CalCO2effectPsn(climate_dt$CO2[rstep], vegpar)

        share$Amax <- vegpar$AmaxA + vegpar$AmaxB * vegpar$FolNCon * 
            CO2Psn$DelAmax
        share$Amax_d <- share$Amax * vegpar$AmaxFrac
        share$BaseFolResp <- share$Amax * vegpar$BaseFolRespFrac

        CO2Cond <- CalCO2effectConductance(climate_dt$CO2[rstep], 
            CO2Psn$DelAmax, CO2Psn$CiElev, CO2Psn$Ci350
        )

        currow$DelAmax <- CO2Psn$DelAmax
        currow$DWUE <- CO2Cond$DWUE

        # Calculate canopy ozone extinction based on folmass
        O3Prof <- 0.6163 + (0.00105 * currow$FolMass)
        CanopyNetPsnO3 <- 0
    }

    GrossAmax <- share$Amax_d + share$BaseFolResp
    currow$GrossAmax <- max(
        0, 
        GrossAmax * currow$DVPD * currow$DTemp * currow$Daylen * 12 / 1e9
    )
    
    # Day and night respiration have been calcuated
    # Realized daytime respiration
    currow$DayResp <- CalRealizedResp(
        share$BaseFolResp, vegpar$RespQ10,
        currow$Tday, vegpar$PsnTOpt, currow$Daylen
    )
    # Realized nighttime respiration
    currow$NightResp <- CalRealizedResp(
        share$BaseFolResp, vegpar$RespQ10, currow$Tnight,
        vegpar$PsnTOpt, currow$Nightlen
    )

    # Calculate photosynthsis by simulating canopy layers
    currow$PosCBalMass <- currow$FolMass
    # Number of layers to simulate
    Layer <- 0
    nlayers <- vegpar$IMAX
    # Average leaf mass per layer
    avgMass <- currow$FolMass / nlayers
    for (ix in 1:nlayers) {
        # Leaf mass at this layer
        i <- ix * avgMass
        # Convert leaf mass to leaf area
        SLWLayer <- vegpar$SLWmax - (vegpar$SLWdel * i)
        currow$LAI <- currow$LAI + avgMass / SLWLayer

        # Calculate light attenuation
        Il <- climate_dt[rstep, Par] * exp(-vegpar$k * currow$LAI)
        # Light effect on photosynthesis
        LightEff <- (1.0 - exp(-Il * log(2.0) / vegpar$HalfSat))

        # Gross layer psn w/o water stress
        LayerGrossPsnRate <- currow$GrossAmax * LightEff
        LayerGrossPsn <- LayerGrossPsnRate * (avgMass)

        # Net layer psn w/o water stress
        LayerResp <- (currow$DayResp + currow$NightResp) * avgMass
        LayerNetPsn <- LayerGrossPsn - LayerResp
        if (LayerNetPsn < 0 && currow$PosCBalMass == currow$FolMass) {
            currow$PosCBalMass <- (ix - 1.0) * avgMass
        }
        currow$CanopyNetPsn <- currow$CanopyNetPsn + LayerNetPsn
        currow$CanopyGrossPsn <- currow$CanopyGrossPsn + LayerGrossPsn

        if (model == "pnet-cn") {
            # Ozone effect on Net Psn
            if (climate_dt$O3[rstep] > 0) {
                # Convert netpsn to micromoles for calculating conductance
                netPsnumol <- ((LayerNetPsn * 10^6) /
                    (currow$Daylen * 12)) /
                    ((currow$FolMass / 50) / SLWLayer)
                # Calculate ozone extinction throughout the canopy
                Layer <- Layer + 1
                RelLayer <- Layer / 50
                RelO3 <- 1 - (RelLayer * O3Prof)^3
                # % Calculate Conductance (mm/s): Conductance down-regulates
                # with prior O3 effects on Psn
                LayerG <- (CO2Cond$gsInt + (CO2Cond$gsSlope * netPsnumol)) *
                    (1 - share$O3Effect[Layer])
                # For no downregulation use:
                # LayerG = gsInt + (gsSlope * netPsnumol);
                if (LayerG < 0) {
                    LayerG <- 0
                }

                # Calculate cumulative ozone effect for each canopy layer
                # with consideration that previous O3 effects were modified
                # by drought
                share$O3Effect[Layer] <- min(
                    1,
                    (share$O3Effect[Layer] * currow$DroughtO3Frac) +
                        (0.0026 * LayerG * climate_dt$O3[rstep] * RelO3)
                )
                LayerDO3 = 1 - share$O3Effect[Layer]
            } else {
                LayerDO3 = 1
            }

            LayerNetPsnO3 <- LayerNetPsn * LayerDO3
            CanopyNetPsnO3 <- CanopyNetPsnO3 + LayerNetPsnO3
        }
    }

    if (currow$DTemp > 0 && currow$GDDTot > vegpar$GDDFolEnd &&
        climate_dt[rstep, DOY] < vegpar$SenescStart
    ) {
        currow$PosCBalMassTot <- ifelse(currow$Year == prerow$Year,
            prerow$PosCBalMassTot + (
                currow$PosCBalMass * currow$Dayspan
            ),
            currow$PosCBalMassTot + (
                currow$PosCBalMass * currow$Dayspan
            )
        )
        currow$PosCBalMassIx <- ifelse(currow$Year == prerow$Year,
            prerow$PosCBalMassIx + currow$Dayspan,
            currow$PosCBalMassIx + currow$Dayspan
        )
    } else {
        currow$PosCBalMassTot <- ifelse(currow$Year == prerow$Year,
            prerow$PosCBalMassTot,
            currow$PosCBalMassTot
        )
        currow$PosCBalMassIx <- ifelse(currow$Year == prerow$Year,
            prerow$PosCBalMassIx,
            currow$PosCBalMassIx
        )
    }

    if (share$LightEffMin > LightEff) {
        share$LightEffMin <- LightEff
    }
    
    if (model == "pnet-cn") {
        # Calculate whole-canopy ozone effects before drought
        if (climate_dt$O3[rstep] > 0 && currow$CanopyGrossPsn > 0) {
            CanopyNetPsnPot <- currow$CanopyGrossPsn - 
                (currow$DayResp * currow$FolMass) - 
                (currow$NightResp * currow$FolMass)
            currow$CanopyDO3Pot <- CanopyNetPsnO3 / CanopyNetPsnPot
        } else {
            currow$CanopyDO3Pot <- 1
        }
    }

    return(currow)
}
