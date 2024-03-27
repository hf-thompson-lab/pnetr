# ******************************************************************************
# Intermittent variables
#
# Author: Xiaojie Gao
# Date: 2023-08-28
# ******************************************************************************

ShareVars <- R6::R6Class("ShareVars",

    public = list(

        # These variables should not be changed once computed
        glb = list(
            # Instantaneous max net photosynthesis rate (g C m^-2)
            Amax = 0,
            # Daily averaged Amax (g C m^-2)
            Amax_d = 0,
            # Instantaneous basal respiration rate at 20°C (g C m^-2)
            BaseFolResp = 0,

            # For PnET-CN
            O3Effect = 0,
            
            NetNMinLastYr = 0
        ),

        vars = list(

            # ~ AtmEnviron ----------------------------------------

            # growing degree day
            GDD = 0,
            # Accumulated GDD
            GDDTot = 0,
            # GDD foliar effect
            GDDFolEff = 0,
            # GDD wood effect
            GDDWoodEff = 0,
            # Temperature effect on photosynthesis
            DTemp = 0,
            # Vapor pressure deficit (kpa)
            VPD = 0,
            # VPD effect on photosynthesis
            DVPD = 0,

            # ~ Photosynthesis ----------------------------------------

            # Instantaneous gross photosynthesis rate w/o water stress 
            # (g C m^-2)
            GrossAmax = 0,
            # Canopy level gross photosynthesis (g C m^-2)
            CanopyGrossPsn = 0,
            # Canopy level net photosynthesis (g C m^-2)
            CanopyNetPsn = 0,
            
            # Monthly canopy gross photosynthesis w/ water stress (g C m^-2)
            CanopyGrossPsnActMo = 0,
            # Monthly gross photosynthesis w/ water stress (g C m^-2)
            GrsPsnMo = 0,
            # Annual total gross photosynthesis (annual GPP, g C m^-2)
            TotGrossPsn = 0,
            # Monthly net photosynthesis w/ water stress (g C m^-2)
            NetPsnMo = 0,
            # Annual total net photosynthesis (g C m^-2)
            TotPsn = 0,
            
            # Daytime foliar respiration (g C m^-2)
            DayResp = 0,
            # Nighttime foliar respiration (g C m^-2)
            NightResp = 0,

            # Min light effect on photosynthesis
            LightEffMin = 0,

            # ~ Water balance ----------------------------------------

            # Water availability (cm)
            Water = 0,
            # Annual accumulated water (cm)
            TotWater = 0,
            # Water stress effect on photosynthesis
            DWater = 0,
            # Annual accumulated DWater effect
            DWatertot = 0,
            # TODO: what is this? (days)
            DWaterIx = 0,
            
            # Drainage rate (cm)
            Drainage = 0,
            # Annual total drainage (cm)
            TotDrain = 0,
            # Annual total evaporation (cm)
            TotEvap = 0,
            # Annual total transpiration (cm)
            TotTrans = 0,
            # Annual total precipitation (cm)
            TotPrec = 0,
            # Annual evapotranspiration (cm)
            ET = 0,

            # ~ Soil respiration ----------------------------------------
            
            # Monthly mean soil moisture effect on soil respiration
            MeanSoilMoistEff = 0,
            # Monthly soil respiration (g C m^-2)
            SoilRespMo = 0,
            # Annual soil respiration (g C m^-2)
            SoilRespYr = 0,

            # ~ Carbon allocation ----------------------------------------
            
            # Net carbon balance (g C m^-2)
            NetCBal = 0,
            # Plant carbon (g C m^-2)
            PlantC = 0,

            # Foliage -----------------
            # Bud carbon pool (g C m^-2)
            BudC = 0,
            # Foliar mass (g m^-2)
            FolMass = 0, 
            # Foliar litter
            FolLitM = 0,
            # Leaf area index (m^2 m^-2)
            LAI = 0,
            # Monthly foliar carbon production (g C m^-2)
            FolProdCMo = 0,
            # Annual foliar carbon production (g C m^-2)
            FolProdCYr = 0,
            # Monthly foliar growth respiration (g C m^-2)
            FolGRespMo = 0,
            # Annual foliar growth respiration (g C m^-2)
            FolGRespYr = 0,
            # Annual foliage NPP 
            NPPFolYr = 0,
            # Annual wood NPP
            NPPWoodYr = 0,
            # Annual Root NPP
            NPPRootYr = 0,
            # Annual NEP (g C m^-2)
            NEP = 0,
            # The mass with positivie carbon balance (g C m^-2)
            PosCBalMass = 0,
            # Annual positive carbon balance mass (g C m^-2)
            PosCBalMassTot = 0,
            # TODO: Annual xxx
            PosCBalMassIx = 0,

            # Wood -----------------
            # Wood carbon (g C m^-2)
            WoodC = 0,
            # Wood biomass
            WoodMass = 0,
            # Annual wood carbon production
            WoodProdCYr = 0,
            # Annual wood maintenance respiration (g C m^-2)
            WoodMRespYr = 0,
            # Annual wood growth respiration (g C m^-2)
            WoodGRespYr = 0,

            # Root -----------------
            # Root carbon (g C m^-2)
            RootC = 0,
            # Annual root carbon production (g C m^-2)
            RootProdCYr = 0,
            # Annual root maintenance respiration (g C m^-2)
            RootMRespYr = 0,
            # Annual root growth respiration (g C m^-2)
            RootGRespYr = 0,
            # Root biomass (g m^-2)
            RootMass = 6,

            # ~ PnET-CN ----------------------------------------

            DWUE = 0,
            DelAmax = 0,
            CanopyDO3Pot = 0,
            DroughtO3Frac = 0,
            TotO3Dose = 0,
            BiomLossFrac = 0,
            RootMassN = 0,
            RemoveFrac = 0,
            AgHarv = 0,

            FolN = 0,
            FolNConOld = 0,
            FolC = 0,
            TotalN = 0,
            TotalM = 0,
            
            TotalLitterM = 0,
            TotalLitterMYr = 0,
            TotalLitterN = 0,
            TotalLitterNYr = 0,

            SoilDecResp = 0,
            SoilDecRespYr = 0,

            # Wood decay respiration
            WoodDecResp = 0,
            WoodDecRespYr = 0,
            
            GrossNImmobYr = 0,
            GrossNMinYr = 0,
            PlantNUptakeYr = 0,
            NetNitrYr = 0,
            NetNMinYr = 0,
            FracDrain = 0,
            NDrainYr = 0,

            # Nitrogen ratio
            NRatio = 0,
            NRatioNit = 0,
            # Plant Nitrogen
            PlantN = 0,
            BudN = 0,
            NetNMinLastYr = 0,
            NH4 = 0, # hardwired in place of user input NH4
            NO3 = 0, # hardwired in place of user input NO3
            NdepTot = 0,
            # Humus mass, (g m^-2)
            HOM = 0,
            # Humus N mass (g m^-2)
            HON = 0,
            RootNSinkEff = 0,
            WUEO3Eff = 0,

            # The following seems for PnET-Day
            # Dead wood maintenance respiration
            DeadWoodM = 0,

            WoodMassN = 0,
            DeadWoodN = 0
        ),

        # Variables logs for each time step
        logdt = NULL,

        initialize = function(climate_dt, vegpar) {
            # Initialize the log data table
            steps <- nrow(climate_dt)
            varnames <- names(self$vars)
            self$logdt <- data.table(matrix(0, 
                nrow = steps, 
                ncol = length(varnames) + 3
            ))
            colnames(self$logdt) <- c("Year", "Date", "DOY", varnames)

            # Convert DOY to date
            date_vec <- as.Date(
                climate_dt$DOY, 
                origin = paste0(climate_dt$Year, "-01-01")
            ) - 1

            self$logdt[, Year := climate_dt$Year]
            self$logdt[, Date := date_vec]
            self$logdt[, DOY := climate_dt$DOY]

            # Init values
            self$vars$PlantC <- 900
            self$vars$BudC <- 135
            self$vars$DeadWoodM <- 11300
            self$vars$WoodC <- 300
            self$vars$Water <- 12
            self$vars$DWater <- 1
            self$vars$WoodMass <- 20000
            self$vars$RootMass <- 6
            self$vars$RootNSinkEff <- .5
            self$vars$WUEO3Eff <- 0
            self$vars$LightEffMin <- 1
            
            self$vars$RootC <- self$vars$WoodC / 3

            # ~ For PnET-CN
            self$glb$O3Effect <- numeric(50)
            self$glb$NetNMinLastYr <- 10
            self$vars$NetNMinLastYr <- 10
            
            self$vars$PlantN <- 1
            self$vars$NRatio <- 1.3993
            self$vars$NRatioNit <- 1
            self$vars$HOM <- 13500
            self$vars$HON <- 390

            self$vars$WoodMassN <- self$vars$WoodMass * vegpar$WLPctN *
                self$vars$NRatio
            self$vars$DeadWoodN <- self$vars$DeadWoodM * vegpar$WLPctN *
                self$vars$NRatio
        },

        # Log intermitent variable values for the current time step
        logvars = function(i, varnames = NULL) {
            if (is.null(varnames)) {
                varnames <- names(self$vars)
                # The following variables are calculated at one go so do not need to
                # be updated each time
                varnames <- varnames[!varnames %in% c(
                    "Tavg", "Tday", "Tnight", "Tmin", "VPD",
                    "Month", "Dayspan", "Daylenhr", "Daylen", "Nightlen",
                    "GDD", "GDDTot",
                    "DayResp", "NightResp", "DTemp", "DVPD"
                )]
            }

            vals <- lapply(varnames, function(v) { self$vars[[v]] })
            set(self$logdt, as.integer(i), varnames, vals)
        },

        # Format output for PnET-II
        output_pnet_ii = function() {
            # Annual table
            ann_dt <- self$logdt[month(Date) == 12, .(
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
            sim_dt <- self$logdt[, .(
                Year, Date, DOY, 
                GrsPsnMo, NetPsnMo, NetCBal, VPD, FolMass, DWater, Drainage, ET
            )]
            
            return(list(
                ann_dt = ann_dt,
                sim_dt = sim_dt
            ))
        },

        # Format output for PnET-Day
        output_pnet_day = function() {
            # Conver daily scale to monthly scale
            self$logdt[, CanopyGrossPsn := CanopyGrossPsn * Dayspan]
            self$logdt[, CanopyNetPsn := CanopyNetPsn * Dayspan]
            # Monthly table
            sim_dt <- self$logdt[, .(
                Year, Date, DOY,
                GrsPsnMo = CanopyGrossPsn, NetPsnMo = CanopyNetPsn, 
                NetCBal, VPD, FolMass
            )]

            return(list(
                sim_dt = sim_dt
            ))
        },

        # Format output for PnET-CN
        output_pnet_cn = function() {
            # Annual table
            ann_dt <- self$logdt[month(Date) == 12, .(
                Year,
                # Photosynthesis
                NPPFolYr, NPPWoodYr, NPPRootYr, NEP, TotGrossPsn,
                # Water
                DWater, TotWater, TotTrans, TotPsn, TotDrain, TotPrec, TotEvap, 
                TotET = TotTrans + TotEvap,
                # Carbon cycle
                PlantC, BudC, WoodC, RootC,
                FolMass, DeadWoodM, WoodMass, RootMass,
                HOM, HON,
                # Nitrogen cycle
                PlantN, BudN, NDrainYr, NetNMinYr, GrossNMinYr, PlantNUptakeYr,
                GrossNImmobYr, TotalLitterNYr, NetNitrYr, NRatio, 
                FolN = FolNConOld, NdepTot, 
                # TBCA
                TotalLitterMYr, RootMRespYr, RootGRespYr, SoilDecRespYr
            )]

            # Monthly table
            sim_dt <- self$logdt[, .(
                Year, Date, DOY,
                GrsPsnMo, NetPsnMo, NetCBal, VPD, FolMass, DWater, Drainage, ET,
                PlantN
            )]

            return(list(
                ann_dt = ann_dt,
                sim_dt = sim_dt
            ))
        }
    )

)
