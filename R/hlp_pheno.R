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
    # Current time step
    currow <- share$dt[rstep,]
    # Previous time step
    prerow <- if (rstep == 1) currow else share$dt[rstep - 1, ]

    if (phenophase == "grow") {
        # Within growing season but before senescence
        if (currow$GDDTot > vegpar$GDDFolStart && 
            currow$DOY < vegpar$SenescStart
        ) {
            # GDD effect on foliage
            currow$GDDFolEff <- (currow$GDDTot - vegpar$GDDFolStart) / 
                (vegpar$GDDFolEnd - vegpar$GDDFolStart)
            currow$GDDFolEff <- max(0, min(1, currow$GDDFolEff))

            delGDDFolEff <- currow$GDDFolEff - prerow$GDDFolEff
            currow$FolMass <- prerow$FolMass + 
                (prerow$BudC * delGDDFolEff) / vegpar$CFracBiomass
            
            currow$FolProdCMo <- (currow$FolMass - prerow$FolMass) * 
                vegpar$CFracBiomass
            currow$FolGRespMo <- currow$FolProdCMo * vegpar$GRespFrac
        } else {
            currow$FolMass <- prerow$FolMass
        }
    } else if (phenophase == "senesce") {
        if (currow$PosCBalMass < currow$FolMass && 
            currow$DOY > vegpar$SenescStart
        ) {
            FolMassNew <- max(currow$PosCBalMass, vegpar$FolMassMin)
            if (FolMassNew == 0) {
                currow$LAI <- 0
            } else if (FolMassNew < currow$FolMass) {
                currow$LAI <- currow$LAI * (FolMassNew / currow$FolMass)
            }

            if (FolMassNew < currow$FolMass) {
                currow$FolLitM <- currow$FolMass - FolMassNew
            }

            # Update current foliar mass
            currow$FolMass <- FolMassNew
        }
    } else {
        stop("Phenophase does not exist!")
    }

    return(currow)
}
