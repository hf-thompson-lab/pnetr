# ******************************************************************************
# Intermittent variables
#
# Author: Xiaojie Gao
# Date: 2023-08-28
# ******************************************************************************

ShareVars <- R6::R6Class("ShareVars",

    public = list(
        
        # ~ Global variables that should not change across the computing -------
        # Instantaneous max net photosynthesis rate (g C m^-2)
        Amax = NULL,
        # Daily averaged Amax (g C m^-2)
        Amax_d = NULL,
        # Instantaneous basal respiration rate at 20°C (g C m^-2)
        BaseFolResp = NULL,
        # Min light effect on photosynthesis
        LightEffMin = 1,

        # For PnET-CN
        O3Effect = numeric(50),
        
        NetNMinLastYr = 10,

        # Variables for each time step
        dt = NULL,

        initialize = function(climate_dt, vegpar) {
            # Number of time steps
            steps <- nrow(climate_dt)
            # Convert DOY to date
            date_vec <- as.Date(
                climate_dt$DOY, 
                origin = paste0(climate_dt$Year, "-01-01")
            ) - 1

            self$dt <- data.table(
                Year = climate_dt$Year,
                Date = date_vec,
                DOY = climate_dt$DOY,
                
                # ~ AtmEnviron ----------------------------------------
                
                # growing degree day
                GDD = numeric(steps),
                # Accumulated GDD
                GDDTot = numeric(steps),
                # GDD foliar effect
                GDDFolEff = numeric(steps),
                # GDD wood effect
                GDDWoodEff = numeric(steps),
                # Temperature effect on photosynthesis
                DTemp = numeric(steps),
                # Vapor pressure deficit (kpa)
                VPD = numeric(steps),
                # VPD effect on photosynthesis
                DVPD = numeric(steps),

                # ~ Photosynthesis ----------------------------------------

                # Instantaneous gross photosynthesis rate w/o water stress 
                # (g C m^-2)
                GrossAmax = numeric(steps),
                # Canopy level gross photosynthesis (g C m^-2)
                CanopyGrossPsn = numeric(steps),
                # Canopy level net photosynthesis (g C m^-2)
                CanopyNetPsn = numeric(steps),
                
                # Monthly canopy gross photosynthesis w/ water stress (g C m^-2)
                CanopyGrossPsnActMo = numeric(steps),
                # Monthly gross photosynthesis w/ water stress (g C m^-2)
                GrsPsnMo = numeric(steps),
                # Annual total gross photosynthesis (annual GPP, g C m^-2)
                TotGrossPsn = numeric(steps),
                # Monthly net photosynthesis w/ water stress (g C m^-2)
                NetPsnMo = numeric(steps),
                # Annual total net photosynthesis (g C m^-2)
                TotPsn = numeric(steps),
                
                # Daytime foliar respiration (g C m^-2)
                DayResp = numeric(steps),
                # Nighttime foliar respiration (g C m^-2)
                NightResp = numeric(steps),

                # Min light effect on photosynthesis
                LightEffMin = numeric(steps),

                # ~ Water balance ----------------------------------------

                # Water availability (cm)
                Water = numeric(steps),
                # Annual accumulated water (cm)
                TotWater = numeric(steps),
                # Water stress effect on photosynthesis
                DWater = numeric(steps),
                # Annual accumulated DWater effect
                Dwatertot = numeric(steps),
                # TODO: what is this? (days)
                DwaterIx = numeric(steps),
                
                # Drainage rate (cm)
                Drainage = numeric(steps),
                # Annual total drainage (cm)
                TotDrain = numeric(steps),
                # Annual total evaporation (cm)
                TotEvap = numeric(steps),
                # Annual total transpiration (cm)
                TotTrans = numeric(steps),
                # Annual total precipitation (cm)
                TotPrec = numeric(steps),
                # Annual evapotranspiration (cm)
                ET = numeric(steps),

                # ~ Soil respiration ----------------------------------------
                
                # Monthly mean soil moisture effect on soil respiration
                MeanSoilMoistEff = numeric(steps),
                # Monthly soil respiration (g C m^-2)
                SoilRespMo = numeric(steps),
                # Annual soil respiration (g C m^-2)
                SoilRespYr = numeric(steps),

                # ~ Carbon allocation ----------------------------------------
                
                # Net carbon balance (g C m^-2)
                NetCBal = numeric(steps),
                # Plant carbon (g C m^-2)
                PlantC = numeric(steps),

                # Foliage -----------------
                # Bud carbon pool (g C m^-2)
                BudC = numeric(steps),
                # Foliar mass (g m^-2)
                FolMass = numeric(steps), 
                # Foliar litter
                FolLitM = numeric(steps),
                # Leaf area index (m^2 m^-2)
                LAI = numeric(steps),
                # Monthly foliar carbon production (g C m^-2)
                FolProdCMo = numeric(steps),
                # Annual foliar carbon production (g C m^-2)
                FolProdCYr = numeric(steps),
                # Monthly foliar growth respiration (g C m^-2)
                FolGRespMo = numeric(steps),
                # Annual foliar growth respiration (g C m^-2)
                FolGRespYr = numeric(steps),
                # Annual foliage NPP 
                NPPFolYr = numeric(steps),
                # Annual wood NPP
                NPPWoodYr = numeric(steps),
                # Annual Root NPP
                NPPRootYr = numeric(steps),
                # Annual NEP (g C m^-2)
                NEP = numeric(steps),
                # The mass with positivie carbon balance (g C m^-2)
                PosCBalMass = numeric(steps),
                # Annual positive carbon balance mass (g C m^-2)
                PosCBalMassTot = numeric(steps),
                # TODO: Annual xxx
                PosCBalMassIx = numeric(steps),

                # Wood -----------------
                # Wood carbon (g C m^-2)
                WoodC = numeric(steps),
                # Wood biomass
                WoodMass = numeric(steps),
                # Annual wood carbon production
                WoodProdCYr = numeric(steps),
                # Annual wood maintenance respiration (g C m^-2)
                WoodMRespYr = numeric(steps),
                # Annual wood growth respiration (g C m^-2)
                WoodGRespYr = numeric(steps),

                # Root -----------------
                # Root carbon (g C m^-2)
                RootC = numeric(steps),
                # Annual root carbon production (g C m^-2)
                RootProdCYr = numeric(steps),
                # Annual root maintenance respiration (g C m^-2)
                RootMRespYr = numeric(steps),
                # Annual root growth respiration (g C m^-2)
                RootGRespYr = numeric(steps),
                # Root biomass (g m^-2)
                RootMass = numeric(steps),

                # ~ PnET-CN ----------------------------------------
                DWUE = numeric(steps),
                DelAmax = numeric(steps),
                CanopyDO3Pot = numeric(steps),
                DroughtO3Frac = numeric(steps),
                TotO3Dose = numeric(steps),
                BiomLossFrac = numeric(steps),
                RootMassN = numeric(steps),
                RemoveFrac = numeric(steps),
                AgHarv = numeric(steps),

                FolN = numeric(steps),
                FolC = numeric(steps),
                TotalN = numeric(steps),
                TotalM = numeric(steps),
                
                TotalLitterM = numeric(steps),
                TotalLitterMYr = numeric(steps),
                TotalLitterN = numeric(steps),
                TotalLitterNYr = numeric(steps),

                SoilDecResp = numeric(steps),
                SoilDecRespYr = numeric(steps),

                # Wood decay respiration
                WoodDecResp = numeric(steps),
                WoodDecRespYr = numeric(steps),
                
                GrossNImmobYr = numeric(steps),
                GrossNMinYr = numeric(steps),
                PlantNUptakeYr = numeric(steps),
                NetNitrYr = numeric(steps),
                NetNMinYr = numeric(steps),
                FracDrain = numeric(steps),
                NDrainYr = numeric(steps),

                # Nitrogen ratio
                NRatio = numeric(steps),
                # Plant Nitrogen
                PlantN = numeric(steps),
                BudN = numeric(steps),
                NetNMinLastYr = numeric(steps),
                NH4 = numeric(steps), # hardwired in place of user input NH4
                NO3 = numeric(steps), # hardwired in place of user input NO3
                NdepTot = numeric(steps),
                HOM = numeric(steps),
                HON = numeric(steps),
                RootNSinkEff = numeric(steps),
                WUEO3Eff = numeric(steps),

                # The following seems for PnET-Day
                # Dead wood maintenance respiration
                DeadWoodM = numeric(steps)
            )

            # The following variables have init values
            self$dt[, ":=" (
                PlantC = 900,
                BudC = 135,
                DeadWoodM = 11300,
                WoodC = 300,
                Water = 12,
                DWater = 1,
                NRatio = 1.3993,
                NRatioNit = 1,
                PlantN = 1,
                WoodMass = 20000,
                RootMass = 6,
                HOM = 13500,
                HON = 390,
                RootNSinkEff = .5,
                WUEO3Eff = 0,
                NetNMinLastYr = 10,
                NH4 = 0, # hardwired in place of user input NH4
                NO3 = 0 # hardwired in place of user input NO3
            )]

            self$dt$LightEffMin <- rep(1, steps)

            # These init values depend on other init values
            self$dt[, RootC := WoodC / 3]
            self$dt[, WoodMassN := WoodMass * vegpar$WLPctN * NRatio]
            self$dt[, DeadWoodN := DeadWoodM * vegpar$WLPctN * NRatio]
        },

        # Format output for PnET-II
        output_pnet_ii = function() {
            # Annual table
            ann_dt <- self$dt[month(Date) == 12, .(
                Year, 
                # Photosynthesis
                NPPFolYr, NPPWoodYr, NPPRootYr, NEP, TotGrossPsn,
                TotPrec, DWater, TotTrans, TotPsn, TotDrain, TotEvap, ET, 
                # Carbon cycle
                PlantC, BudC, WoodC, RootC, 
                FolMass, DeadWoodM, WoodMass, RootMass, 
                TotalLitterMYr, RootMRespYr, RootGRespYr
            )]

            # Monthly table
            mon_dt <- self$dt[, .(
                Year, Date, DOY, 
                GrsPsnMo, NetPsnMo, NetCBal, VPD, FolMass, DWater, Drainage, ET
            )]
            
            return(list(
                ann_dt = ann_dt,
                mon_dt = mon_dt
            ))
        },

        # Format output for PnET-Day
        output_pnet_day = function() {
            # Monthly table
            # HACK: I don't think PnET-Day uses water stress, which is DWater
            mon_dt <- self$dt[, .(
                Year, Date, DOY,
                CanopyGrossPsn, CanopyNetPsn, NetCBal, VPD, FolMass, DWater
            )]

            return(list(
                mon_dt = mon_dt
            ))
        },

        # Format output for PnET-CN
        output_pnet_cn = function() {
            # Annual table
            ann_dt <- self$dt[month(Date) == 12, .(
                Year,
                # Photosynthesis
                NPPFolYr, NPPWoodYr, NPPRootYr, NEP, TotGrossPsn,
                # Water
                DWater, TotWater, TotTrans, TotPsn, TotDrain, TotPrec, TotEvap, 
                ET,
                # Carbon cycle
                PlantC, BudC, WoodC, RootC,
                FolMass, DeadWoodM, WoodMass, RootMass,
                HOM, HON,
                # Nitrogen cycle
                PlantN, BudN, NDrainYr, NetNMinYr, GrossNMinYr, PlantNUptakeYr,
                GrossNImmobYr, TotalLitterNYr, NetNitrYr, NRatio, FolN, 
                # TBCA
                TotalLitterMYr, RootMRespYr, RootGRespYr, SoilDecRespYr
            )]

            # Monthly table
            mon_dt <- self$dt[, .(
                Year, Date, DOY,
                GrsPsnMo, NetPsnMo, NetCBal, VPD, FolMass, DWater, Drainage, ET,
                PlantN
            )]

            return(list(
                ann_dt = ann_dt,
                mon_dt = mon_dt
            ))
        }
    )

)
