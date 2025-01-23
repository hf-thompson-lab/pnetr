# ******************************************************************************
# Functions to easily visualize internal variables.
# 
# Author: Xiaojie Gao
# Date: 2025-06-27
# ******************************************************************************


PlotInternalVariables <- function(
    obj_mod, ann_file = "internal_annual.pdf", sim_file = "internal_sim.pdf"
) {

    # Meteorological variables
    met_variables <- c()

    # Carbon variables

    # Water variables

    # Nitrogen variables


    varnames <- c(
        "TotGrossPsn", "NEP",
        "DWater", "TotWater", "TotTrans", 
        "TotET", "TotDrain", "TotEvap",
        "NPPFolYr", "NPPWoodYr", "NPPRootYr",
        "PlantC", "BudC", "WoodC", "RootC", 
        "FolMass", 
        "WoodMass", "DeadWoodM", 
        "RootMass", "RootMRespYr", "RootGRespYr",
        "TotalLitterMYr", 
        "NdepTot", "NRatio", 
        "PlantNUptakeYr", "PlantN", "BudN", "NDrainYr",
        "HOM", "HON", 
        "NetNMinYr", "GrossNMinYr", "GrossNImmobYr",
        "TotalLitterNYr", "NetNitrYr",
        "SoilDecRespYr"
    )

    pdf(ann_file, width = 12, height = 4)
    for (nm in varnames) {
        plot(
            obj_mod$ann_dt[, .(Year, get(nm))],
            ylab = nm, main = nm, type = "o", col = 1, pch = 16, lwd = 2
        )
    }
    dev.off()
}
