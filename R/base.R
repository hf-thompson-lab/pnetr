# ******************************************************************************
# Common libraries and functions of the project
# 
# Author: Xiaojie Gao
# Date: 2023-08-20
# ******************************************************************************
# library(data.table)

.datatable.aware <- TRUE

#' Calculate reslized respiration per unit mass.
#' 
#' @param BaseFolResp Base foliar respiration rate.
#' @param RespQ10 The Q10 parameter.
#' @param T Temperature.
#' @param PsnTOpt Optimum temperature for photosynthesis.
#' @param TimeLen The length of time, e.g, day length or night length.
#'
#' @return Realized respiration per unit mass.
CalRealizedResp <- function(BaseFolResp, RespQ10, T, PsnTOpt, TimeLen) {
    pwr <- (T - PsnTOpt) / 10
    resp <- BaseFolResp * RespQ10^pwr * TimeLen * 12 / 1e9
    return(resp)
}
