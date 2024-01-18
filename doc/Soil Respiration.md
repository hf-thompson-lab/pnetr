# Soil Respiration

Here are the variables involved (See [variables_table](/doc/paramters_table.md) for description):

- SoilRespMo
- SoilRespYr


These variables will be calculated or updated in this component:

- Monthly soil respiration ($\text{SoilResp}^m$)

- Annual accumulated soil respiration ($\text{SoilRespYr}$)

<!-- TODO: seems mean soil moisture effect on soil respiration is controlled by potential transpiration? -->

And, the mean soil moisture effect on soil respiration ($\text{MeanSoilMoistEff}^m$) is determined by the current water amount ($\text{Water}^m$) and potential transpiration. And, during this period, potential transpiration is 0, so, we assign $\text{MeanSoilMoistEff}^m$ to 1:

$$\text{MeanSoilMoistEff}^m = 1$$

Monthly soil respiration:

$$\text{SoilResp}^m = \textcolor{cyan}{\text{SoilRespA}^{sp}} \cdot \exp(\textcolor{cyan}{\text{SoilRespB}^{sp}} \cdot \text{T}_{avg}^m) \cdot \text{MeanSoilMoistEff}^m \cdot (\text{Dayspan}^m / 30.5)$$

So, the annual soil respiration is:

$$\text{SoilRespYr} = \Sigma_{m=1}^{12} \text{SoilResp}^m$$
