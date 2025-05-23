# ******************************************************************************
# Phenological control
# 
# Author: Xiaojie Gao
# Date: 2023-08-20
# ******************************************************************************



#' Phenology module
#' 
#' @description 
#' The following variables are calculated/updated:
#' - GDDFolEff
#' - FolMass
#' - FolProdCMo
#' - FolGRespMo
#' - PosCBalMass
#' - LAI
#' - FolLitM
#' 
#' @param sitepar A table that contains site-specific variables.
#' @param vegpar A table that contains vegetation-specific variables.
#' @param share The shared object containing intermittent variables.
#' @param rstep current time step
#' @param phenophase Phenology stage, can be "grow" or "senesce".
Phenology <- function(sitepar, vegpar, share, rstep, phenophase) {
    # Variables to update
    GDDFolEff <- FolMass <- FolProdCMo <- FolGRespMo <- NULL
    LAI <- NULL
    FolLitM <- NULL

    GDDTot <- share$logdt[rstep, GDDTot]
    DOY <- share$logdt[rstep, DOY]

    # --------------------------------------------------------------------------
    #! Example of replacing phenology w/ observations

    # theyr <- share$logdt[rstep, Year]
    # gddstart <- blsp_thres_dt[Year == theyr, GDD]
    # if (length(gddstart) != 0) {
    #     vegpar$GDDFolStart <- gddstart
    # }

    # sens <- blsp_thres_dt[Year == theyr, sens]
    # if (length(sens) != 0) {
    #     vegpar$SenescStart <- sens
    # }
    # if (theyr >= 2001 & theyr <= 2022) { # MODIS pheno
    #     vegpar$GDDFolStart <- gdds_dt[yr == theyr, gdds]
    #     vegpar$SenescStart <- gdds_dt[yr == theyr, gse]
    #     vegpar$GDDFolEnd <- gdds_dt[yr == theyr, gdd_folend]
    # }
    # --------------------------------------------------------------------------
    

    if (phenophase == "grow") {
        # Within growing season but before senescence
        if (GDDTot > vegpar$GDDFolStart && DOY <= vegpar$SenescStart) {
            # GDD effect on foliage
            GDDFolEff <- (GDDTot - vegpar$GDDFolStart) / 
                (vegpar$GDDFolEnd - vegpar$GDDFolStart)
            GDDFolEff <- max(0, min(1, GDDFolEff))

            delGDDFolEff <- GDDFolEff - share$vars$GDDFolEff
            FolMass <- share$vars$FolMass + 
                (share$vars$BudC * delGDDFolEff) / vegpar$CFracBiomass
            
            FolProdCMo <- (FolMass - share$vars$FolMass) * vegpar$CFracBiomass
            FolGRespMo <- FolProdCMo * vegpar$GRespFrac
        } else {
            FolProdCMo <- 0
            FolGRespMo <- 0
        }
    } else if (phenophase == "senesce") {
        FolLitM <- 0
        if (share$vars$PosCBalMass < share$vars$FolMass && 
            DOY > vegpar$SenescStart
        ) {
            FolMassNew <- max(share$vars$PosCBalMass, vegpar$FolMassMin)
            
            # Calculate LAI
            # if (FolMassNew == 0) {
            #     LAI <- 0
            # } else if (FolMassNew < share$vars$FolMass) {
            #     LAI <- share$vars$LAI * (FolMassNew / share$vars$FolMass)
            # }
            LAI <- share$vars$LAI * (FolMassNew / share$vars$FolMass)
            # I use the following instead of "<" here to avoid decimal error in
            # comparison due to the floating precision issues.
            # if (FolMassNew - share$vars$FolMass > 1e-5) {
            #     stop("should not be here!")
            # }

            # Calculate litter mass
            if (FolMassNew < share$vars$FolMass) {
                FolLitM <- share$vars$FolMass - FolMassNew
            }

            FolMass <- FolMassNew
        }

    } else {
        stop("Phenophase does not exist!")
    }


    # Update values
    if (!is.null(GDDTot)) {
        share$vars$GDDTot <- GDDTot
    }
    if (!is.null(DOY)) {
        share$vars$DOY <- DOY
    }
    
    if (!is.null(GDDFolEff)) {
        share$vars$GDDFolEff <- GDDFolEff
    }
    
    if (!is.null(FolMass)) {
        share$vars$FolMass <- FolMass
    }
    if (!is.null(FolProdCMo)) {
        share$vars$FolProdCMo <- FolProdCMo
    }
    if (!is.null(FolGRespMo)) {
        share$vars$FolGRespMo <- FolGRespMo
    }
    if (!is.null(LAI)) {
        share$vars$LAI <- LAI
    }
    if (!is.null(FolLitM)) {
        share$vars$FolLitM <- FolLitM
    }
}
