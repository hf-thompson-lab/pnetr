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
    AtmEnviron(climate_dt, sitepar$Lat, share$dt)
    share$dt[, DVPD := 1 - vegpar$DVPD1 * share$dt$VPD^vegpar$DVPD2]

    # Create a progress bar
    if (verbose == TRUE) {
        pb <- txtProgressBar(min = 0, max = 100, style = 3)
    }

    # Now, for each time step
    for (rstep in 1L:length(share$dt$DOY)) {
        
        # End of year activity
        if (rstep != 1 && share$dt$DOY[rstep] < share$dt$DOY[rstep]) {
            set(share$dt, rstep, names(share$dt), AllocateYrPre(
                sitepar, vegpar, share, rstep, model = "pnet-cn"
            ))
        }

        set(share$dt, rstep, names(share$dt), Phenology(
            sitepar, vegpar, share, rstep,
            phenophase = "grow"
        ))

        set(share$dt, rstep, names(share$dt), Photosynthesis(
            climate_dt, sitepar, vegpar, share, rstep, model = "pnet-cn"
        ))
        set(share$dt, rstep, names(share$dt), Waterbal(
            climate_dt, sitepar, vegpar, share, rstep, model = "pnet-cn"
        ))

        set(share$dt, rstep, names(share$dt), AllocateMon(
            sitepar, vegpar, share, rstep, model = "pnet-cn"
        ))

        set(share$dt, rstep, names(share$dt), Phenology(
            sitepar, vegpar, share, rstep,
            phenophase = "senesce"
        ))

        # PnET-CN specific
        set(share$dt, rstep, names(share$dt), CNTrans(
            climate_dt, sitepar, vegpar, share, rstep
        ))

        set(share$dt, rstep, names(share$dt), Decomp(
            climate_dt, sitepar, vegpar, share, rstep
        ))
        set(share$dt, rstep, names(share$dt), Leach(
            share, rstep
        ))

        # # End of year activity
        # if (share$dt[rstep, Month] == 12) {
        #     set(share$dt, rstep, names(share$dt), AllocateYr(
        #         sitepar, vegpar, share, rstep, model = "pnet-cn"
        #     ))
        # }
       
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
    out <- share$output_pnet_cn()

    return(out)
}

