# CNTrans

Here are the variables involved (See [variables_table](/doc/paramters_table.md) for description).

- $\text{HOM}$
- $\text{HON}$
- $\text{RootMass}$
- $\text{RootMassN}$
- $\text{WoodMass}$
- $\text{WoodMassN}$
- $\text{WoodDecResp}$
- $\text{WoodDecRespYr}$
- $\text{DeadWoodM}$
- $\text{DeadWoodN}$
- $\text{NetCBal}$
- $\text{PlantN}$
- $\text{FolLitM}$
- $\text{FolMass}$
- $\text{PlantC}$
- $\text{TotalLitterM}$
- $\text{TotalLitterMYr}$
- $\text{TotalLitterN}$
- $\text{TotalLitterNYr}$

## Wood turnover

Woody litter production:

$$\text{WoodLitM} = \text{WoodMass} \cdot \textcolor{cyan}{\text{WoodTurnover}}$$

This turnover carries the same fraction of N from $\text{WoodMassN}$, which means:

$$\text{WoodLitN} = \text{WoodLitM} \cdot \textcolor{cyan}{\text{WoodTurnover}}$$

Woody litter is held in a separate pool ($\text{DeadWoodM}$, $\text{DeadWoodN}$) and transferred to soil organic matter (SOM) at a rate determined by $\textcolor{cyan}{\text{WoodLitTrans}}$:

$$\text{WoodTransM} = \text{DeadWoodM} \cdot \textcolor{cyan}{\text{WoodLitTrans}}$$

$$\text{WoodTransN} = \text{DeadWoodM} \cdot \textcolor{cyan}{\text{WoodLitTrans}}$$

The $\textcolor{cyan}{\text{WoodLitCLoss}}$ specifies a ratio of CO2 production from decaying wood to residue transfer to SOM. This results in an increasing concentration of N in woody material as it decays in this pool.

## Root turnover

The fine root turnover rate is determined by:

$$\text{RootTurnover} = \textcolor{cyan}{\text{RootTurnoverA}} + \textcolor{cyan}{\text{RootTurnoverB}} \cdot \text{NMin} + \textcolor{cyan}{\text{RootTurnoverC}} \cdot \text{NMin}^2$$

There is a bound restricting the values of root turnover to be $[0.1, 2.5]$. Then, the monthly root turnover is calculated as:

$$\text{RootTurnover}^m = \text{RootTurnover} \cdot \text{Dayspan}^m / 365$$

The root litter mass and N are fractions of the current root mass and N:

$$\text{RootLitM} = \text{RootMass} \cdot \text{RootTurnover}$$

$$\text{RootLitN} = \text{RootLitM} \cdot \frac{\text{RootMassN}}{\text{RootMass}}$$



