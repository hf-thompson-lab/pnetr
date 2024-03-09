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
    FolMassNew <- LAI <- NULL

    GDDTot <- share$logdt[rstep, GDDTot]
    DOY <- share$logdt[rstep, DOY]

    if (phenophase == "grow") {
        # Within growing season but before senescence
        if (GDDTot > vegpar$GDDFolStart && DOY < vegpar$SenescStart) {
            # GDD effect on foliage
            GDDFolEff <- (GDDTot - vegpar$GDDFolStart) / 
                (vegpar$GDDFolEnd - vegpar$GDDFolStart)
            GDDFolEff <- max(0, min(1, GDDFolEff))

            delGDDFolEff <- GDDFolEff - share$vars$GDDFolEff
            FolMass <- share$vars$FolMass + 
                (share$vars$BudC * delGDDFolEff) / vegpar$CFracBiomass
            
            FolProdCMo <- (FolMass - share$vars$FolMass) * vegpar$CFracBiomass
            FolGRespMo <- FolProdCMo * vegpar$GRespFrac
        }

    } else if (phenophase == "senesce") {
        if (share$vars$PosCBalMass < share$vars$FolMass && 
            DOY > vegpar$SenescStart
        ) {
            FolMassNew <- max(share$vars$PosCBalMass, vegpar$FolMassMin)
            
            # Calculate LAI
            if (FolMassNew == 0) {
                LAI <- 0
            } else if (FolMassNew < share$vars$FolMass) {
                LAI <- share$vars$LAI * (FolMassNew / share$vars$FolMass)
            }

            # Calculate litter mass
            if (FolMassNew < share$vars$FolMass) {
                share$vars$FolLitM <- share$vars$FolMass - FolMassNew
            }
        }

    } else {
        stop("Phenophase does not exist!")
    }


    # Update values
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
    if (!is.null(FolMassNew)) {
        share$vars$FolMassNew <- FolMassNew
    }
    if (!is.null(LAI)) {
        share$vars$LAI <- LAI
    }
}
