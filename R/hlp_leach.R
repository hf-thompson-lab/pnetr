# ******************************************************************************
# Leach routine of PnET-CN
# 
# Author: Xiaojie Gao
# Date: 2023-10-09
# ******************************************************************************

#' The Leach module in PnET-CN
#'
#' @description
#' The following variables are calculated/updated:
#'   - NDrainYr
#'   - NO3
#'
#' @param share The shared object containing intermittent variables.
#' @param rstep current time step
Leach <- function(share, rstep) {
    # Variables to update
    NDrainYr <- NULL
    NO3 <- NULL

    NDrain <- share$vars$FracDrain * share$vars$NO3
    NDrainYr <- share$vars$NDrainYr + NDrain

    NO3 <- share$vars$NO3 - NDrain

    
    # Update variables
    share$vars$NDrainYr <- NDrainYr
    share$vars$NO3 <- NO3
}