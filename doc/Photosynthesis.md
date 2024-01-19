# Photosynthesis

Here are the variables involved (See [variables_table](/doc/paramters_table.md) for description):

- DTemp
- GrossAmax
- PosCBalMass
- LAI
- CanopyNetPsn
- CanopyGrossPsn
- PosCBalMassTot
- PosCBalMassIx
- LightEffMin

## Calculate the realized gross photosynthetic rate

Considering seasonality, if foliar biomass $\text{FolMass}^m \leq 0$, there will not be photosynthesis and the following variables will be simply assigned 0: $\text{PosCBalMass}$, $\text{CanopyNetPsn}$, $\text{CanopyGrossPsn}$, $\text{LAI}$, $\text{DayResp}$, $\text{NightResp}$.

Otherwise, the realized gross photosynthetic rate ($\text{GrossAmax}$) is calculated by the potential photosynthesis under the effects of light ($\text{LightEff}$), temperature ($\text{DTemp}$), VPD (${\text{DVPD}}$), and water stress ($\text{DWater}$):

$$\text{GrossAmax} = \text{PotGrossAmax} \cdot \text{LightEff} \cdot \text{DTemp} \cdot \text{DVPD} \cdot \text{DWater}$$

Now, let's describe each variable sequentially.

### Calculate $\text{PotGrossAmax}$

$\text{PotGrossAmax}$ is determined by the instantaneous max net photosynthesis rate ($\text{Amax}$). $\text{Amax}$ follows a linear function of foliar N concentration ($\textcolor{cyan}{\text{FolNCon}}$) with empirical values of intercept ($\textcolor{cyan}{\text{AmaxA}}$) and slope ($\textcolor{cyan}{\text{AmaxB}}$):

$$\text{Amax} = \textcolor{cyan}{\text{AmaxA}} + \textcolor{cyan}{\text{AmaxB}} \cdot \textcolor{cyan}{\text{FolNCon}}$$

Daily averaged instantaneous max net photosynthesis rate ($\text{Amax}^d$) is then calculated as a fraction ($\textcolor{cyan}{\text{AmaxFrac}}$) of the $\text{Amax}$, reflecting the fact that $\text{Amax}$ is not maintained throughout an entire day due to light limitation, increased evaporative demand, etc.:

$$\text{Amax}^d = \text{Amax} \cdot \textcolor{cyan}{\text{AmaxFrac}}$$

A basal respiration rate at 20 °C ($\text{BaseFolResp}$) is calculated as a fraction ($\textcolor{cyan}{\text{BaseFolRespFrac}}$) of $\text{Amax}$:

$$\text{BaseFolResp} = \textcolor{cyan}{\text{BaseFolRespFrac}} \cdot \text{Amax}$$

Then, the realized daytime and nighttime respirations are calculated using a $Q_{10}$ factor specified by $\textcolor{cyan}{\text{RespQ10}}$.

$$\text{DayResp}^m = (\text{BaseFolResp} \cdot \textcolor{cyan}{\text{RespQ10}}^{(\text{T}_{day}^m - \textcolor{cyan}{\text{PsnTopt}}) / 10} \cdot \text{Daylength}^m \cdot 12) / 10^9$$

$$\text{NightResp}^m = (\text{BaseFolResp} \cdot \textcolor{cyan}{\text{RespQ10}}^{(\text{T}_{night}^m - \textcolor{cyan}{\text{PsnTopt}}) / 10} \cdot \text{Nightlength}^m \cdot 12) / 10^9$$

Note that the above variables ($\text{Amax}$, $\text{Amax}^d$, $\text{BaseFolResp}$, $\text{DayResp}^m$, $\text{NightResp}^m$) can be calculated once and they don't change throughout the entire simulation.

Then, $\text{PotGrossAmax}$ can be calculated by adding $\text{Amax}^{d}$ and $\text{BaseFolResp}$:

$$\text{PotGrossAmax} = \text{Amax}^d + \text{BaseFolResp}$$

### Temperature effect on photosynthesis ($\text{DTemp}$)

Response functions for radiation intensity, temperature, and vapor pressure deficit (VPD) are used with daily mean climate drivers to calculate the realized $A_{\max}$ for leaves at the top of the canopy. Then, a layered canopy is simulated with both radiation intensity and specific leaf weight ($\text{SLW}$) declining with canopy depth. Daytime and nighttime leaf respiration ($\text{DayResp}, \text{NightResp}$) is a function of $A_{\max}$ and temperature. Maximum (summer) and minimum (winter) leaf mass are input parameters. (Aber et al 1992, Eq. 6. Slightly different)

$${\text{DTemp}}^m = \frac{(\textcolor{cyan}{\text{Psn}T_\text{max}} - T_{\text{day}}^m) \cdot (T_{\text{day}}^m - \textcolor{cyan}{\text{Psn}T_\text{min}})}{((\textcolor{cyan}{\text{Psn}T_\text{max}} - \textcolor{cyan}{\text{Psn}T_\text{min}}) / 2)^2}$$

If $T_{min}^m < 6$ & $\text{DTemp}^m > 0$ & $\text{GDD}_{\text{total}}^m \geq \textcolor{cyan}{\text{GDDFolEnd}^{sp}}$:

$$\text{DTemp}^m = \text{DTemp}^m \cdot (1 - \frac{6 - T_{min}^m}{6}) \cdot (\text{Dayspan}^m / 30)$$

End

$$\text{DTemp}^m = \max(\text{DTemp}^m, 0)$$

### VPD effect on photosynthesis (${\text{DVPD}}$)

$${\text{DVPD}}^m = 1 - \textcolor{cyan}{\text{DVPD1}} \cdot ({\text{VPD}^m}) ^{\textcolor{cyan}{\text{DVPD2}}}$$

### Simulate canopy layers

Since a canopy is a vertical structure, light conditions are different at different canopy layers. To calculate the accumulated variables, we simulate the canopy to have `nlayer` of layers (`nlayer = 50` by default). For each layer `i`, we estimate a $\text{LightEff}_i$ and use it to calculate a realized layer-level gross photosynthesis ($\text{LayerGrossPsn}$) and net photosynthesis ($\text{LayerNetPsn}$). Specifically, $\text{LayerGrossAmax}$ without water stress is calculated by:

$$\text{LayerGrossAmax}_i = \begin{cases}
	0 & \text{LayerGrossAmax}_i \le 0 \\
	\text{PotGrossAmax} \cdot \text{LightEff}_i \cdot {\text{DVPD}} \cdot \text{DTemp}\cdot \text{DayLength} \cdot 12 / 10^9 & \text{LayerGrossAmax}_i > 0
\end{cases}$$

and to estimate $\text{LightEff}_i$, we do the following:

- We use average foliar mass ($\text{AvgFolMass}$) to represent the foliar mass in this layer:

$$\text{AvgFolMass} = \text{FolMass}^m / \text{nlayer}$$

- Photosynthesis and respiration are calculated on a per unit mass basis, while light attenuation is described by a function of leaf area. So, we use SLW to convert foliar mass to area. $\textcolor{cyan}{\text{SLWmax}}$ is the SLW at the top of the canopy, and $\textcolor{cyan}{\text{SLWdel}}$ is the change in SLW with canopy depth expressed as total foliar mass above a given layer.
- Calculate layer-specific leaf weight (SLW) using the top sunlit canopy SLW minus change in SLW with increasing foliar mass:

$$\text{SLWLayer}_i = \textcolor{cyan}{\text{SLWmax}} - \textcolor{cyan}{\text{SLWdel}} \cdot i$$

- Accumulated LAI at this layer is:

$$\text{LAI}_i = \text{LAI}_{i-1} + \text{AvgFolMass} / \text{SLWLayer}_i$$

- Light attenuation in forest canopy is described by the Beers-Lambert exponential decay equation and the effect of light on gross photosynthesis at this year are (Aber et al 1992, Eq. 8, Eq. 9):

$$I_i = \text{PAR}^m \cdot exp(-\textcolor{cyan}{k} \cdot \text{LAI}_i)$$

- At last

$$\text{LightEff}_i = 1.0 - exp(-(I_i \ln(2)) / \textcolor{cyan}{\text{HalfSat}})$$

Then, this layer's gross and net photosynthesis without water stress is:

$$\text{LayerGrossPsn}_i = \text{LayerGrossAmax}_i \cdot \text{AvgFolMass}$$

$$\begin{align*}
	\text{LayerNetPsn}_i &= \text{layerGrossPsn}_i - \text{LayerResp}_i \\
	&= \text{layerGrossPsn}_i - (\text{DayResp} + \text{NightResp}) \cdot \text{AvgFolMass}
\end{align*}$$

However, if $\text{LayerNetPsn}_i < 0$ & $\text{PosCBalMass} == \text{FolMass}$, meaning that net photosynthesis for this layer is negative and the layer is beyond the positive carbon balance mass, we assign the positive carbon balance mass to be the previous layer's accumulated mass:

$$\text{PosCBalMass}^m = (i -1) \cdot \text{AvgFolMass}$$

Finally, the accumulated gross and net photosynthesis without water stress for the whole canopy are:

$$\text{CanopyGrossPsn} = \Sigma_{i=1}^{\text{nlayer}} \text{LayerGrossPsn}_i$$

$$\text{CanopyNetPsn}_i = \Sigma_{i=1}^{\text{nlayer}} \text{LayerNetPsn}_i$$

If $\text{DTemp}^m > 0$ & $\text{GDD}_{\text{total}} > \textcolor{cyan}{\text{GDDFolEnd}^{st}}$ & $\text{DOY}^m < \textcolor{cyan}{\text{SenescStart}^{st}}$:

$$\text{PosCBalMassTot}^m = \text{PosCBalMassTot}^{m-1} + (\text{PosCBalMass}^m \cdot \text{Dayspan}^m)$$

$$\text{PosCBalMassIx}^m = \text{PosCBalMassIx}^{m-1} + (\text{PosCBalMass}^m \cdot \text{Dayspan}^m)$$

