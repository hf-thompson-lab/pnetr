# Decomp

Reference: [[aber1997Modeling]].

Here are the variables involved (See [variables_table](/doc/paramters_table.md) for description):

- $\text{NO3}$
- $\text{NH4}$
- $\text{NdepTot}$
- $\text{tEffSoil}$
- $\text{TMult}$
- $\text{WMult}$
- $\text{HOM}$
- $\text{HON}$
- $\text{KhoAct}$
- $\text{DHO}$
- $\text{GrossNMin}$
- $\text{SoilDecResp}$
- $\text{SoilDecRespYr}$
- $\text{GrossNMinYr}$
- $\text{NetCBal}$
- $\text{SoilPctN}$
- $\text{NReten}$
- $\text{GrossNImmob}$
- $\text{GrossNImmobYr}$
- $\text{NetNMin}$
- $\text{NetNMinYr}$
- $\text{NetNitr}$
- $\text{NetNitrYr}$
- $\text{RootNSinkStr}$
- $\text{PlantNUptake}$
- $\text{PlantNUptakeYr}$
- $\text{PlantN}$
- $\text{NH4Up}$
- $\text{NO3Up}$

This module determines the mineralization of C and N, net nitrification, plant uptake demand, and total plant N uptake. 
## Atmospheric N deposition

The current month's atmospheric N deposition is added from the climate data:

$$\text{NO3}^m = \text{NO3}^{m-1} + \text{NO3dep}^m $$

$$\text{NH4}^m = \text{NH4}^{m-1} + \text{NH4dep}^m$$

$$\text{NdepTot}^m = \text{NdepTot}^{m-1} + \text{NO3dep}^m + \text{NH4}^m$$

## Temperature effect on soil processes

$\text{TMult}$ is a temperature scalar resulting from an empirical fit to seasonal decomposition data from several temperate forest sites. $\text{Ksom}$ determines the annual average turnover rate for the soil organic matter pool.

$$\text{TMult} = 0.68 \cdot \exp(0.1 \cdot (T_{avg} - 7.1))$$

Carbon release from soil organic matter (SOM) is

$$\text{DSOM} = \text{SOM} \cdot (1 - \exp(-\text{Ksom} \cdot \text{TMult}))$$

Gross N mineralization ($\text{GrossNMin}$) is assumed to be equal to DSOM times the concentration of N in SOM:

$$\text{GrossNMin} = \text{DSOM} \cdot N$$

A N re-immobilization process is described by:

$$\text{NReten} = (\textcolor{cyan}{\text{NImmobA}} + \textcolor{cyan}{\text{NImmobB}} \cdot \text{SoilPctN}) / 100$$

where $\text{NReten}$ is the fraction of mineralized N which is re-immobilized. $\text{SoilPctN}$ is the percentage of N in soil organic matter. The values of $\textcolor{cyan}{\text{NImmobA}}$ and $\textcolor{cyan}{\text{NImmobB}}$ were selected to allow complete re-immobilization of all mineralized N at 1.5% in SOM and decrease to zero re-immobilization at 4.3%.

Gross N immobilization is calculated as:

$$\text{GrossNImmob} = \text{GrossNMin} \cdot \text{NReten}$$

And, net N mineralization is gross N mineralization minus gross N immobilization: 

$$\text{NetNMin} = \text{GrossNMin} - \text{GrossNImmob}$$

Nitrification is controlled by competition between nitrifiers and plants for NH4. The effect of high soil pH on nitrification is ignored. The fraction of NH4 nitrified in any one month is calculated by:

$$\text{NRatioNit} = ((\text{NRatio} - 1) / \text{FolNConRange})^2$$


## N uptake

A root sink strength for N ($\text{RootNSinkEff}$) describes that when the internal N pool increases, plant demand for N and actual N uptake decrease.

$$\text{RootNSinkEff} = \sqrt{1 - \text{PlantN} / \text{MaxNStore}}$$

Actual total plant N uptake each month is:

$$\text{PlantNUptake} = (NH4 + NO3) \cdot \text{RootNSinkEff}$$

The $\text{PlantNUptake}$ cannot exceed the $\text{MaxNStore}$ allowed in a plant and cannot be negative.



