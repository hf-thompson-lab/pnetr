# ******************************************************************************
# The main function of the PnET-CN model
# 
# Author: Xiaojie Gao
# Date: 2023-10-09
# ******************************************************************************



#' The PnET-CN model
#'
#' @description Please see [Aber et al
#' 1997](https://linkinghub.elsevier.com/retrieve/pii/S0304380097019534) for
#' context of the model. And, `doc/pnet_model.md` file contains technical
#' details of the model.
#'
#'
#' @param climate_dt A table that contains monthly climate data.
#' @param sitepar A table that contains site-specific variables.
#' @param vegpar A table that contains vegetation-specific variables.
#'
#' @return A list that contains both annual and monthly computed variables.
PnET_CN <- function(climate_dt, sitepar, vegpar, verbose = FALSE) {
    # Create a share object to save intermittent computing results
    share <- ShareVars$new(climate_dt, vegpar)

    # These parameters can be calculated at once, can save some computing time
    AtmEnviron(climate_dt, sitepar$Lat, share$logdt)

    # Realized daytime respiration
    share$logdt[, DayResp := CalRealizedResp(
        share$glb$BaseFolResp, vegpar$RespQ10,
        share$logdt$Tday, vegpar$PsnTOpt, share$logdt$Daylen
    )]
    # Realized nighttime respiration
    share$logdt[, NightResp := CalRealizedResp(
        share$glb$BaseFolResp, vegpar$RespQ10, share$logdt$Tnight,
        vegpar$PsnTOpt, share$logdt$Nightlen
    )]

    # Calculate temperature effect
    share$logdt[, DTemp := CalDTemp(
        Tday, Tmin, vegpar$PsnTOpt, vegpar$PsnTMin,
        GDDTot, vegpar$GDDFolEnd, Dayspan
    )]

    # Calculate DVPD effect
    share$logdt[, DVPD := 1 - vegpar$DVPD1 * share$logdt$VPD^vegpar$DVPD2]

    # Create a progress bar
    if (verbose == TRUE) {
        pb <- txtProgressBar(min = 0, max = 100, style = 3)
    }

    # Now, for each time step
    for (rstep in 1L:length(share$logdt$DOY)) {
if (rstep == 25) {
    b <- 1
}

        if (rstep > 1 && share$logdt[rstep, Month] == 1) {
            AllocateYr(sitepar, vegpar, share, rstep, model = "pnet-cn")
            
            # ============== maybe detele later =================
            # Just to make it consistent w/ Matlab version
            # But, I don't think they are needed once we confirm all processes
            # in the model are coded correctly.

            varnames <- names(share$vars)
            varnames <- varnames[!varnames %in% c(
                "Tavg", "Tday", "Tnight", "Tmin", "VPD",
                "Month", "Dayspan", "Daylenhr", "Daylen", "Nightlen",
                "GDD", "GDDTot",
                "DayResp", "NightResp", "DTemp", "DVPD",
                "PlantN", "FolN"
            )]
            share$logvars(rstep - 1, varnames)
            # ============== maybe detele later =================

            YearInit(share)
        }
        # Assign already calculated values
        share$vars$GDD <- share$logdt[rstep, GDD]
        share$vars$GDDTot <- share$logdt[rstep, GDDTot]
        share$vars$DayResp <- share$logdt[rstep, DayResp]
        share$vars$NightResp <- share$logdt[rstep, NightResp]

        Phenology(sitepar, vegpar, share, rstep, phenophase = "grow")
        Photosynthesis(climate_dt, sitepar, vegpar, share, rstep, model = "pnet-cn")
        Waterbal(climate_dt, sitepar, vegpar, share, rstep, model = "pnet-cn")
        AllocateMon(sitepar, vegpar, share, rstep, model = "pnet-cn")
        Phenology(sitepar, vegpar, share, rstep, phenophase = "senesce")

        # PnET-CN specific
        CNTrans(climate_dt, sitepar, vegpar, share, rstep)
        Decomp(climate_dt, sitepar, vegpar, share, rstep)
        Leach(share, rstep)

        share$logvars(rstep)

        if (verbose == TRUE) {
            # update progress
            setTxtProgressBar(pb, rstep * 100 / length(share$logdt$DOY))
        }
    }

    # Delete the probress bar
    if (verbose == TRUE) {
        close(pb)
    }

    # Summarize output
    out <- share$output_pnet_cn()

    return(out)
}

