Reference: [[aber1997Modeling]].

Here are the variables involved (See [variables_table](/doc/paramters_table.md) for description):

- $\text{NDrain}$
- $\text{NDrainYr}$
- $\text{NO3}$

All available nitrate is assumed to be in the soil solution. The fraction of soil water drains in any month is multiplied by the total NO3 pool to determine the total nitrate leaching in that month.

$$\text{NDrain} = \textcolor{cyan}{\text{FracDrain}} \cdot NO3$$

$$\text{NDrainYr}^m = \Sigma_{i=1}^m \text{NDrain}^i$$

