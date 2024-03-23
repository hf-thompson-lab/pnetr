# Soil Respiration

This routine deals with the respirations in soil. Here are the variables involved (See [variables_table](/doc/paramters_table.md) for description):

- $\text{SoilRespMo}$: Soil repiration at the current time step.
- $\text{SoilRespYr}$: Annual accumulated soil respiration.


## Soil respiration calculation

The current step soil respiration ($\text{SoilRespMo}$) is an empirical function of temperature and mean soil moisture effect ($\text{MeanSoilMoistEff}^t$), which is calculated in the [Water Balance](/doc/water_balance.md) routine. $\text{SoilRespMo}$ is calculated as:

$$\text{SoilResp} = \textcolor{cyan}{\text{SoilRespA}} \cdot \exp(\textcolor{cyan}{\text{SoilRespB}} \cdot \text{T}_{avg}) \cdot \text{MeanSoilMoistEff} \cdot (\text{Dayspan} / 30.5)$$

So, the annual soil respiration is:

$$\text{SoilRespYr} = \Sigma_{m=1}^{12} \text{SoilResp}^m$$
