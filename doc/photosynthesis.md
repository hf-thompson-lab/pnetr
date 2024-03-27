# Photosynthesis

This routine estimates photosynthesis **without water stress**. Here are the variables involved (See [variables_table](/doc/paramters_table.md) for description):

- $\text{DTemp}$: Temperature effect on photosynthesis.
- $\text{GrossAmax}$: Realized gross photosynthetic rate.
- $\text{LAI}$: Leaf area index.
- $\text{CanopyNetPsn}$: Canopy-level net photosynthesis.
- $\text{CanopyGrossPsn}$: Canopy-level gross photosynthesis.
- $\text{PosCBalMass}$: 
- $\text{PosCBalMassTot}$: 
- $\text{PosCBalMassIx}$:
- $\text{LightEffMin}$: Minimum light effect on photosynthesis.

And, for PnET-CN, these variables are also involved:

- $\text{DelAmax}$
- $\text{DWUE}$
- $\text{CanopyDO3Pot}$


## Calculate the realized gross photosynthetic rate

Considering seasonality, if foliar biomass $\text{FolMass}^t \leq 0$, there will not be photosynthesis and the following variables will be simply assigned 0: 
- $\text{PosCBalMass} = 0$
- $\text{CanopyNetPsn} = 0$
- $\text{CanopyGrossPsn} = 0$
- $\text{LAI} = 0$
- $\text{DayResp} = 0$
- $\text{NightResp} = 0$.

Otherwise, the realized gross photosynthetic rate ($\text{GrossAmax}$) is calculated by the potential photosynthesis ($\text{PotGrossAmax}$) under the effects of light ($\text{LightEff}$), temperature ($\text{DTemp}$), VPD (${\text{DVPD}}$), and water stress ($\text{DWater}$):

$$\text{GrossAmax} = \text{PotGrossAmax} \cdot \text{LightEff} \cdot \text{DTemp} \cdot \text{DVPD} \cdot \text{DWater}$$

Now, let's describe each variable sequentially.

### Calculate $\text{PotGrossAmax}$

$\text{PotGrossAmax}$ is determined by the instantaneous max net photosynthesis rate ($\text{Amax}$). $\text{Amax}$ follows a linear function of foliar N concentration ($\textcolor{cyan}{\text{FolNCon}}$) with empirical values of intercept ($\textcolor{cyan}{\text{AmaxA}}$) and slope ($\textcolor{cyan}{\text{AmaxB}}$):

$$\text{Amax} = \textcolor{cyan}{\text{AmaxA}} + \textcolor{cyan}{\text{AmaxB}} \cdot \textcolor{cyan}{\text{FolNCon}}$$

However, for PnET-CN, we need to add **CO2 effect on photosynthesis** ([Ollinger et al 2002](https://onlinelibrary.wiley.com/doi/abs/10.1046/j.1365-2486.2002.00482.x)) to the above equation:

$$\text{Amax} = \textcolor{cyan}{\text{AmaxA}} + \textcolor{cyan}{\text{AmaxB}} \cdot \textcolor{cyan}{\text{FolNCon}} \cdot \text{DelAmax}$$

<!-- #HACK: understand this! -->
where $\text{DelAmax}$ is determined by the CO2 concentration and the foliar nitrogen concentration ($\text{FolNCon}$):

$$\text{DelAmax} = 1 + \frac{\text{Arel}_{Elev} - \text{Arel}_{350}}{\text{Arel}_{350}}$$

$$\text{Arel} = 1.22 + \frac{C_i - 68}{C_i + 136}$$

$$C_i = C_a \cdot \text{CiCaRatio}$$

$$\text{CiCaRatio} = -0.075 \cdot \text{FolNCon} + 0.0875$$

$$\text{Arel}_{350} = \text{Arel}(C_i = 350) = \text{Arel}(C_i(C_a = 350))$$

Daily averaged instantaneous max net photosynthesis rate ($\text{Amax}^d$) is then calculated as a fraction ($\textcolor{cyan}{\text{AmaxFrac}}$) of the $\text{Amax}$, reflecting the fact that $\text{Amax}$ is not maintained throughout an entire day due to light limitation, increased evaporative demand, etc.:

$$\text{Amax}^d = \text{Amax} \cdot \textcolor{cyan}{\text{AmaxFrac}}$$

A basal respiration rate at 20 °C ($\text{BaseFolResp}$) is calculated as a fraction ($\textcolor{cyan}{\text{BaseFolRespFrac}}$) of $\text{Amax}$:

$$\text{BaseFolResp} = \textcolor{cyan}{\text{BaseFolRespFrac}} \cdot \text{Amax}$$

Then, the realized daytime and nighttime respirations are calculated using a $Q_{10}$ factor specified by $\textcolor{cyan}{\text{RespQ10}}$:

$$\begin{align*}
\text{Resp} &= f_{Resp}(\text{BaseFolResp}, \text{T}, \text{Time}) \\ &= (\text{BaseFolResp} \cdot \textcolor{cyan}{\text{RespQ10}}^{(\text{T} - \textcolor{cyan}{\text{PsnTopt}}) / 10} \cdot \text{Time} \cdot 12) / 10^9
\end{align*}$$

$$\text{DayResp} = f_{Resp}(\text{BaseFolResp}, \text{T}_{day}, \text{Daylength})$$

$$\text{NightResp} = f_{Resp}(\text{BaseFolResp}, \text{T}_{night}, \text{Nightlength})$$

> Note that for PnET-Day and PnET-II, the above variables ($\text{Amax}$, $\text{Amax}^d$, $\text{BaseFolResp}$, $\text{DayResp}$, $\text{NightResp}$) can be calculated once and they don't change throughout the entire simulation. For PnET-CN, because $\text{FolNCon}$ changes year to year, those variables cannot be calculated at one go.

Then, $\text{PotGrossAmax}$ can be calculated by adding $\text{Amax}^{d}$ and $\text{BaseFolResp}$:

$$\text{PotGrossAmax} = \text{Amax}^d + \text{BaseFolResp}$$

### Temperature effect on photosynthesis ($\text{DTemp}$)

Daytime and nighttime leaf respiration ($\text{DayResp}, \text{NightResp}$) is a function of $A_{\max}$ and temperature. Maximum (summer) and minimum (winter) leaf mass are input parameters. (Aber et al 1992, Eq. 6. Slightly different)

$${\text{DTemp}} = \frac{(\textcolor{cyan}{\text{Psn}T_\text{max}} - T_{\text{day}}) \cdot (T_{\text{day}} - \textcolor{cyan}{\text{Psn}T_\text{min}})}{((\textcolor{cyan}{\text{Psn}T_\text{max}} - \textcolor{cyan}{\text{Psn}T_\text{min}}) / 2)^2}$$

<!-- #HACK: what does this mean? -->
However, if $\text{T}_{min}^t < 6$ & $\text{DTemp}^t > 0$ & $\text{GDDTot}^t \geq \textcolor{cyan}{\text{GDDFolEnd}}$:

$$\text{DTemp} = \text{DTemp} \cdot (1 - \frac{6 - \text{T}_{min}}{6})$$

Note that $\text{DTemp} \ge 0$.

### VPD effect on photosynthesis (${\text{DVPD}}$)

The VPD effect on photosynthesis is determined by an empirical function with 2 parameters ($\text{DVPD1}$ and $\text{DVPD2}$):

$${\text{DVPD}} = 1 - \textcolor{cyan}{\text{DVPD1}} \cdot ({\text{VPD}}) ^{\textcolor{cyan}{\text{DVPD2}}}$$

### Simulate canopy layers

The above response functions for temperature and vapor pressure deficit (VPD) are for calculating the realized $A_{\max}$ for leaves at the top of the canopy, but the canopy is a vertical structure and light conditions are different at different canopy layers. We can simulate the layered canopy with both radiation intensity and specific leaf weight ($\text{SLW}$) declining with canopy depth. To calculate the accumulated variables, we simulate the canopy to have `nlayer` of layers (`nlayer = 50` by default). For each layer `i`, we estimate a $\text{LightEff}_i$ and use it to calculate a realized layer-level gross photosynthesis ($\text{LayerGrossPsn}_i$) and net photosynthesis ($\text{LayerNetPsn}_i$). Specifically, $\text{LayerGrossAmax}_i$ without water stress is calculated by:

$$\text{LayerGrossAmax}_i = \text{PotGrossAmax} \cdot \text{LightEff}_i \cdot {\text{DVPD}} \cdot \text{DTemp}\cdot \text{DayLength} \cdot 12 / 10^9$$

Note that $\text{LayerGrossAmax}_i \ge 0$.

To estimate $\text{LightEff}_i$, we do the following:

- We use average foliar mass ($\text{AvgFolMass}$) to represent the foliar mass in this layer:

$$\text{AvgFolMass} = \text{FolMass}^t / \text{nlayer}$$

- Photosynthesis and respiration are calculated on a per unit mass basis, while light attenuation is described by a function of leaf area. So, we use SLW to convert foliar mass to area. Using $\textcolor{cyan}{\text{SLWmax}}$ to represent the SLW at the top of the canopy, and $\textcolor{cyan}{\text{SLWdel}}$ to represent the change in SLW with canopy depth expressed as total foliar mass above a given layer. The layer-specific leaf weight ($\text{SLWLayer}_i$) can be calculated using the top sunlit canopy SLW minus change in SLW with increasing foliar mass:

$$\text{SLWLayer}_i = \textcolor{cyan}{\text{SLWmax}} - \textcolor{cyan}{\text{SLWdel}} \cdot i$$

- Accumulated LAI at this layer is then:

$$\text{LAI}_i = \text{LAI}_{i-1} + \text{AvgFolMass} / \text{SLWLayer}_i$$

- Light attenuation in forest canopy is described by the Beers-Lambert exponential decay equation and the effect of light on gross photosynthesis at this layer is (Aber et al 1992, Eq. 8, Eq. 9):

$$I_i = \text{PAR}^t \cdot exp(-\textcolor{cyan}{k} \cdot \text{LAI}_i)$$

- At last:

$$\text{LightEff}_i = 1.0 - exp(-\frac{I_i \ln(2)}{\textcolor{cyan}{\text{HalfSat}}})$$

Then, this layer's gross and net photosynthesis without water stress is:

$$\text{LayerGrossPsn}_i = \text{LayerGrossAmax}_i \cdot \text{AvgFolMass}$$

$$\begin{align*}
	\text{LayerNetPsn}_i &= \text{layerGrossPsn}_i - \text{LayerResp}_i \\
	&= \text{layerGrossPsn}_i - (\text{DayResp} + \text{NightResp}) \cdot \text{AvgFolMass}
\end{align*}$$

<!-- #HACK: understand this -->
However, if $\text{LayerNetPsn}_i < 0$ & $\text{PosCBalMass} == \text{FolMass}$, meaning that net photosynthesis for this layer is negative and the layer is beyond the positive carbon balance mass, we assign the positive carbon balance mass to be the previous layer's accumulated mass:

$$\text{PosCBalMass} = (i -1) \cdot \text{AvgFolMass}$$

Note that for PnET-CN, we should also consider **Ozone effect on net photosyntheis** ([Ollinger et al 1997](http://doi.wiley.com/10.1890/1051-0761(1997)007[1237:SOEOFP]2.0.CO;2)). The ratio of ozone-exposed to control photosynthesis is calculated as:

$$d\text{O3} = 1 - 2.6 \cdot 10^{-6} \cdot g \cdot \text{D40}$$

where $g$ is mean stomatal conductance to water vapor ($mm \cdot s^{-1}$) and $\text{D40}$ is the cumulative ozone dose above 40 $nmol \cdot mol^{-1}$. However, to integrate the ozone effect on the vertical structure of the canopy, in the canopy layer simulation, we calculate the stomatal conductance $g_i$ for the layer $i$ by an empirical linear function of potential net photosynthesis:

$$g_i = \text{intercept} + \text{slope} \cdot \text{LayerNetPsn}_i$$

Then, we calculate the $\text{D40}_i$ using the following empirical equation:

$$\text{D40}_i = 1 - (\frac{i}{\text{nlayer}} \cdot \alpha)^3$$

Where $\alpha$ is determined by a linear function of foliar biomass ($\text{FolMass}$):

$$\alpha = 0.6163 + (0.00105 \cdot \text{FolMass})$$

Because water stress, or drought, affects stomatal conductance and the ozone effect above is calculated as a function of stomatal conductance, we further reduce the whole-canopy ozone effect in proportion to the drought experienced:

$$\text{O3Effect}_i = \text{O3Effect}_i \cdot \text{DroughtO3Frac} + 2.6 \cdot 10^{-6} \cdot g_i \cdot \text{D40}_i$$

Where $\text{DroughtO3Frac}$ is calculated in the [Water Balance](/doc/water_balance.md) routine. And:

$$d\text{O3}_i = 1 - \text{O3Effect}_i$$

Then, we modify the layer net photosyntheis ($\text{LayerNetPsn}_i$) to get layer net photosynthesis under the ozone effect ($\text{LayerNetPsnO3}_i$):

$$\text{LayerNetPsnO3}_i = \text{LayerNetPsn}_i \cdot d\text{O3}_i$$

Finally, the accumulated gross and net photosynthesis without water stress for the whole canopy are:

$$\text{CanopyGrossPsn} = \Sigma_{i=1}^{\text{nlayer}} \text{LayerGrossPsn}_i$$

$$\text{CanopyNetPsn}_i = \Sigma_{i=1}^{\text{nlayer}} \text{LayerNetPsn}_i$$

$$\text{CanopyNetPsnO3}_i = \Sigma_{i=1}^{\text{nlayer}} \text{LayerNetPsnO3}_i$$

If $\text{DTemp}^t > 0$ & $\text{GDDTot}^t > \textcolor{cyan}{\text{GDDFolEnd}}$ & $\text{DOY}^t < \textcolor{cyan}{\text{SenescStart}}$:

$$\text{PosCBalMassTot}^t = \text{PosCBalMassTot}^{t-1} + (\text{PosCBalMass}^t \cdot \text{Dayspan})$$

$$\text{PosCBalMassIx}^t = \text{PosCBalMassIx}^{t-1} + (\text{PosCBalMass}^t \cdot \text{Dayspan})$$
