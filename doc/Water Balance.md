# Water Balance

Here are the variables involved (See [variables_table](/doc/paramters_table.md) for description):

- Evaporation ($\text{Evap}^m$)
- Snowpack ($\text{SnowPack}^m$)
- Snow melt ($\text{SnowMelt}^m$)
- Input water amount ($\text{WaterIn}^m$)
- Canopy gross photosynthesis rate with water stress ($\text{CanopyGrossPsnRate}^m$)
- Gross photosynthesis with water stress ($\text{GrsPsn}^m$)
- Net photosynthesis with water stress ($\text{NetPsn}^m$)
- Water use efficiency ($\text{WUE}$)
- Water stress effect on photosynthesis ($\text{DWater}^m$)
- Annual water stress ($\text{Dwatertot}^m$)
- ($\text{DwaterIx}^m$)
- Transpiration ($\text{Trans}^m$)
- Evapotranspiration ($\text{ET}$)
- Water amount ($\text{Water}^m$)
- Drainage ($\text{Drainage}^m$)
- Annual accumulated drainage ($\text{TotDrain}^m$)
- Annual accumulated transpiration ($\text{TotTrans}^m$)
- Annual accumulated total gross photosynthesis ($\text{TotGrossPsn}^m$)
- Annual accumulated total net photosynthesis ($\text{TotPsn}^m$)
- Annual accumulated precipitation ($\text{TotPrec}^m$)
- Annual accumulated evaporation ($\text{TotEvap}^m$)

## Water input

Precipitation is the only water input source. When precipitation drops, a constant fraction of precipitation ($\textcolor{cyan}{\text{PreclntFrac}}$) is intercepted and evaporated. This includes both rain interception and evaporation (sublimation) from canopy and ground level snow:

$$\text{Evap}^m = \textcolor{lime}{Prep^m} \cdot \textcolor{cyan}{PrecIntFrac}$$

The rest of the precipitation ($\text{PrepRemain}^m$) is dropped in the form of snow or rain depends on temperature:

$$\text{PrepRemain}^m = \textcolor{lime}{Prep^m} - \text{Evap}^m$$

$$\text{SnowFrac}^m = \begin{cases}
    1 & T_{avg}^m \le -5 \\
    (T_{avg}^m - 2) / -7 & -5 < T_{avg}^m < 2 \\
    0 & T_{avg}^m \ge 2
\end{cases}$$

where $\text{SnowFrac}^m$ is the fraction of precipitation falling as snow.

Potentially, the accumulated snow pack on the ground should be:

$$\text{PotSnowPack}^m = \text{SnowPack}^{m-1} + \textcolor{lime}{Prep^m} \cdot \text{SnowFrac}^m$$

But, depends on temperature, a portion of snow may be melted:

$$\text{SnowMelt}^m = \begin{cases}
    \min(0.15 \cdot \min(1, T_{avg}^m) \cdot \text{Dayspan}^m, \text{PotSnowPack}^m) & \text{PotSnowPack}^m > 0 \\
    0 & \text{PotSnowPack}^m = 0
\end{cases}$$

So, the actual snow pack is:

$$\text{SnowPack}^m = \text{PotSnowPack}^m - \text{SnowMelt}^m$$

The melted snow adds to the potential amount of water input ($\text{PotWaterIn}^m$) along with the remaining precipitation after considering snow fraction:

$$\text{PotWaterIn}^m = \text{SnowMelt}^m + \text{PrepRemain}^m \cdot (1 - \text{SnowFrac}^m)$$

However, there is a small fast flow proportion:

$$\text{FastFlow}^m = \textcolor{cyan}{FastFlowFrac} \cdot \text{PotWaterIn}^m$$

So, the actual input water is:

$$\text{WaterIn}^m = \text{PotWaterIn}^m - \text{FastFlow}^m$$

We can also calculate the average daily input water in this month:

$$\text{WaterIn}^d = \text{WaterIn}^m / \text{Dayspan}^m$$


## Transpiration

Transpiration requires photosynthesis, so if the current period is out of growing season, i.e., $\text{GDD}_{\text{total}}^m < \textcolor{cyan}{\text{GDDFolStart}}$ or $\text{GDD}_{\text{total}}^m > \textcolor{cyan}{\text{GDDFolEnd}}$, transpiration would be 0. If this is the case, we update the following variables:

- $\text{DWater}^m = 1$
- $\text{Water}^m = \text{Water}^{m-1} + \text{WaterIn}^m$
- $\text{MeanSoilMoistEff}^m = 1$
- $\text{Trans}^m = 0$
- $\text{NetPsn}^m = 0$
- $\text{GrsPsn}^m = 0$

Otherwise, if the current period is within the growing season, we first calculate water use efficiency by:

$$\text{WUE}^m = \textcolor{cyan}{\text{WUE}_{const}} / \text{VPD}^m$$

Convert units, and calculate daily potential transpiration without water stress:

$$\text{CanopyGrossPsnMG} = \text{CanopyGrossPsn}^m \cdot 1000 \cdot 44 / 12$$

$$\text{PotTrans}^d = \text{CanopyGrossPsnMG} / \text{WUE}^m / 10000$$

If $\text{PotTrans}^d > 0$, For each day $d$ in the month, current potential available water is:

$$\text{PotWater}^d = \text{Water}_{d-1} + \text{WaterIn}^d$$

so the transpiration for the day is:

$$\text{Trans}^d = \begin{cases}
    \text{PotTrans}^d & \text{PotWater}^d \geq \text{PotTrans}^d / \textcolor{cyan}{\text{f}} \\
    \text{PotWater}^d \cdot \textcolor{cyan}{\text{f}} & \text{PotWater}^d < \text{PotTrans}^d / \textcolor{cyan}{\text{f}}
\end{cases}$$

Then, the actual daily water after transpiration is:

$$\text{Water}^d = \text{PotWater}^d - \text{Trans}^d$$

And the accumulated transpiration for the month is:

$$\text{Trans}^m = \text{Trans}^d \cdot \text{Dayspan}^m$$

The accumulated total soil moisture effect for the month is:

$$\text{TotSoilMoistEff}^m = \Sigma_{d=1}^{\text{Dayspan}^m} {\min(\text{Water}^d, \textcolor{cyan}{\text{WHC}}) / \textcolor{cyan}{\text{WHC}}}^{1.0 + \textcolor{cyan}{\text{SoilMoistFact}}}$$

The mean daily soil moisture effect on soil respiration is:

$$\text{MeanSoilMoistEff}^m = \min(1, \text{TotSoilMoistEff}^m / \text{Dayspan}^m)$$

Then, the effect of water on gross photosynthesis is:

$$\text{DWater}^m = \text{Trans}^m / (\text{PotTrans}^d \cdot \text{Dayspan}^m)$$

The accumulated $\text{DWater}$ is:

$$\text{DWatertot}^{12} = \Sigma_{m=1}^{12} (\text{DWater}^m \cdot \text{Dayspan}^m)$$

$$\text{DWaterIx}^{12} = \Sigma_{m=1}^{12} \text{Dayspan}^m$$


## Water stress on photosynthesis

If $\textcolor{cyan}{\text{WaterStress}^m} = 0$, then $\text{DWater}^m = 1$

Finally, we can calculate the canopy gross photosynthesis rate and monthly value with water stress effect:

$$\text{CanopyGrossPsnRate}^m = \text{CanopyGrossPsn}^m \cdot \text{DWater}^m$$

$$\text{CanopyGrossPsnAct}^m = \text{CanopyGrossPsnRate}^m \cdot \text{Dayspan}^m$$

$$\text{GrsPsn}^m = \text{CanopyGrossPsnAct}^m$$

$$\text{NetPsn}^m = (\text{CanopyGrossPsnRate}^m - (\text{DayResp}^m + \text{NightResp}^m) \cdot \text{FolMass}^m) \cdot \text{Dayspan}^m$$


## Water storage 

The amount of water available in this month is:

$$\text{Water}^m = \text{Water}^{m-1} + \text{WaterIn}^m$$

And, if current amount of water is greater than the water holding capacity ($\textcolor{cyan}{\text{WHC}}$), i.e., $\text{Water}^m > \textcolor{cyan}{\text{WHC}}$, the additional water would drain away and $\text{Water}^m$ would just be $\textcolor{cyan}{\text{WHC}}$.

$$\text{Drainage}^m = \max(0, \text{Water}^m - \textcolor{cyan}{\text{WHC}})$$

$$\text{Water}^m = \textcolor{cyan}{\text{WHC}}$$

Otherwise, $\text{Drainage}^m = 0$

Finally, we can summarize the following accumulated annual variables in the current month:

- $\text{TotDrainage}^m = \text{Drainage}^m + \text{FastFlow}^m$
- $\text{TotTrans}^m = \text{TotTrans}^m + \text{Trans}^m$
- $\text{TotPsn}^m = \text{TotPsn}^m + \text{NetPsn}^m$
- $\text{TotDrain}^m = \text{TotDrain}^m + \text{Drainage}^m$
- $\text{TotPrep}^m = \text{TotPrep}^m + \textcolor{lime}{\text{Prep}^m}$
- $\text{TotEvap}^m = \text{TotEvap}^m + \text{Evap}^m$
- $\text{TotGrossPsn}^m = \text{TotGrossPsn}^m + \text{GrsPsn}^m$
- $\text{TotET}^m = \text{Trans}^m + \text{Evap}^m$
