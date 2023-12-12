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
    # Current time step
    currow <- share$dt[rstep, ]
    # Previous time step
    prerow <- if (rstep == 1) currow else share$dt[rstep - 1, ]

    NDrain <- currow$FracDrain * currow$NO3
    currow$NDrainYr <- ifelse(currow$Year == prerow$Year,
        prerow$NDrainYr + NDrain,
        currow$NDrainYr + NDrain
    )

    currow$NO3 <- currow$NO3 - NDrain

    return(currow)
}