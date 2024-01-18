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
            samp_val <- rnorm(nsample, pars[[p]], abs(pars[[p]] * 0.3))
        }
        return(cbind(p, t(samp_val)))
    })
    samp_mat <- do.call(rbind, samp_mat)
    
    return(samp_mat)
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
SensitivityAnalysis <- function(vegpar_temp, vegpar_mat,
    clim_dt, sitepar, model = "pnet-day", 
    target_pars = c("CanopyGrossPsn", "CanopyNetPsn"),
    annual = TRUE
) {
    require(data.table)
    
    vegpar_new <- copy(vegpar_temp)
    res_dt <- apply(vegpar_mat[, -1], 2, function(pars) {
        browser() # For debug
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
                sum(out$mon_dt[[tpar]])
            })
        } else {
            vec <- sapply(target_pars, function(tpar) {
                out$mon_dt[[tpar]]
            })
        }

        return(vec)
    })
    res_dt <- do.call(rbind, list(t(res_dt)))
    res_dt <- as.data.table(res_dt)
    # colnames(res_dt) <- target_pars

    return(res_dt)
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
    for (vari in colnames(sens_res_dt)) {
        dt <- data.table(vari = sens_res_dt[[vari]], t((par_mat[, -1])))
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
    sens_res_dt <- SensitivityAnalysis(
        vegpar_temp = vegpar,
        vegpar_mat = vegpar_samp_mat,
        model = model,
        target_pars = target_pars,
        annual = annual
    )
    VisSense(vegpar_samp_mat, sens_res_dt, outfile = "zzz.pdf")
}