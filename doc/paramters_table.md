# PnET model variables

Note that this table was derived from the [official website](https://www.pnet.sr.unh.edu/).

## Site 

Variables related to sites.

| Variable      | Description                                                                                    | Unit                | Parameter | Processes                                             |
| ------------- | ---------------------------------------------------------------------------------------------- | ------------------- | --------- | ----------------------------------------------------- |
| Lat           | Site latitude                                                                                  | degrees             | No        | For calculating daylength                             |
| WHC           | Water hold capacity, water available for plant                                                 | cm                  | No        | Soil water balance                                    |
| WaterStress   | 0 or 1: 1 for no stress on photosynthesis                                                      |                     | No        | Calculated in water routine to modify photosysthensis |
| SnowPack      | Initial snow pack on the first month (day) of simulation                                       | cm equivalent water | No        | Water balance                                         |
| O3EffectOnWUE | 1: Yes; 0: NO, if there is an effect of O3 on WUE                                              |                     | No        | Water balance                                         |
| CO2gsEffect   | 1: Yes; 0: NO; if there is an effect of CO2 on conductance which affects WUE and O3 impairment |                     | No        | To calculate effect of CO2 on WUE and PNS             |
| distyear      | disturbance year                                                                               |                     | No        | Disturbance: harvest, storm, insect, etal             |
| distintensity | disturbance motality, 0-1                                                                      |                     | No        | Effect on biomass                                     |
| distremove    | removal fraction for aboveground biomass                                                       |                     | No        | Biomass loss                                          |
| distsoilloss  | removal fraction for soil biomass                                                              |                     | No        | Soil biomass loss                                     |
| folregen      | foliar regeneration rate                                                                       | g m-2               | No        | Foliage mass regenerated next year after disturbance  |


## Vegetation

Variables related to vegetation.

| Variable          | Description                                                                                       | Unit                   | Parameter | Processes                                                                 |
| ----------------- | ------------------------------------------------------------------------------------------------- | ---------------------- | --------- | ------------------------------------------------------------------------- |
| AmaxA             | Intercept (A) and Slope (B) for relationship between Foliar N and max. net photosynthesis         | n mol CO2 g-1 leaf s-1 | Yes       | To calculate net assimilation of photosynthesis                           |
| AmaxB             | Intercept (A) and Slope (B) for relationship between Foliar N and max.  net photosynthesis        | n mol CO2 g-1 leaf s-1 | Yes       | To calculate net assimilation of photosynthesis                           |
| AmaxFrac          | Daily Amax as a fraction of integral of instantaneous rate                                        | fraction               | Yes       | To adjust the average psn at different temporal scales                    |
| BaseFolRespFrac   | Dark respiration as fraction of Amax                                                              | fraction               | Yes       | Foliage dark respiration                                                  |
| CFracBiomass      | Carbon fraction of biomass                                                                        | g C g-1 dry biomass    | Yes       | To convert biomass to Carbon,                                             |
| DVPD1             | Coefficients for power function converting VPD to fractional loss in photosynthesis               | 0-1                    | Yes       | To calculate effect of vpd on photosynthesis                              |
| DVPD2             | Coefficients for power function converting VPD to fractional loss in photosynthesis               | 0-1                    | Yes       | To calculate effect of vpd on photosynthesis                              |
| FolMassMax        | Site specific max summer foliar biomass                                                           | g m-2                  | Yes       | To calculate peak foliage mass in  summer                                 |
| FolMassMin        | Site specific min winter foliar biomass                                                           | g m-2                  | Yes       | To calculate min foliage mass in  winter                                  |
| GDDFolStart       | Growing degree days at which foliage production onset                                             | degree                 | Yes       | Onset of budburst                                                         |
| GDDFolEnd         | Growing degree days at which foliage production ends                                              | degree                 | Yes       | End of foliage growth                                                     |
| GRespFrac         | Growth respiration, as a fraction of construction cost                                            |                        | Yes       | Respiration for growth of biomass                                         |
| HalfSat           | Half saturation light level                                                                       | umol m-2 s-1           | Yes       | Where the psn is half of the max at light saturation                      |
| k                 | Canopy light attenuation constant                                                                 |                        | Yes       | To calculate light profile in the canopy                                  |
| PsnTMin           | Minimum temperature for photosynthesis                                                            | C degree               | Yes       | Effect of temperatue on photosynthesis                                    |
| PsnTopt           | Optimum temperature for photosynthesis                                                            | C degree               | Yes       | Effect of temperatue on photosynthesis                                    |
| RespQ10           | Q10 value for respiration                                                                         |                        | Yes       | Effect of temperatue on respiration                                       |
| SLW               | Specific leaf weight                                                                              | g m-2                  | No        | Link biomass to leaf area                                                 |
| SLWMax            | Top sunlit canopy specific leaf weight                                                            | g m-2                  | Yes       | SLW distribution in canopy                                                |
| SLWDel            | Change in SLW with increasing foliar mass                                                         | g m-2 g-1              | Yes       | SLW distribution in canopy                                                |
| SenescStart       | Day of year after which leaf drop can occur                                                       | day of year            | Yes       | Phenology                                                                 |
| FolRelGroMax      | Maximum relative growth rate for foliage                                                          | % year-1               | Yes       | Foliage growth next year                                                  |
| FolNCon           | Foliar nitrogen concentration (% by weight)                                                       | 100 g N g^-1 dm        | Yes       | Photosynthesis                                                            |
| FLPctN            | min  N concentration in foliar litter                                                             | g N g-1 dry matter     | Yes       | Biomass Turnover and N concentartion in foliage                           |
| FolNRetrans       | Fraction of foliage N retransfer to plant N, remainder in litter                                  | fraction               | Yes       | N allocation in senescence                                                |
| FolNConRange      | Max. fractional increase in N concentrations                                                      |                        | Yes       | Biomass Turnover and N concentartion Variables                            |
| FolReten          | Foliage retention time                                                                            | year                   | Yes       | To calculate min foliage mass in  winter                                  |
| MaxNStore         | Max. N content in PlantN pool                                                                     | g N m-2                | Yes       | To calculate N stress (Nratio) assumed to be enough for 3 filiage flushes |
| GDDWoodEnd        | Growing degree days of at which wood production ends                                              | degree                 | Yes       | Wood phenology                                                            |
| GDDWoodStart      | Growing degree days of at which wood production onset                                             | degree                 | Yes       | Wood phenology                                                            |
| WoodMRespA        | Wood maintenance prespiration as a fraction of gross photosynthesis                               | fraction               | Yes       | Wood maintenance respiration                                              |
| WoodTurnover      | Fractional mortality of live wood per year,live wood to dead wood                                 | year-1                 | Yes       | Biomass Turnover and N concentartion Variables                            |
| WoodLitLossRate:  | Fraction of dead wood loss to litter and decay, dead wood turnover                                | year-1                 | Yes       | Dead wood loss (litter and dacay)                                         |
| WoddLitCLoss      | Fractional of dead wood loss decayed as CO2 in wood decomposition                                 | fraction               | Yes       | Dead wood decomposition                                                   |
| WLPctN            | Min. N concentration in wood litter                                                               | %                      | Yes       | Biomass Turnover and N concentartion                                      |
| MinWoodFolRatio   | Minimum ratio of carbon allocation to wood and foliage                                            |                        | Yes       | To set the lower bound for wood growth                                    |
| PlantCReserveFrac | Fraction of PlantC held in reserve after allocation to bud carbon, rest is WoodC                  |                        | Yes       | To calcualte WoodC or wood production for next year                       |
| RootAllocA        | Intercept (A)of relationship between foliar and root allocation                                   |                        | Yes       | Root carbon allocation                                                    |
| RootAllocB        | Slope (B) of relationship between foliar and root allocation                                      |                        | Yes       | Root carbon allocation                                                    |
| RootMRespFrac     | Ratio of fine root maintenance respiration to biomass production                                  |                        | Yes       | Root maintenance respiration                                              |
| RootTurnoverA     | Cofficients for find root turnover                                                                |                        | Yes       | Live root turnover to dead root                                           |
| RootTurnoverB     | Cofficients for find root turnover                                                                |                        | Yes       | Live root turnover to dead root                                           |
| RootTurnoverC     | Cofficients for find root turnover                                                                |                        | Yes       | Live root turnover to dead root                                           |
| RLPctN            | Min. N concentration in root litter                                                               | %                      | Yes       | Root N content                                                            |
| PrecIntFrac       | Fraction of precipitation intercepted and evaporated                                              | fraction               | Yes       | Evaporation                                                               |
| FastFlowFrac      | Fraction of water inputs lost directly to drainage                                                | 0-1                    | Yes       | Runoff and a fast, non-Darcian, drainage  or macro-pore flow              |
| f                 | Soil water release parameter for evapotranspiration                                               |                        | Yes       | Plant water uptake ability                                                |
| WUEConst          | Constant in equation for WUE as a function of VPD, intrinsic water use effeciency                 | g CO2/kg water         | Yes       | Transpiration                                                             |
| Ksom              | Decomposition constant for SOM pool                                                               | year-1                 | Yes       | Soil organic matter decomposition                                         |
| NiImmobB          | Cofficients for fraction of mineralized N reimmobilized as a function of SOM                      | fraction               | Yes       | Soil mineralized N immobilization,                                        |
| NImmobA           | Cofficients for fraction of mineralized N reimmobilized as a function of SOM                      |                        | Yes       | Biomass Turnover and N concentartion Variables                            |
| SoilMoistFact     | Effect of soil moisture on som decomposition                                                      |                        | Yes       | to calculate effect of soil moisture on som decomposition                 |
| SoilRespA         | Intercept (A) and Slope (B) of relationship between mean monthly temperature and soil respiration |                        | Yes       | Soil respiration                                                          |
| SoilRespB         | Slope (B) of relationship between mean monthly temperature and soil respiration in PnET II        |                        | Yes       | Soil respiration                                                          |


## Internal variables

| Variable     | Description                                                      | Unit                   | Processes |
| ------------ | ---------------------------------------------------------------- | ---------------------- | --------- |
| PosCBalMass  | The foliar biomass needed to maintain a positive carbon balance. | g m-2                  |           |
| DTemp        | Temperature effect on                                            |                        |           |
| PotGrossAmax | Potential gross instantenous maximum photosynthesis rate.        | n mol CO2 g-1 leaf s-1 |           |





