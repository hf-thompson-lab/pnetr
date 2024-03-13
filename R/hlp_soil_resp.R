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
    # Variables to update
    SoilRespMo <- SoilRespYr <- NULL

    # Some already caculated variables at this time step
    Tavg <- share$logdt[rstep, Tavg]
    Dayspan <- share$logdt[rstep, Dayspan]
    
    # TODO: Why divide by 30.5?
    SoilRespMo <- vegpar$SoilRespA * exp(vegpar$SoilRespB * Tavg) * 
        share$vars$MeanSoilMoistEff * (Dayspan / 30.5)

    # currow$SoilRespMo <- vegpar$SoilRespA * exp(vegpar$SoilRespB * currow$Tavg)
    # currow$SoilRespMo <- currow$SoilRespMo * currow$MeanSoilMoistEff
    # currow$SoilRespMo <- currow$SoilRespMo * (currow$Dayspan / 30.5)
    
    SoilRespYr <- share$vars$SoilRespYr + SoilRespMo


    # Update variables
    share$vars$SoilRespMo <- SoilRespMo
    share$vars$SoilRespYr <- SoilRespYr
}