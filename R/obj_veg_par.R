# ******************************************************************************
# Vegetation parameters
# 
# Author: Xiaojie Gao
# Date: 2023-08-28
# ******************************************************************************


#' The vegetation related parameters.
#' 
#' @export
VegPar <- R6::R6Class("VegPar", inherit = Param,

    public = list(
        # ~ Canopy variables ----------------------------------------
        # Canopy light attenuation constant (unitless)
        k = numeric(),
        # Foliar nitrogen (% by weight; 100 g N g^-1 dm)
        FolNCon = numeric(),
        # Site-specific max summer foliar mass (g m^-2)
        FolMassMax = numeric(),
        # Site-specific min winter foliar mass (g m^-2)
        FolMassMin = numeric(),
        # Foliage retention time (yr)
        FolReten = integer(),
        # Top sunlit canopy specific leaf weight (g m^-2)
        SLWmax = numeric(),
        # Change in SLW with increasing foliar mass above (g m^-2 g^-1)
        SLWdel = numeric(),
        # Maximum relative growth rate for foliage (% yr^-1)
        FolRelGrowMax = 0.3,
        # Growing-degree-days at which foliar production begins (degree)
        GDDFolStart = integer(),
        # Senescence start DOY (day of yr)
        SenescStart = integer(),
        # Growing-degree-days at which foliar production ends (degree)
        GDDFolEnd = integer(),
        # Growing-degree-days at which wood production begins (degree)
        GDDWoodStart = integer(),
        # Growing-degree-days at which wood production ends (degree)
        GDDWoodEnd = integer(),
        # Number of layers to subdivde the cohort. In Aber and Federer 1992,
        # IMAX=50, but setting IMAX=5 saves computational time (de Bruijin et al
        # 2014).
        IMAX = 50,

        # ~ Photosynthesis variables ----------------------------------------
        # Intercept of relationship between foliar N and max photosynthetic rate
        # (n mol CO2 g^-1 leaf s^-1)
        AmaxA = numeric(),
        # Slope of relationship between foliar N and max photosynthetic rate
        # (n mol CO2 g^-1 leaf s^-1)
        AmaxB = numeric(),
        # Respiration as a fraction of maximum photosynthesis (%)
        BaseFolRespFrac = 0.1,
        # Half saturation light level (umol CO2 m^-2 leaf s^-1)
        HalfSat = 200,
        # Daily Amax as a fraction of early morning instantaneous rate
        AmaxFrac = 0.76,
        # Optimum temperature for photosynthesis (°C)
        PsnTOpt = numeric(),
        # Minimum temperature for photosynthesis (°C)
        PsnTMin = numeric(),
        # Q10 value for foliar respiration
        RespQ10 = 2,

        # ~ Water balance variables ----------------------------------------
        # Coefficients for converting VPD to DVPD (kPa^-1)
        DVPD1 = 0.05,
        # Coefficients for converting VPD to DVPD (kPa^-1)
        DVPD2 = 2,
        # Fraction of precipitation intercepted and evaporated
        PrecIntFrac = numeric(),
        # Constant in equation for water use efficiency as a function of VPD
        WUEConst = 10.9,
        # Fraction of water inputs lost directly to drainage
        FastFlowFrac = 0.1,
        # Soil water release parameter
        f = 0.04,
        # Soil moisture effect on water stress
        SoilMoistFact = 0,

        # ~ Carbon allocation variables ----------------------------------------
        # Carbon as fraction of foliage mass
        CFracBiomass = 0.45,
        # Intercept of relationship between foliar and root allocation
        RootAllocA = 0,
        # Slope of relationship between foliar and root allocation
        RootAllocB = 2,
        # Growth respiration, fraction of allocation
        GRespFrac = 0.25,
        # Ratio of fine root maintenance respiration to biomass production
        RootMRespFrac = 1,
        # Wood maintenance respiration as a fraction of gross photosynthesis
        WoodMRespA = 0.07,
        # Fraction of PlantC held in reserve after allocation to BudC
        PlantCReserveFrac = 0.75,
        # Minimum ratio of carbon allocation to wood and foliage
        MinWoodFolRatio = numeric(),

        # ~ Soil respiration variables ----------------------------------------
        # Intercept of relationship between mean montly temperature and soil 
        # respiration (g C m^-2 mo^-1)
        SoilRespA = 27.46,
        # Slope of relationship between mean montly temperature and soil
        # respiration (g C m^-2 mo^-1)
        SoilRespB = 0.06844,

        # ~ N cycle for PnET-CN ----------------------------------------
        # Coefficients for fine root turnover (fraction * year^-1) as a function
        # of annual net N
        RootTurnoverA = 0.789,
        RootTurnoverB = 0.191,
        RootTurnoverC = 0.0211,
        # Fractional mortality of live wood per year
        WoodTurnover = 0.025,
        # Fractional transfer from dead wood to SOM per year
        WoodLitTrans = 0.1,
        # Fractional loss of mass as CO2 in wood decomposition (%)
        WoodLitCLoss = 4,
        # Max. N content in PlantN pool (g m^-2)
        MaxNStore = 20,
        # Decomposition constant for SOM pool (year^-1)
        Kho = 0.075,
        # Coefficients for fraction of mineralized N reimmobilized as a function
        # of SOM C:N
        NImmobA = 151,
        NImmobB = -35,
        # Max. fractional increase in N concentrations
        FolNConRange = 0.6,
        # Fraction of foliage N retransfer to plant N, remainder in litter (%)
        FolNRetrans = 0.5,
        # Min N concentration in foliar litter (g N g^-1 dry matter)
        FLPctN = 0.009,
        # Min. N concentration in root litter (%)
        RLPctN = 0.012,
        # Min. N concentration in wood litter (%)
        WLPctN = 0.002,
        # Fraction of dead wood loss to litter and decay, dead wood turnover 
        # (yr ^-1)
        WoodLitLossRate = 0.1
    )

)





