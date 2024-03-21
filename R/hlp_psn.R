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
    CiCaRatio <- -0.075 * vegpar$FolNCon + 0.875
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
CalCO2effectConductance <- function(Ca, DelAmax, CiElev, Ci350, sitepar) {
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
#' - LightEffMin
#' ---- For PnET-CN
#' - DelAmax
#' - DWUE
#' - CanopyDO3Pot
#' 
#' @param climate_dt A table that contains monthly climate data.
#' @param sitepar A table that contains site-specific variables.
#' @param vegpar A table that contains vegetation-specific variables.
#' @param share The shared object containing intermittent variables.
#' @param rstep current time step
Photosynthesis <- function(climate_dt, sitepar, vegpar, share, rstep, 
    model = "pnet-ii"
) {
    # Variables to update
    GrossAmax <- CanopyNetPsn <- CanopyGrossPsn <- NULL
    PosCBalMass <- PosCBalMassTot <- PosCBalMassIx <- NULL
    LightEffMin <- NULL
    LAI <- NULL
    DayResp <- NightResp <- NULL
    # For PnET-CN
    if (model == "pnet-cn") {
        DelAmax <- DWUE <- NULL
        CanopyDO3Pot <- NULL
    }


    # No leaves, no photosynthesis
    if (share$vars$FolMass > 0) {
        # Some already calculated variables at this time step
        GDDTot <- share$logdt[rstep, GDDTot]
        DOY <- share$logdt[rstep, DOY]
        DTemp <- share$logdt[rstep, DTemp]
        Tday <- share$logdt[rstep, Tday]
        Tnight <- share$logdt[rstep, Tnight]
        DVPD <- share$logdt[rstep, DVPD]
        Daylen <- share$logdt[rstep, Daylen]
        Nightlen <- share$logdt[rstep, Nightlen]
        Dayspan <- share$logdt[rstep, Dayspan]
        DayResp <- share$logdt[rstep, DayResp]
        NightResp <- share$logdt[rstep, NightResp]

        # Some init values
        CanopyNetPsn <- CanopyGrossPsn <- 0
        LAI <- 0
        PosCBalMass <- share$vars$FolMass


        if (model == "pnet-cn") {
            CO2Psn <- CalCO2effectPsn(climate_dt$CO2[rstep], vegpar)

            share$glb$Amax <- vegpar$AmaxA + vegpar$AmaxB * vegpar$FolNCon *
                CO2Psn$DelAmax
            share$glb$Amax_d <- share$glb$Amax * vegpar$AmaxFrac
            share$glb$BaseFolResp <- share$glb$Amax * vegpar$BaseFolRespFrac

            # Recalculate day and night respiration
            DayResp <- CalRealizedResp(
                share$glb$BaseFolResp, vegpar$RespQ10,
                Tday, vegpar$PsnTOpt, Daylen
            )
            NightResp <- CalRealizedResp(
                share$glb$BaseFolResp, vegpar$RespQ10,
                Tnight, vegpar$PsnTOpt, Nightlen
            )

            CO2Cond <- CalCO2effectConductance(
                climate_dt$CO2[rstep],
                CO2Psn$DelAmax, CO2Psn$CiElev, CO2Psn$Ci350,
                sitepar
            )

            DelAmax <- CO2Psn$DelAmax
            DWUE <- CO2Cond$DWUE

            # Calculate canopy ozone extinction based on folmass
            O3Prof <- 0.6163 + (0.00105 * share$vars$FolMass)

            # Init some values
            CanopyNetPsnO3 <- 0
        }

        GrossAmax <- share$glb$Amax_d + share$glb$BaseFolResp
        GrossAmax <- max(
            0,
            GrossAmax * DVPD * DTemp * Daylen * 12 / 1e9
        )

        # Calculate photosynthsis by simulating canopy layers -----------------

        # Number of layers to simulate
        nlayers <- vegpar$IMAX
        # Average leaf mass per layer
        avgMass <- share$vars$FolMass / nlayers
        for (ix in 1:nlayers) {
            # Leaf mass at this layer
            i <- ix * avgMass
            # Convert leaf mass to leaf area
            SLWLayer <- vegpar$SLWmax - (vegpar$SLWdel * i)
            LAI <- LAI + avgMass / SLWLayer

            # Calculate light attenuation
            Il <- climate_dt[rstep, Par] * exp(-vegpar$k * LAI)
            # Light effect on photosynthesis
            LightEff <- (1.0 - exp(-Il * log(2.0) / vegpar$HalfSat))

            # Gross layer psn w/o water stress
            LayerGrossPsnRate <- GrossAmax * LightEff
            LayerGrossPsn <- LayerGrossPsnRate * avgMass

            # Net layer psn w/o water stress
            LayerResp <- (DayResp + NightResp) * avgMass
            LayerNetPsn <- LayerGrossPsn - LayerResp
            if (LayerNetPsn < 0 && PosCBalMass == share$vars$FolMass) {
                PosCBalMass <- (ix - 1.0) * avgMass
            }
            CanopyNetPsn <- CanopyNetPsn + LayerNetPsn
            CanopyGrossPsn <- CanopyGrossPsn + LayerGrossPsn

            if (model == "pnet-cn") {
                # Ozone effect on Net Psn
                if (climate_dt$O3[rstep] > 0) {
                    # Convert netpsn to micromoles for calculating conductance
                    netPsnumol <- ((LayerNetPsn * 10^6) /
                        (Daylen * 12)) /
                        (avgMass / SLWLayer)
                    # Calculate ozone extinction throughout the canopy
                    RelLayer <- ix / nlayers
                    RelO3 <- 1 - (RelLayer * O3Prof)^3
                    # % Calculate Conductance (mm/s): Conductance down-regulates
                    # with prior O3 effects on Psn
                    LayerG <- (CO2Cond$gsInt + (CO2Cond$gsSlope * netPsnumol)) *
                        (1 - share$glb$O3Effect[ix])
                    # For no downregulation use:
                    # LayerG = gsInt + (gsSlope * netPsnumol);
                    if (LayerG < 0) {
                        LayerG <- 0
                    }

                    # Calculate cumulative ozone effect for each canopy layer
                    # with consideration that previous O3 effects were modified
                    # by drought
                    share$glb$O3Effect[ix] <- min(
                        1,
                        (share$glb$O3Effect[ix] * share$vars$DroughtO3Frac) +
                            (0.0026 * LayerG * climate_dt$O3[rstep] * RelO3)
                    )
                    LayerDO3 = 1 - share$glb$O3Effect[ix]
                } else {
                    LayerDO3 = 1
                }

                LayerNetPsnO3 <- LayerNetPsn * LayerDO3
                CanopyNetPsnO3 <- CanopyNetPsnO3 + LayerNetPsnO3
            }
        }

        LightEffMin <- min(LightEffMin, LightEff)

        if (DTemp > 0 && GDDTot > vegpar$GDDFolEnd &&
            climate_dt[rstep, DOY] < vegpar$SenescStart
        ) {
            PosCBalMassTot <- share$vars$PosCBalMassTot +
                PosCBalMass * Dayspan
            PosCBalMassIx <- share$vars$PosCBalMassIx + Dayspan
        }


        if (model == "pnet-cn") {
            # Calculate whole-canopy ozone effects before drought
            if (climate_dt$O3[rstep] > 0 && CanopyGrossPsn > 0) {
                CanopyNetPsnPot <- CanopyGrossPsn -
                    (DayResp * share$vars$FolMass) -
                    (NightResp * share$vars$FolMass)
                CanopyDO3Pot <- CanopyNetPsnO3 / CanopyNetPsnPot
            } else {
                CanopyDO3Pot <- 1
            }
        }
    } else {
        CanopyNetPsn <- CanopyGrossPsn <- 0
        PosCBalMass <- 0
        LAI <- 0
        DayResp <- NightResp <- 0
    }
    

    # Update values
    if (!is.null(GrossAmax)) {
        share$vars$GrossAmax <- GrossAmax
    }
    if (!is.null(CanopyNetPsn)) {
        share$vars$CanopyNetPsn <- CanopyNetPsn
    }
    if (!is.null(CanopyGrossPsn)) {
        share$vars$CanopyGrossPsn <- CanopyGrossPsn
    }
    if (!is.null(PosCBalMass)) {
        share$vars$PosCBalMass <- PosCBalMass
    }
    if (!is.null(PosCBalMassTot)) {
        share$vars$PosCBalMassTot <- PosCBalMassTot
    }
    if (!is.null(PosCBalMassIx)) {
        share$vars$PosCBalMassIx <- PosCBalMassIx
    }
    if (!is.null(LAI)) {
        share$vars$LAI <- LAI
    }
    if (!is.null(DayResp)) {
        share$vars$DayResp <- DayResp
    }
    if (!is.null(NightResp)) {
        share$vars$NightResp <- NightResp
    }
    if (!is.null(LightEffMin) && share$vars$LightEffMin > LightEff) {
        share$vars$LightEffMin <- LightEffMin
    }
    # For PnET-CN -----------------
    if (model == "pnet-cn") {
        if (!is.null(DelAmax)) {
            share$vars$DelAmax <- DelAmax
        }
        if (!is.null(DWUE)) {
            share$vars$DWUE <- DWUE
        }
        if (!is.null(CanopyDO3Pot)) {
            share$vars$CanopyDO3Pot <- CanopyDO3Pot
        }
        # Here we have to update the log table
        set(share$logdt, rstep, "DayResp", DayResp)
        set(share$logdt, rstep, "NightResp", NightResp)
    }
}
