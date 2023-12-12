# ******************************************************************************
# Soil respiration
# 
# Author: Xiaojie Gao
# Date: 2023-08-20
# ******************************************************************************

#' Soil respiration module
#'
#' @description
#' The following variables are calculated/updated:
#' - SoilRespMo
#' - SoilRespYr
#'
#' @param sitepar A table that contains site-specific variables.
#' @param vegpar A table that contains vegetation-specific variables.
#' @param share The shared object containing intermittent variables.
#' @param rstep current time step
#' @param phenophase Phenology stage, can be "grow" or "senesce".
SoilRespiration <- function(sitepar, vegpar, share, rstep) {
    # Current time step
    currow <- share$dt[rstep, ]
    # Previous time step
    prerow <- if (rstep == 1) currow else share$dt[rstep - 1, ]

    # TODO: Why divide by 30.5?
    soil_resp <- vegpar$SoilRespA * exp(vegpar$SoilRespB * currow$Tavg) * 
        currow$MeanSoilMoistEff * (currow$Dayspan / 30.5)

    # currow$SoilRespMo <- vegpar$SoilRespA * exp(vegpar$SoilRespB * currow$Tavg)
    # currow$SoilRespMo <- currow$SoilRespMo * currow$MeanSoilMoistEff
    # currow$SoilRespMo <- currow$SoilRespMo * (currow$Dayspan / 30.5)
    
    currow$SoilRespMo <- soil_resp
    currow$SoilRespYr <- ifelse(currow$Year == prerow$Year, 
        prerow$SoilRespYr + soil_resp,
        currow$SoilRespYr + soil_resp
    )

    return(currow)
}