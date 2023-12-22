# ******************************************************************************
# This module provides functions for sensitivity analysis
# 
# Author: Xiaojie Gao
# Date: 2023-12-22
# ******************************************************************************

sens <- list(
    
    #' Sensitivity analysis using random forest
    #' 
    #' @param clim_dt
    #' @param sitepar
    #' @param vegpar
    #' @param model Character. Case insensitive. One of "pnet-day", "pnet-ii", 
    #' and "pnet-cn".
    #' @param samp_mat A matrix containing parameter samples.
    #' @param variables Character. Interested variables to check, can be a 
    #' vector.
    #' @param outfile A path indicating a pdf file for plotting out the
    #' parameter importance figures.
    #'
    #' @export
    DoSens = function(clim_dt, sitepar, vegpar, model,
        samp_mat, variables, outfile
    ) {
        require(randomForest)
        require(data.table)

        vegparnew <- copy(vegpar)

        res_dt <- apply(samp_mat[, -1], 2, function(pars) {
            # Initialize the vegpar object
            for (i in 1:length(samp_mat[, 1])) {
                vegparnew[[samp_mat[i]]] <- as.numeric(pars[i])
            }

            # Run the PnET model
            out <- switch(model, 
                "pnet-day" = PnET_Day(clim_dt, sitepar, vegparnew),
                "pnet-ii" = PnET_II(clim_dt, sitepar, vegparnew),
                "pnet-cn" = PnET_CN(clim_dt, sitepar, vegparnew)
            )

            # Find the insterested variable
            var_li <- lapply(variables, function(vv) {
                sum(out$mon_dt[[vv]], na.rm = TRUE)
            })
            var_dt <- do.call(cbind, var_li)

            return(var_dt)
        })
        res_dt <- data.table(t(res_dt))
        colnames(res_dt) <- variables

        # For each interested variable, use random forest model to evaluate the
        # important parameters and plot the importance figure out
        # 
        # We plot to a pdf file
        pdf(outfile, width = 12, height = 8)
        for (vari in variables) {
            dt <- data.table(vari = res_dt[[vari]], t((samp_mat[, -1])))
            colnames(dt) <- c(vari, samp_mat[, 1])
            dt <- setDT(lapply(dt, as.numeric))

            mod <- randomForest(as.formula(paste(vari, "~ .")), 
                data = dt,
                importance = TRUE
            )
            
            varImpPlot(mod, main = vari)
        }
        dev.off()
    }

)

