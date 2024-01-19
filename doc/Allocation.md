# Allocation

Here are the variables involved (See [variables_table](/doc/paramters_table.md) for description):

- Monthly allocation
	- BudC
	- WoodC
	- RootC
	- PlantC
	- WoodMRespYr
	- FolProdCYr
	- FolGRespYr
	- GDDWoodEff
	- WoodProdCYr
	- WoodGRespYr
	- RootProdCYr
	- RootMRespYr
	- RootGRespYr
	- NetCBal
- Annual allocation
	- BudC
	- WoodC
	- RootC
	- PlantC
	- NPPFolYr
	- NPPWoodYr
	- NPPRootYr
	- FolMassMax (in VegPar)
	- FolMassMin (in VegPar)
	- NEP
	- FolN (PnET-CN)
	- FolC (PnET-CN)
	- TotalN (PnET-CN)
	- TotalM (PnET-CN)
	- BudN (PnET-CN)
	- PlantN (PnET-CN)
	- FolNCon (PnET-CN)

## Monthly allocation

The plant carbon pool in current month:

$$\text{PlantC}^m = \text{PlantC}^{m-1} + \text{NetPsn}^m - \text{FolGResp}^m$$

### Wood carbon allocation

<!-- TODO: does this make sense? -->

The wood maintenance respiration is calculated as a fraction of canopy gross photosynthesis with water stress:

$$\text{WoodMResp}^m = \text{CanopyGrossPsnAct}^m \cdot \textcolor{cyan}{\text{WoodMRespA}}$$

The annual wood respiration, foliage production, and foliage respiration are accumulated:

$$\text{WoodMRespYr} = \Sigma_{m=1}^{12} \text{WoodMResp}^m$$

$$\text{FolProdCYr} = \Sigma_{m=1}^{12} \text{FolProdCMo}$$

$$\text{FolGRespYr} = \Sigma_{m=1}^{12} \text{FolGRespMo}$$

Note that $\text{FolProdCMo}$ and $\text{FolGRespMo}$ are calculated in the phenology section.

If $\text{GDD}_{\text{total}} \geq \textcolor{cyan}{\text{GDDWoodStart}}$, which means wood production has started:

$$\text{GDDWoodEff}^m = \frac{\text{GDD}_{\text{total}}^m - \textcolor{cyan}{\text{GDDWoodStart}}}{\textcolor{cyan}{\text{GDDWoodEnd}} - \textcolor{cyan}{\text{GDDWoodStart}}}$$

$$\text{GDDWoodEff}^m = max(0, min(1.0, \text{GDDWoodEff}^m))$$

$$\text{delGDDWoodEff}^m = \text{GDDWoodEff}^m - \text{GDDWoodEff}^{m-1}$$

The produced wood for this month is:

$$\text{WoodProdC}^m = \text{WoodC}^m \cdot \text{delGDDWoodEff}^m$$

The growth respiration of the wood is:

$$\text{WoodGResp}^m = \text{WoodProdC}^m \cdot \textcolor{cyan}{\text{GRespFrac}}$$

Annual wood carbon production and growth respiration are:

$$\text{WoodProdCYr} = \Sigma_{m=1}^{12} \text{WoodProdC}^m$$

$$\text{WoodGRespYr} = \Sigma_{m=1}^{12} + \text{WoodGResp}^m$$

Otherwise, if $\text{GDD}_{\text{total}} < \textcolor{cyan}{\text{GDDWoodStart}}$, which means wood production has not started, $\text{WoodProdC}^m$ and $\text{WoodGResp}^m$ are both 0.

### Root carbon allocation

This month's added root carbon is calculated as a linear function of $\text{FolProdC}^m$:

$$\text{RootCAdd}^m = \textcolor{cyan}{\text{RootAllocA}} \cdot (\text{Dayspan}^m / 365.0) + \textcolor{cyan}{\text{RootAllocB}} \cdot \text{FolProdC}^m$$

<!-- TODO: this part is a bit confusing. -->

Then, this month's accumulated root carbon is:

$$\text{RootC}^m = \text{RootC}^{m-1} + \text{RootCAdd}^m$$

$$\text{TMult} = (\exp(0.1 \cdot (\text{Tavg} - 7.1)) \cdot 0.68) \cdot 1.0$$

$$\text{RootAllocC}^m = \min(1.0, ((1.0 / 12.0) \cdot \text{TMult})) \cdot \text{RootC}^m$$

The remaining Root carbon is:

$$\text{RootC}^m = \text{RootC}^m - \text{RootAllocC}^m$$

The monthly and annual root carbon production is:

$$\text{RootProdC}^m = \frac{\text{RootAllocC}^m}{1.0 + \textcolor{cyan}{\text{RootMRespFrac}^{sp}} + \textcolor{cyan}{\text{GRespFrac}^{sp}}}$$

$$\text{RootProdCYr} = \Sigma_{m=1}^{12} \text{RootProdC}^m$$

The monthly and annual root maintenance respiration is calculated as:

$$\text{RootMResp}^m = \text{RootProdC}^m \cdot \textcolor{cyan}{\text{RootMRespFrac}}$$

$$\text{RootMRespYr} = \Sigma_{m=1}^{12} \text{RootMResp}^m$$

The monthly and annual growth respiration is calculated as:

$$\text{RootGResp}^m = \text{RootProdC}^m \cdot \textcolor{cyan}{\text{GRespFrac}}$$

$$\text{RootGRespYr} = \Sigma_{m=1}^{12} \text{RootGResp}^m$$

The remaining plant carbon pool is then:

$$\text{PlantC} = \text{PlantC} - \text{RootCAdd} - \text{WoodMResp}^m - \text{WoodGResp}^m$$

And the net carbon balance is:

$$\text{NetCBal} = \text{NetPsnMo} - \text{SoilRespMo} - \text{WoodMResp}^m - \text{WoodGResp}^m - \text{FolGRespMo}$$


## Annual carbon allocation

In addition to monthly carbon allocation, there is also an annual carbon allocation.

Annual NPP for foliage, wood, and root:

$$\text{NPPFolYr} = \text{FolProdCYr} / \textcolor{cyan}{\text{CFracBiomass}^{sp}}$$

$$\text{NPPWoodYr} = \text{WoodProdCYr} / \textcolor{cyan}{\text{CFracBiomass}^{sp}}$$

$$\text{NPPRootYr} = \text{RootProdCYr} / \textcolor{cyan}{\text{CFracBiomass}^{sp}}$$

The average water effect on photosynthesis:

$$\text{AvgDWater} = \begin{cases}
	\text{Dwatertot} / \text{DwaterIx} & \text{DwaterIx} > 0 \\
	1 & \text{DwaterIx} \leq 0
\end{cases}$$

The average PCBM:

$$\text{avgPCBM} = \begin{cases}
	\text{PosCbalMassTot} / \text{PosCBalMassIx} & \text{PosCBalMassIx} > 0 \\
	\text{FolMass} & \text{PosCBalMassIx} \leq 0
\end{cases}$$

$$\text{EnvMaxFol} = (\text{AvgDWater} \cdot \text{avgPCBM}) \cdot (1 + \text{FolRelGrowMax} \cdot \text{LightEffMin})$$

$$\text{SppMaxFol} = \text{avgPCBM} \cdot (1 + \text{FolRelGrowMax} \cdot \text{LightEffMin})$$

The maximum and minimum foliage of the vegetation is:

$$\text{FolMassMax} = \min(\text{EnvMaxFol}, \text{SppMaxFol})$$

$$\text{FolMassMin} = \text{FolMassMax} - \text{FolMassMax} \cdot \frac{1}{\text{FolReten}}$$

$$\text{BudC} = \min(0, (\text{FolMassMax} - \text{FolMass}) \cdot \text{CFracBiomass})$$

$$\text{PlantC} = \text{PlantC} - \text{BudC}$$

$$\text{WoodC} = (1 - \text{PlantCReserveFrac}) \cdot \text{PlantC}$$

<!-- TODO: BudC and WoodC may be calibrated later but seems PlantC does not, why? -->

$$\text{PlantC} = \text{PlantC} - \text{WoodC}$$

$\text{MinWoodFolRatio}$ controls the minimum ratio of wood carbon to bud carbon, so if the calculated $\text{WoodC} < \text{MinWoodFolRatio} \cdot \text{BudC}$, the $\text{WoodC}$ and $\text{BudC}$ need to be calibrated:

$$\text{TotalC} = \text{WoodC} + \text{BudC}$$

$$\text{WoodC} = \text{TotalC} \cdot \frac{\text{MinWoodFolRatio}}{1 + \text{MinWoodFolRatio}}$$

$$\text{BudC} = \text{TotalC} - \text{WoodC}$$

The annual maximum and minimum foliar mass are updated as:

$$\text{FolMassMax} = \text{FolMass} + \frac{\text{BudC}}{\text{CFracBiomass}}$$

$$\text{FolMassMin} = \text{FolMassMax} - \text{FolMassMax} \cdot \frac{1}{\text{FolReten}}$$

The annual NEP is then:

$$\text{NEP} = \text{TotPsn} - \text{WoodMRespYr} - \text{WoodGRespYr} - \text{FolGRespYr} - \text{SoilRespYr}$$

### PnET-CN only

For PnET-CN, there is also an annual allocation routine for N that determines the relative degree of N limitation on plants and the effect of this limitation on N content of foliage and other tissues. Carbon and nitrogen for next year's foliar and wood production are also transferred to bud and wood compartments.

$\text{NRatio}$ is central to the interactions between carbon and nitrogen cycles and expresses the degree of N limitation on plant function. This in turn affects both the nitrogen concentration in foliage, and so maximum rates of photosynthesis, and also the fraction of mineralized N which is nitrified. $\text{NRatio}$ is determined by the amount of mobile N in the plant ($\text{PlantN}$) relative to a specified maximum value ($\textcolor{cyan}{\text{MaxNStore}}$). An additional variable ($\text{FolNConRange}$) limits the range of $\text{NRatio}$, which is calculated as:

$$\text{NRatio} = 1 + (\text{PlantN} / \textcolor{cyan}{\text{MaxNStore}}) \cdot \text{FolNConRange}$$

where $\text{FolNConRange}$ establishes the maximum fractional increase in N concentration in foliage relative to the minimum or critical concentration. This in turn is determined by the re-translocation fraction from senescing foliage times the minimum concentration in litter. No re-translocation is assumed to occur from wood and fine roots.

The amount of $\text{PlantN}$ transferred to $\text{BudN}$ for next year's foliar growth is:

$$\text{BudN} = \text{BudC} / \textcolor{cyan}{\text{CFracFol}} \cdot \text{FLPctN} \cdot (\frac{1}{1 - \textcolor{cyan}{\text{FolNRetrans}}}) \cdot \text{NRatio}$$

where $\text{BudC}$ is the amount of carbon allocated to next year's foliar production. $\textcolor{cyan}{\text{CFracFol}}$ is the fraction of carbon in foliar biomass. $\text{FLPctN}$ is the minimal percent N in foliar litter. 

Then, the next year's foliar N concentration ($\text{FolNCon}$) is determined as:

$$\text{FolNCon} = \frac{\text{FolMass} \cdot \text{FolNCon} / 100 + \text{BudN}}{\text{FolMass} + \text{BudC} / \textcolor{cyan}{\text{CFracBiomass}} \cdot 100}$$
