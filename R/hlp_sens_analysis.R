# ******************************************************************************
# Sensitivity analysis
# 
# Author: Xiaojie Gao
# Date: 2024-01-13
# ******************************************************************************


GenerateSamples <- function(pars, 
    nsample = 1e3, meanvals = NULL, variation = NULL
) {
    samp_mat <- lapply(names(pars), function(p) {
        if (p %in% c(".__enclos_env__", "clone", "initialize")) {
            return(NULL)
        }

        if (is.null(meanvals) & is.null(variation)) {
            samp_val <- rnorm(nsample, pars[[p]], abs(pars[[p]] * 0.1))
        }
        return(cbind(p, t(samp_val)))
    })
    samp_mat <- do.call(rbind, samp_mat)
    
    return(samp_mat)
}

GenerateVegParSamples <- function(nsample = 1e3, meanvals) {
    # ~ Canopy variables ----------------------------------------
        # Canopy light attenuation constant (unitless)
        k <- rnorm(nsample, 0.573)
        # Foliar nitrogen (% by weight; 100 g N g^-1 dm)
        FolNCon <- numeric()
        # Site-specific max summer foliar mass (g m^-2)
        FolMassMax <- numeric()
        # Site-specific min winter foliar mass (g m^-2)
        FolMassMin <- numeric()
        # Foliage retention time (yr)
        FolReten <- integer()
        # Top sunlit canopy specific leaf weight (g m^-2)
        SLWmax <- numeric()
        # Change in SLW with increasing foliar mass above (g m^-2 g^-1)
        SLWdel <- numeric()
        # Maximum relative growth rate for foliage (% yr^-1)
        FolRelGrowMax <- 0.3
        # Growing-degree-days at which foliar production begins (degree)
        GDDFolStart <- integer()
        # Senescence start DOY (day of yr)
        SenescStart <- integer()
        # Growing-degree-days at which foliar production ends (degree)
        GDDFolEnd <- integer()
        # Growing-degree-days at which wood production begins (degree)
        GDDWoodStart <- integer()
        # Growing-degree-days at which wood production ends (degree)
        GDDWoodEnd <- integer()
        # Number of layers to subdivde the cohort. In Aber and Federer 1992,
        # IMAX=50, but setting IMAX=5 saves computational time (de Bruijin et al
        # 2014).
        IMAX <- 50

        # ~ Photosynthesis variables ----------------------------------------
        # Intercept of relationship between foliar N and max photosynthetic rate
        # (n mol CO2 g^-1 leaf s^-1)
        AmaxA <- numeric()
        # Slope of relationship between foliar N and max photosynthetic rate
        # (n mol CO2 g^-1 leaf s^-1)
        AmaxB <- numeric()
        # Respiration as a fraction of maximum photosynthesis (%)
        BaseFolRespFrac <- 0.1
        # Half saturation light level (umol CO2 m^-2 leaf s^-1)
        HalfSat <- 200
        # Daily Amax as a fraction of early morning instantaneous rate
        AmaxFrac <- 0.76
        # Optimum temperature for photosynthesis (°C)
        PsnTOpt <- numeric()
        # Minimum temperature for photosynthesis (°C)
        PsnTMin <- numeric()
        # Q10 value for foliar respiration
        RespQ10 <- 2

        # ~ Water balance variables ----------------------------------------
        # Coefficients for converting VPD to DVPD (kPa^-1)
        DVPD1 <- 0.05
        # Coefficients for converting VPD to DVPD (kPa^-1)
        DVPD2 <- 2
        # Fraction of precipitation intercepted and evaporated
        PrecIntFrac <- numeric()
        # Constant in equation for water use efficiency as a function of VPD
        WUEconst <- 10.9
        # Fraction of water inputs lost directly to drainage
        FastFlowFrac <- 0.1
        # Soil water release parameter
        f <- 0.04
        # Soil moisture effect on water stress
        SoilMoistFact <- 0

        # ~ Carbon allocation variables ----------------------------------------
        # Carbon as fraction of foliage mass
        CFracBiomass <- 0.45
        # Intercept of relationship between foliar and root allocation
        RootAllocA <- 0
        # Slope of relationship between foliar and root allocation
        RootAllocB <- 2
        # Growth respiration, fraction of allocation
        GRespFrac <- 0.25
        # Ratio of fine root maintenance respiration to biomass production
        RootMRespFrac <- 1
        # Wood maintenance respiration as a fraction of gross photosynthesis
        WoodMRespA <- 0.07
        # Fraction of PlantC held in reserve after allocation to BudC
        PlantCReserveFrac <- 0.75
        # Minimum ratio of carbon allocation to wood and foliage
        MinWoodFolRatio <- numeric()

        # ~ Soil respiration variables ----------------------------------------
        # Intercept of relationship between mean montly temperature and soil 
        # respiration (g C m^-2 mo^-1)
        SoilRespA <- 27.46
        # Slope of relationship between mean montly temperature and soil
        # respiration (g C m^-2 mo^-1)
        SoilRespB <- 0.06844

        # ~ N cycle for PnET-CN ----------------------------------------
        # Coefficients for fine root turnover (fraction * year^-1) as a function
        # of annual net N
        RootTurnoverA <- 0.789
        RootTurnoverB <- 0.191
        RootTurnoverC <- 0.0211
        # Fractional mortality of live wood per year
        WoodTurnover <- 0.025
        # Fractional transfer from dead wood to SOM per year
        WoodLitTrans <- 0.1
        # Fractional loss of mass as CO2 in wood decomposition (%)
        WoodLitCLoss <- 4
        # Max. N content in PlantN pool (g m^-2)
        MaxNStore <- 20
        # Decomposition constant for SOM pool (year^-1)
        Kho <- 0.075
        # Coefficients for fraction of mineralized N reimmobilized as a function
        # of SOM C:N
        NImmobA <- 151
        NImmobB <- -35
        # Max. fractional increase in N concentrations
        FolNConRange <- 0.6
        # Fraction of foliage N retransfer to plant N, remainder in litter (%)
        FolNRetrans <- 0.5
        # Min N concentration in foliar litter (g N g^-1 dry matter)
        FLPctN <- 0.009
        # Min. N concentration in root litter (%)
        RLPctN <- 0.012
        # Min. N concentration in wood litter (%)
        WLPctN <- 0.002
        # Fraction of dead wood loss to litter and decay, dead wood turnover 
        # (yr ^-1)
        WoodLitLossRate <- 0.1
}


#' Conduct the sensitivity analysis for each set of parameters.
#' 
#' @param vegpar_template A template object for the `vegpar` object. 
#' @param vegpar_mat Sampled parameter matrix. 
#' @param clim_dt A table that contains monthly climate data.
#' @param sitepar A table that contains site-specific variables.
#' @param model Model name, should be one of "pnet-day", "pnet-ii", 
#' and "pnet-cn".
#' @param target_pars Interested target output parameters.
#' @param annual Logical. Whether the target parameters are annual.
#'
#' @return Model outputs for the target parameters.
#'
#' @export
SensitivityAnalysis <- function(clim_dt, 
    vegpar_templ, vegpar_mat,
    sitepar_templ, sitepar_mat, 
    model = "pnet-day", 
    target_pars = c("GrsPsnMo", "NetPsnMo"),
    annual = TRUE
) {
    require(data.table)
    
    # For VegPar
    vegpar_new <- copy(vegpar_templ)
    veg_res_dt <- apply(vegpar_mat[, -1], 2, function(pars) {
        for (i in 1:length(vegpar_mat[, 1])) {
            vegpar_new[[vegpar_mat[i]]] <- as.numeric(pars[i])
        }

        out <- switch(tolower(model),
            "pnet-day" = PnET_Day(clim_dt, sitepar, vegpar_new),
            "pnet-ii" = PnET_II(clim_dt, sitepar, vegpar_new),
            "pnet-cn" = PnET_CN(clim_dt, sitepar, vegpar_new)
        )

        if (annual == TRUE) {
            vec <- sapply(target_pars, function(tpar) {
                sum(out$sim_dt[[tpar]])
            })
        } else {
            vec <- sapply(target_pars, function(tpar) {
                out$sim_dt[[tpar]]
            })
        }

        return(vec)
    })
    veg_res_dt <- do.call(rbind, list(t(veg_res_dt)))
    veg_res_dt <- as.data.table(veg_res_dt)

    # For SitePar
    sitepar_new <- copy(sitepar_templ)
    site_res_dt <- apply(sitepar_mat[, -1], 2, function(pars) {
        for (i in 1:length(sitepar_mat[, 1])) {
            if (sitepar_mat[[i]] %in% c(
                "agrem", "agstart", "agstop", "distsoilloss", "distremove",
                "distintensity", "distyear", "Lat"
            )) {
                next
            } else {
                sitepar_new[[sitepar_mat[[i]]]] <- as.numeric(pars[i])
            }
        }

        out <- switch(tolower(model),
            "pnet-day" = PnET_Day(clim_dt, sitepar, vegpar_new),
            "pnet-ii" = PnET_II(clim_dt, sitepar, vegpar_new),
            "pnet-cn" = PnET_CN(clim_dt, sitepar, vegpar_new)
        )

        if (annual == TRUE) {
            vec <- sapply(target_pars, function(tpar) {
                sum(out$sim_dt[[tpar]])
            })
        } else {
            vec <- sapply(target_pars, function(tpar) {
                out$sim_dt[[tpar]]
            })
        }
        
        return(vec)
    })
    site_res_dt <- do.call(rbind, list(t(site_res_dt)))
    site_res_dt <- as.data.table(site_res_dt)

    return(list(
        veg_res_dt = veg_res_dt,
        site_res_dt = site_res_dt
    ))
}


#' Visualize the sensitivity analysis.
#' 
#' @description This function uses a random forest model to fit the model
#' outputs with input parameters to determine the importance of the input
#' parameters. 
#' 
#' 
#' @param par_mat The input parameter matrix for the sensitivity analysis.
#' @param sens_res_dt The output sensitivity analysis data.table.
#' @param outfile A pdf filename to visualize the figures.
#'
#' @export
VisSense <- function(par_mat, sens_res_dt, outfile) {
    require(randomForest)
    require(data.table)

    # For each interested variable, use random forest model to evaluate the
    # important parameters and plot the importance figure out
    #
    # We plot to a pdf file
    pdf(outfile, width = 12, height = 8)
    veg_sens_dt <- sens_res_dt$veg_res_dt
    for (vari in colnames(veg_sens_dt)) {
        dt <- data.table(vari = veg_sens_dt[[vari]], t((par_mat[, -1])))
        colnames(dt) <- c(vari, par_mat[, 1])
        dt <- setDT(lapply(dt, as.numeric))

        mod <- randomForest(as.formula(paste(vari, "~ .")),
            data = dt,
            importance = TRUE
        )

        varImpPlot(mod, main = vari)
    }
    dev.off()
}


#' This is an integreated function to perfom sensitivity analysis.
#'
#' @param clim_dt A table that contains monthly climate data.
#' @param sitepar A table that contains site-specific variables.
#' @param vegpar A table that contains vegetation-specific variables.
#' @param model Character. Case insensitive. One of "pnet-day", "pnet-ii",
#' and "pnet-cn".
#' @param outfile A path indicating a pdf file for plotting out the
#' parameter importance figures.
#' @param target_pars Interested target output parameters.
#' @param annual Logical. Whether the target parameters are annual.
#'
#' @export
DoSens <- function(clim_dt, sitepar, vegpar, model,
    outfile,
    target_pars = c("CanopyGrossPsn", "CanopyNetPsn"),
    annual = TRUE
) {
    require(randomForest)
    require(data.table)

    vegpar_samp_mat <- GenerateSamples(vegpar)
    sitepar_samp_mat <- GenerateSamples(sitepar)
    sens_res_dt <- SensitivityAnalysis(
        clim_dt = clim_dt,
        vegpar_templ = vegpar,
        vegpar_mat = vegpar_samp_mat,
        sitepar_templ = sitepar,
        sitepar_mat = sitepar_samp_mat,
        model = model,
        target_pars = target_pars,
        annual = annual
    )
    VisSense(vegpar_samp_mat, sens_res_dt, outfile = "zzz.pdf")
}
