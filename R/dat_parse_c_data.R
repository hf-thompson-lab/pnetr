# ******************************************************************************
# Parse input data format of the PnET C++ version
# 
# Author: Xiaojie Gao
# Date: 2023-09-23
# ******************************************************************************
require(data.table)
require(magrittr)


ReadCData <- function(testfilename) {
# testfilename <- "/Users/xiaojiegao/Documents/Git/PnET-R/PNET_C1/Input/input.txt"
    txt <- readLines(testfilename)

    climate_filename <- txt[grep("Climate file name", txt)] %>%
        trimws() %>%
        strsplit("\\s{2,}") %>%
        unlist() %>%
        .[1]
    # Since the climate filename in the example input.txt is on a Windows system and
    # it is a fixed path, here I'm reading it directly
    climate_filename <- "/Users/xiaojiegao/Documents/Git/PnET-R/PNET_C1/Input/climate.clim"

    clim_dt <- fread(climate_filename)

    sitepar <- SitePar$new()
    vegpar <- VegPar$new()


    site_settings_start_line <- grep("Site settings", txt)
    tree_settings_start_line <- grep("Tree settings", txt)


    # Init site and vegetation parameters
    for (i in (site_settings_start_line + 1):length(txt)) {
        curtxt <- txt[i] %>%
            trimws() %>%
            strsplit("\\s+{2,}") %>%
            unlist()

        name <- gsub("-", "", curtxt[2])
        if (is.na(name)) {
            next
        }

        if (name == "Latitude") {
            sitepar$Lat <- as.numeric(curtxt[1])
        } else if (name == "Water hold capacity,cm") {
            sitepar$WHC <- as.numeric(curtxt[1])
        } else if (name == "Snow pack,cm") {
            sitepar$SnowPack <- as.numeric(curtxt[1])
        } else if (name == "Water stress") {
            sitepar$WaterStress <- as.numeric(curtxt[1])
        } else if (name == "Fast flow fraction") {
            vegpar$FastFlowFrac <- as.numeric(curtxt[1])
        } else if (name == "AmaxA") {
            vegpar$AmaxA <- as.numeric(curtxt[1])
        } else if (name == "AmaxB") {
            vegpar$AmaxB <- as.numeric(curtxt[1])
        } else if (name == "AmaxFrac") {
            vegpar$AmaxFrac <- as.numeric(curtxt[1])
        } else if (name == "BaseFolRespFrac") {
            vegpar$BaseFolRespFrac <- as.numeric(curtxt[1])
        } else if (name == "m_CFracBiomass") {
            vegpar$CFracBiomass <- as.numeric(curtxt[1])
        } else if (name == "DVPD1") {
            vegpar$DVPD1 <- as.numeric(curtxt[1])
        } else if (name == "DVPD2") {
            vegpar$DVPD2 <- as.numeric(curtxt[1])
        } else if (name == "m_FLPctN") {
            vegpar$FLPctN <- as.numeric(curtxt[1])
        } else if (name == "Max leaf mass") {
            vegpar$FolMassMax <- as.numeric(curtxt[1])
        } else if (name == "Min leaf mass") {
            vegpar$FolMassMin <- as.numeric(curtxt[1])
        } else if (name == "FolNCon, by weight") {
            vegpar$FolNCon <- as.numeric(curtxt[1])
        } else if (name == "FolNConRange") {
            vegpar$FolNConRange <- as.numeric(curtxt[1])
        } else if (name == "FolNRetrans") {
            vegpar$FolNRetrans <- as.numeric(curtxt[1])
        } else if (name == "m_FolRelGrowMax, '/yr") {
            vegpar$FolRelGrowMax <- as.numeric(curtxt[1])
        } else if (name == "FolReten") {
            vegpar$FolReten <- as.numeric(curtxt[1])
        } else if (name == "GDDFolStart") {
            vegpar$GDDFolStart <- as.numeric(curtxt[1])
        } else if (name == "GDDFolEnd") {
            vegpar$GDDFolEnd <- as.numeric(curtxt[1])
        } else if (name == "m_GDDWoodStart") {
            vegpar$GDDWoodStart <- as.numeric(curtxt[1])
        } else if (name == "m_GDDWoodEnd") {
            vegpar$GDDWoodEnd <- as.numeric(curtxt[1])
        } else if (name == "GRespFrac") {
            vegpar$GRespFrac <- as.numeric(curtxt[1])
        } else if (name == "HalfSat") {
            vegpar$HalfSat <- as.numeric(curtxt[1])
        } else if (name == "k") {
            vegpar$k <- as.numeric(curtxt[1])
        } else if (name == "m_MinWoodFolRatio") {
            vegpar$MinWoodFolRatio <- as.numeric(curtxt[1])
        } else if (name == "m_PlantCReserveFrac") {
            vegpar$PlantCReserveFrac <- as.numeric(curtxt[1])
        } else if (name == "m_PrecIntFrac") {
            vegpar$PrecIntFrac <- as.numeric(curtxt[1])
        } else if (name == "PsnTMin") {
            vegpar$PsnTMin <- as.numeric(curtxt[1])
        } else if (name == "PsnTOpt") {
            vegpar$PsnTOpt <- as.numeric(curtxt[1])
        } else if (name == "RespQ10") {
            vegpar$RespQ10 <- as.numeric(curtxt[1])
        } else if (name == "m_RLPctN") {
            vegpar$RLPctN <- as.numeric(curtxt[1])
        } else if (name == "RootAllocA") {
            vegpar$RootAllocA <- as.numeric(curtxt[1])
        } else if (name == "RootAllocB") {
            vegpar$RootAllocB <- as.numeric(curtxt[1])
        } else if (name == "RootMRespFrc") {
            vegpar$RootMRespFrac <- as.numeric(curtxt[1])
        } else if (name == "SenescStart") {
            vegpar$SenescStart <- as.numeric(curtxt[1])
        } else if (name == "SLWdel, 'g dry matter/(m2 leaf * g leaf mass)") {
            vegpar$SLWdel <- as.numeric(curtxt[1])
        } else if (name == "SLWmax, 'g dry matter/m2 leaf") {
            vegpar$SLWmax <- as.numeric(curtxt[1])
        } else if (name == "Soil moisture factor") {
            vegpar$SoilMoistFact <- as.numeric(curtxt[1])
        } else if (name == "Soil respiration factor A") {
            vegpar$SoilRespA <- as.numeric(curtxt[1])
        } else if (name == "Soil respiration factor B") {
            vegpar$SoilRespB <- as.numeric(curtxt[1])
        } else if (name == "m_WLPctN") {
            vegpar$WLPctN <- as.numeric(curtxt[1])
        } else if (name == "m_WoodLitCLoss") {
            vegpar$WoodLitCLoss <- as.numeric(curtxt[1])
        } else if (name == "m_WoodLitLossRate") {
            vegpar$WoodLitLossRate <- as.numeric(curtxt[1])
        } else if (name == "WoodMRFrc") {
            vegpar$WoodMRespA <- as.numeric(curtxt[1])
        } else if (name == "m_WUEConst") {
            vegpar$WUEconst <- as.numeric(curtxt[1])
        }
    }

    return(list(
        sitepar = sitepar,
        vegpar = vegpar,
        clim_dt = clim_dt
    ))
}
