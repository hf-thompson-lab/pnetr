# Leach

This routine calculates leaching losses of nitrate. Here are the variables involved (See [variables_table](/doc/paramters_table.md) for description):

- $\text{NDrain}$: Nitrate leaching.
- $\text{NDrainYr}$: The annual accumulated nitrate leaching.
- $\text{NO3}$: Nitrogen deposition in NO3.

All available nitrate is assumed to be in the soil solution. The fraction of soil water drains in any month is multiplied by the total NO3 pool to determine the total nitrate leaching in that month.

$$\text{NDrain} = \textcolor{cyan}{\text{FracDrain}} \cdot NO3$$

$$\text{NDrainYr}^m = \Sigma_{t=1}^m \text{NDrain}^t$$

