# Allocation

This routine allocates carbon and nitrogen to different parts of the plant system such as wood, root, and bud, in a monthly or annually time scale. Here are the variables involved (See [variables_table](/doc/paramters_table.md) for description):

- Monthly allocation
	- $\text{BudC}$: Bud carbon pool.
	- $\text{WoodC}$: Wood carbon pool.
	- $\text{RootC}$: Root carbon pool.
	- $\text{PlantC}$: Plant total carbon pool.
	- $\text{WoodMRespYr}$: Wood maintenance respiration.
	- $\text{FolProdCYr}$: The amount of carbon required by foliar production.
	- $\text{FolGRespYr}$: Foliar growth repiration.
	- $\text{GDDWoodEff}$: Growing degree day effect on wood production.
	- $\text{WoodProdCYr}$: The amount of carbon required by wood production.
	- $\text{WoodGRespYr}$: Wood growth respiration.
	- $\text{RootProdCYr}$: The amount of carbon required by root production.
	- $\text{RootMRespYr}$: The annual accumulated root maintanence respiration.
	- $\text{RootGRespYr}$: The annual accumulated root growth respiration.
	- $\text{NetCBal}$: Net carbon balance.
- Annual allocation
	- $\text{BudC}$: Bud carbon pool.
	- $\text{WoodC}$: Wood carbon pool.
	- $\text{RootC}$: Root carbon pool.
	- $\text{PlantC}$: Plant total carbon pool.
	- $\text{NPPFolYr}$: The annual accumulated net primary productivity of foliage.
	- $\text{NPPWoodYr}$: The annual accumulated net primary productivity of wood.
	- $\text{NPPRootYr}$: The annual accumulated net primary productivity of root.
	- $\text{FolMassMax}$ (in VegPar): The maximum foliage amount.
	- $\text{FolMassMin}$ (in VegPar): The minimum foliage amount.
	- $\text{NEP}$: Net ecosystem productivity.
	- $\text{FolN}$ (PnET-CN): Foliar nitrogen amount.
	- $\text{FolC}$ (PnET-CN): Foliar carbon amount.
	- $\text{TotalN}$ (PnET-CN): Total nitrogen amount.
	- $\text{TotalM}$ (PnET-CN): Total 
	- $\text{BudN}$ (PnET-CN): The amount of nitrogen in buds.
	- $\text{PlantN}$ (PnET-CN): The amount of nitrogen in plant.
	- $\text{FolNCon}$ (PnET-CN): Foliar nitrogen concentration.


## Monthly allocation

The plant carbon pool in current month is first calculated by considering this month's net photosynthesis ($\text{NetPsn}$) and foliar growth respiration ($\text{FolGResp}$):

$$\text{PlantC}^m = \text{PlantC}^{m-1} + \text{NetPsn}^m - \text{FolGResp}^m$$

Then, the available carbon is allocated to wood and root respectively.


### Wood carbon allocation

The wood maintenance respiration is calculated as a fraction of canopy gross photosynthesis with water stress:

$$\text{WoodMResp} = \text{CanopyGrossPsnAct} \cdot \textcolor{cyan}{\text{WoodMRespA}}$$

The annual wood respiration, foliage production, and foliage respiration are accumulated:

$$\text{WoodMRespYr} = \Sigma_{m=1}^{12} \text{WoodMResp}^m$$

$$\text{FolProdCYr} = \Sigma_{m=1}^{12} \text{FolProdCMo}$$

$$\text{FolGRespYr} = \Sigma_{m=1}^{12} \text{FolGRespMo}$$

Note that $\text{FolProdCMo}$ and $\text{FolGRespMo}$ are calculated in the [Phenology](/doc/phenology.md) routine.

Since wood production only happens in the growing season, we use $\text{GDDTot}^m \geq \textcolor{cyan}{\text{GDDWoodStart}}$ to determine when carbon should be allocated to wood production. The effect of GDD on this month's wood production is an empirical linear function:

$$\text{GDDWoodEff}^m = \frac{\text{GDDTot}^m - \textcolor{cyan}{\text{GDDWoodStart}}}{\textcolor{cyan}{\text{GDDWoodEnd}} - \textcolor{cyan}{\text{GDDWoodStart}}}$$

Note that $0 \le \text{GDDWoodEff} \le 1$. The additional GDD effect on wood production for this time step is then:

$$\text{delGDDWoodEff}^m = \text{GDDWoodEff}^m - \text{GDDWoodEff}^{m-1}$$

The wood production for this month is a fraction of the wood carbon pool and the additional GDD effect:

$$\text{WoodProdC}^m = \text{WoodC}^m \cdot \text{delGDDWoodEff}^m$$

The wood growth respiration is then a fraction of the $\text{WoodProdC}$:

$$\text{WoodGResp}^m = \text{WoodProdC}^m \cdot \textcolor{cyan}{\text{GRespFrac}}$$

Annual wood carbon production and growth respiration are:

$$\text{WoodProdCYr} = \Sigma_{m=1}^{12} \text{WoodProdC}^m$$

$$\text{WoodGRespYr} = \Sigma_{m=1}^{12} + \text{WoodGResp}^m$$

Otherwise, if $\text{GDDTot}^m < \textcolor{cyan}{\text{GDDWoodStart}}$, which means wood production has not started, $\text{WoodProdC}^m$ and $\text{WoodGResp}^m$ are both 0.


### Root carbon allocation

This month's added root carbon is calculated as a linear function of $\text{FolProdC}^m$:

$$\text{RootCAdd}^m = \textcolor{cyan}{\text{RootAllocA}} \cdot (\text{Dayspan}^m / 365.0) + \textcolor{cyan}{\text{RootAllocB}} \cdot \text{FolProdC}^m$$

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


### Update PlantC

After root and wood allocation, the remaining plant carbon pool is:

$$\text{PlantC}^m = \text{PlantC}^{m-1} - \text{RootCAdd}^m - \text{WoodMResp}^m - \text{WoodGResp}^m$$

And the net carbon balance is:

$$\text{NetCBal}^m = \text{NetPsnMo}^m - \text{SoilRespMo}^m - \text{WoodMResp}^m - \text{WoodGResp}^m - \text{FolGRespMo}^m$$


## Annual allocation

Annual allocation happens in the begining of a year, this routine allocates carbon and nitrogen (PnET-CN) into different pools and calculate annual net primary productivity (NPP) and carbon & nitrogen balance.

The maximum foliage of the vegetion is calculated as:

$$\text{FolMassMax} = \min(\text{EnvMaxFol}, \text{SppMaxFol})$$

where $\text{SppMaxFol}$ and $\text{EnvMaxFol}$ are calculated as:

$$\text{SppMaxFol} = \text{avgPCBM} \cdot (1 + \text{FolRelGrowMax} \cdot \text{LightEffMin})$$

$$\text{EnvMaxFol} = \text{avgDWater} \cdot \text{SppMaxFol}$$

in which the average positive carbon balance biomass ($\text{avgPCBM}$) and water effect on photosynthesis ($\text{avgDWater}$) are:

$$\text{avgPCBM} = \begin{cases}
	\text{PosCbalMassTot} / \text{PosCBalMassIx} & \text{PosCBalMassIx} > 0 \\
	\text{FolMass} & \text{PosCBalMassIx} \leq 0
\end{cases}$$

$$\text{avgDWater} = \begin{cases}
	\text{Dwatertot} / \text{DwaterIx} & \text{DwaterIx} > 0 \\
	1 & \text{DwaterIx} \leq 0
\end{cases}$$

The minimum foliage of the vegetation is a fraction of the $\text{FolMassMax}$:

$$\text{FolMassMin} = \text{FolMassMax} - \text{FolMassMax} \cdot 1 / \text{FolReten}$$

Now, allocate carbon to the bud carbon pool:

$$\text{BudC} = \min(0, (\text{FolMassMax} - \text{FolMass}) \cdot \text{CFracBiomass})$$

And, update the remaining $\text{PlantC}$:

$$\text{PlantC} = \text{PlantC} - \text{BudC}$$

Then, allocate carbon too the wood carbon pool:

$$\text{WoodC} = (1 - \text{PlantCReserveFrac}) \cdot \text{PlantC}$$

And, update the remaining $\text{PlantC}$ **again**:

$$\text{PlantC} = \text{PlantC} - \text{WoodC}$$

Note that $\text{MinWoodFolRatio}$ controls the minimum ratio of wood carbon to bud carbon, so if the calculated $\text{WoodC} < \text{MinWoodFolRatio} \cdot \text{BudC}$, $\text{WoodC}$ and $\text{BudC}$ need to be calibrated:

$$\text{TotalC} = \text{WoodC} + \text{BudC}$$

$$\text{WoodC} = \text{TotalC} \cdot \frac{\text{MinWoodFolRatio}}{1 + \text{MinWoodFolRatio}}$$

$$\text{BudC} = \text{TotalC} - \text{WoodC}$$

At the same time, the annual maximum and minimum foliar mass are updated as:

$$\text{FolMassMax} = \text{FolMass} + \frac{\text{BudC}}{\text{CFracBiomass}}$$

$$\text{FolMassMin} = \text{FolMassMax} - \text{FolMassMax} \cdot \frac{1}{\text{FolReten}}$$

At last, the annual net ecosystem productivity (NEP) is then calculated as:

$$\text{NEP} = \text{TotPsn} - \text{WoodMRespYr} - \text{WoodGRespYr} - \text{FolGRespYr} - \text{SoilRespYr}$$

Annual NPP for foliage, wood, and root:

$$\text{NPPFolYr} = \text{FolProdCYr} / \textcolor{cyan}{\text{CFracBiomass}^{sp}}$$

$$\text{NPPWoodYr} = \text{WoodProdCYr} / \textcolor{cyan}{\text{CFracBiomass}^{sp}}$$

$$\text{NPPRootYr} = \text{RootProdCYr} / \textcolor{cyan}{\text{CFracBiomass}^{sp}}$$

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


