# ******************************************************************************
# Site parameters
# 
# Author: Xiaojie Gao
# Date: 2023-08-28
# ******************************************************************************


#' The site related parameters.
#' 
#' @description These default values are from Aber et al 1992, 1995, 1996
#'
#' @export
SitePar <- R6::R6Class("SitePar", inherit = Param,

    public = list(
        # Latitude (degrees)
        Lat = numeric(),
        # Water holding capacity, plant available water (cm)
        WHC = numeric(), 
        # Site water stress on photosynthesis. 0 or 1, with 1 stands for water
        # stress.
        WaterStress = numeric(),
        # Initial snow pack on the first month (day) of simulation (cm)
        SnowPack = numeric(),

        # ~ The following seems for PnET-CN or PnET-Day ---------------
        # If there is an effect of CO2 on conductance which affects WUE and O3
        # impairment. 1: Yes; 0: NO;
        CO2gsEffect = numeric(),
        
        # Disturbance -----------------
        # Agriculture start year
        agstart = numeric(),
        # Agriculture end year
        agstop = numeric(),
        # Removal fraction in agriculture
        agrem = numeric(),
        
        # The following variable are vectors
        # Disturbance years
        distyear = numeric(),
        # Disturbance intensity. 0-1.
        distintensity = numeric(),
        # Disturbance removal fraction of aboveground biomass
        distremove = numeric(),
        
        distsoilloss = numeric()
    )

)
