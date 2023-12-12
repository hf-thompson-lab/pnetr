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
    AtmEnviron(climate_dt, sitepar$Lat, share$dt)
    share$Amax <- vegpar$AmaxA + vegpar$AmaxB * vegpar$FolNCon
    share$Amax_d <- share$Amax * vegpar$AmaxFrac
    share$BaseFolResp <- share$Amax * vegpar$BaseFolRespFrac
    
    # Realized daytime respiration
    share$dt[, DayResp := CalRealizedResp(
        share$BaseFolResp, vegpar$RespQ10,
        share$dt$Tday, vegpar$PsnTOpt, share$dt$Daylen
    )]
    # Realized nighttime respiration
    share$dt[, NightResp := CalRealizedResp(
        share$BaseFolResp, vegpar$RespQ10, share$dt$Tnight,
        vegpar$PsnTOpt, share$dt$Nightlen
    )]
    share$dt[, DVPD := 1 - vegpar$DVPD1 * share$dt$VPD^vegpar$DVPD2]

    # Create a progress bar
    if (verbose == TRUE) {
        pb <- txtProgressBar(min = 0, max = 100, style = 3)
    }

    # Now, for each time step
    for (rstep in 1L:length(share$dt$DOY)) {

        set(share$dt, rstep, names(share$dt), Phenology(
            sitepar, vegpar, share, rstep, phenophase = "grow"
        ))
        set(share$dt, rstep, names(share$dt), Photosynthesis(
            climate_dt, sitepar, vegpar, share, rstep
        ))

        set(share$dt, rstep, names(share$dt), Waterbal(
            climate_dt, sitepar, vegpar, share, rstep
        ))
        set(share$dt, rstep, names(share$dt), SoilRespiration(
            sitepar, vegpar, share, rstep
        ))

        set(share$dt, rstep, names(share$dt), AllocateMon(
            sitepar, vegpar, share, rstep
        ))

        set(share$dt, rstep, names(share$dt), Phenology(
            sitepar, vegpar, share, rstep, phenophase = "senesce"
        ))

        # End of year activity
        if (share$dt[rstep, Month] == 12) {
            set(share$dt, rstep, names(share$dt), AllocateYr(
                sitepar, vegpar, share, rstep
            ))
        }

        if (verbose == TRUE) {
            # update progress
            setTxtProgressBar(pb, rstep * 100 / length(share$dt$DOY))
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




