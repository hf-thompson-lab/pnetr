# CNTrans

This routine calculates litterfall and transfers to soil organic matter (SOM). Here are the variables involved (See [variables_table](/doc/paramters_table.md) for description).

- $\text{HOM}$
- $\text{HON}$
- $\text{RootMass}$: Root biomass.
- $\text{RootMassN}$: Nitrogen in root biomass.
- $\text{WoodMass}$: Wood biomass.
- $\text{WoodMassN}$: Nitrogen in wood biomass.
- $\text{WoodDecResp}$: Wood decay respiration.
- $\text{WoodDecRespYr}$: The annual accumulated wood decay respiration.
- $\text{DeadWoodM}$: Dead wood biomass.
- $\text{DeadWoodN}$: Nitrogen in dead wood biomass.
- $\text{NetCBal}$: Net carbon balance.
- $\text{PlantN}$: Plant nitrogen pool.
- $\text{FolLitM}$: Foliar litter biomass.
- $\text{FolMass}$: Foliar mass.
- $\text{PlantC}$: Plant carbon pool.
- $\text{TotalLitterM}$: Total litter biomass.
- $\text{TotalLitterMYr}$: The annual accumulated total litter biomass.
- $\text{TotalLitterN}$: Nitrogen in total litter biomass.
- $\text{TotalLitterNYr}$: The annual accumulated nitrogen in total litter biomass.


## Root litter biomass and N

The root litter biomass is calculated as a turnover fraction ($\text{RootTurnover}$) of root biomass ($\text{RootMass}$):

$$\text{RootLitM} = \text{RootMass} \cdot \text{RootTurnover}$$

where the root turnover fraction is calculated:

$$\text{RootTurnover} = \textcolor{cyan}{\text{RootTurnoverA}} + \textcolor{cyan}{\text{RootTurnoverB}} \cdot \text{NMin} + \textcolor{cyan}{\text{RootTurnoverC}} \cdot \text{NMin}^2$$

Note that $0.1 \le \text{RootTurnover} \le 2.5$. To calibrate $\text{RootTurnover}$ to the current time step, we do:

$$\text{RootTurnover}^m = \text{RootTurnover} \cdot \text{Dayspan}^m / 365$$

Also, $\text{RootTurnover}$ is less than the biomass loss fraction ($\text{BiomLossFrac}$, which is determined by disturbance), i.e., $\text{RootTurnover} < \text{BiomLossFrac}$.

And, the amount of nitrogen in the root litter ($\text{RootLitN}$) is a fraction of $\text{RootLitM}$, and the fraction is the ratio of the amount of nitrogen in root biomass ($\text{RootMassN}$) and the total root biomass ($\text{RootMass}$):

$$\text{RootLitN} = \text{RootLitM} \cdot \frac{\text{RootMassN}}{\text{RootMass}}$$

Note that $\text{RootMassN}$ and $\text{RootMass}$ are calculated in [Monthly allocation](/doc/allocation.md). But here, after moving carbon and nitrogen to root litter, we should update $\text{RootMassN}$ and $\text{RootMass}$:

$$\text{RootMass} = \text{RootMass} - \text{RootLitM}$$

$$\text{RootMassN} = \text{RootMassN} - \text{RootLitN}$$


## Wood turnover

#TODO:
Woody litter production:

$$\text{WoodLitM} = \text{WoodMass} \cdot \textcolor{cyan}{\text{WoodTurnover}}$$

This turnover carries the same fraction of N from $\text{WoodMassN}$, which means:

$$\text{WoodLitN} = \text{WoodLitM} \cdot \textcolor{cyan}{\text{WoodTurnover}}$$

Woody litter is held in a separate pool ($\text{DeadWoodM}$, $\text{DeadWoodN}$) and transferred to soil organic matter (SOM) at a rate determined by $\textcolor{cyan}{\text{WoodLitTrans}}$:

$$\text{WoodTransM} = \text{DeadWoodM} \cdot \textcolor{cyan}{\text{WoodLitTrans}}$$

$$\text{WoodTransN} = \text{DeadWoodM} \cdot \textcolor{cyan}{\text{WoodLitTrans}}$$

The $\textcolor{cyan}{\text{WoodLitCLoss}}$ specifies a ratio of CO2 production from decaying wood to residue transfer to SOM. This results in an increasing concentration of N in woody material as it decays in this pool.





