# ******************************************************************************
# The main function of the PnET-II model
# 
# Author: Xiaojie Gao
# Date: 2023-08-20
# ******************************************************************************

#' The PnET-II model
#' 
#' @description Please see [Aber et al 1992](https://doi.org/10.1007/BF00317837)
#' and [Aber et al 1995](http://www.int-res.com/abstracts/cr/v05/n3/p207-222/)
#' for context of the model. And, `doc/pnet_ii_model.md` file contains technical
#' details of the model.
#' 
#' 
#' @param climate_dt A table that contains monthly climate data.
#' @param sitepar A table that contains site-specific variables.
#' @param vegpar A table that contains vegetation-specific variables.
#'
#' @return A list that contains both annual and monthly computed variables.
PnET_II <- function(climate_dt, sitepar, vegpar, verbose = FALSE) {
    # Create a share object to save intermittent computing results
    share <- ShareVars$new(climate_dt, vegpar)

    # These parameters can be calculated at once, can save some computing time
    AtmEnviron(climate_dt, sitepar$Lat, share$logdt)
    share$glb$Amax <- vegpar$AmaxA + vegpar$AmaxB * vegpar$FolNCon
    share$glb$Amax_d <- share$glb$Amax * vegpar$AmaxFrac
    share$glb$BaseFolResp <- share$glb$Amax * vegpar$BaseFolRespFrac
    
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
        if (share$logdt[rstep, Month] == 1) {
            YearInit(share)
        }
        # Assign already calculated values
        share$vars$GDD <- share$logdt[rstep, GDD]
        share$vars$GDDTot <- share$logdt[rstep, GDDTot]
        share$vars$DayResp <- share$logdt[rstep, DayResp]
        share$vars$NightResp <- share$logdt[rstep, NightResp]

        Phenology(sitepar, vegpar, share, rstep, phenophase = "grow")
        Photosynthesis(climate_dt, sitepar, vegpar, share, rstep)
        Waterbal(climate_dt, sitepar, vegpar, share, rstep)
        SoilRespiration(sitepar, vegpar, share, rstep)
        AllocateMon(sitepar, vegpar, share, rstep)
        Phenology(sitepar, vegpar, share, rstep, phenophase = "senesce")

        # End of year activity
        if (share$logdt[rstep, Month] == 12) {
            AllocateYr(sitepar, vegpar, share, rstep)
        }

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
    out <- share$output_pnet_ii()

    return(out)
}




