# ******************************************************************************
# The climate section
# 
# Author: Xiaojie Gao
# Date: 2023-08-20
# ******************************************************************************

# Calculate vapor pressure
CalVP <- function(a, b, c, T) {
    vp <- a * exp(b * T / (T + c))
    return(vp)
}

# Calculate daytime VPD
CalVPD <- function(Tday, Tmin) {
    # Saturated vapor pressure
    es <- ifelse(Tday < 0,
        CalVP(0.61078, 21.87456, 265.5, Tday),
        CalVP(0.61078, 17.26939, 237.3, Tday)
    )

    emean <- ifelse(Tmin < 0,
        CalVP(0.61078, 21.87456, 265.5, Tmin),
        CalVP(0.61078, 17.26939, 237.3, Tmin)
    )

    vpd <- es - emean

    return(vpd)
}

# Day length in seconds
CalDaylengthSec <- function(hr) {
    daylen <- hr * 60 * 60
    return(daylen)
}

# Night length in seconds
CalNightlengthSec <- function(hr) {
    nightlen <- (24 - hr) * 60 * 60
    return(nightlen)
}

# Day length in hours
CalDaylengthHr <- function(lat, DOY) {
    lat_rad <- lat * (2 * pi) / 360
    # r <- 1 - (0.0167 * cos(0.0172 * (DOY - 3)))
    z <- 0.39785 * sin(
        4.868961 + 0.017203 * DOY + 
        0.033446 * sin(6.224111 + 0.017202 * DOY)
    )

    decl <- ifelse(abs(z) < 0.7, 
        atan(z / (sqrt(1.0 - z * z))),
        pi / 2 - atan(sqrt(1 - z * z) / z)
    )

    if (abs(lat_rad) >= pi / 2.0) {
        if (lat < 0) {
            lat_rad <- (-1) * (pi / 2 - 0.01)
        }
        else {
            lat_rad = 1 * (pi / 2 - 0.01);
        }
    }
    z2 <- -tan(decl) * tan(lat_rad)

    h <- sapply(z2, function(z2i) {
        if (z2i >= 1.0) {
            h <- 0
        } else if (z2i <= -1.0) {
            h <- pi
        } else {
            TA <- abs(z2i)
            if (TA < 0.7) {
                AC <- 1.570796 - atan(TA / sqrt(1 - TA * TA))
            } else {
                AC <- atan(sqrt(1 - TA * TA) / TA)
            }
            if (z2i < 0) {
                h <- 3.141593 - AC
            } else {
                h <- AC
            }
        }
    })
    
    daylenhr <- 2 * (h * 24) / (2 * pi)
    
    return(daylenhr)
}



#' Calculate atmospheric environmental variables
#' 
#' @description 
#' The following variables are calculated/updated:
#' - Tavg
#' - Tday
#' - Tnight
#' - VPD
#' - Tmin
#' - Month
#' - Dayspan
#' - Daylenhr
#' - Daylen
#' - Nightlen
#' - GDD
#' - GDDTot
#' 
#' @param climate_dt Climate data table.
#' @param lat Site latitude.
#' @param share_dt The shared data table from a `share` object used to store
#' intermittend variables.
#'
#' @return A data.table w/ additional columns compared to the `climate_dt`.
AtmEnviron <- function(climate_dt, lat, share_dt) {
    share_dt[, Tavg := (climate_dt$Tmax + climate_dt$Tmin) / 2]
    share_dt[, Tday := (climate_dt$Tmax + share_dt$Tavg) / 2]
    share_dt[, Tnight := (climate_dt$Tmin + share_dt$Tavg) / 2]
    share_dt[, VPD := CalVPD(share_dt$Tday, climate_dt$Tmin)]
    share_dt[, Tmin := climate_dt$Tmin]
    
    share_dt[, Month := lubridate::month(Date)]
    #HACK: There are three calculations of Dayspan
    # 1. PnET-Day original version
    share_dt[, Dayspan := DOY - shift(DOY, 1, 0), by = "Year"]
    # 2. PnET-II original version
    # share_dt[, Dayspan := 30]
    # 3. 
    # share_dt[, Dayspan := lubridate::days_in_month(Month)]

    # share_dt[, Dayspan := 1]

    
    share_dt[, Daylenhr := CalDaylengthHr(lat, DOY)]
    share_dt[, Daylen := CalDaylengthSec(Daylenhr)]
    share_dt[, Nightlen := CalNightlengthSec(Daylenhr)]

    share_dt[, GDD := ifelse(Tavg * Dayspan > 0, Tavg * Dayspan, 0)]
    share_dt[, GDDTot := cumsum(GDD), by = "Year"]

    invisible(share_dt)
}
