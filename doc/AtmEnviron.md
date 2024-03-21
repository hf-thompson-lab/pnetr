# AtmEnviron

This routine uses site attributes and meteorological data to calculate model required environmental variables. Here are the variable involved (See [variables_table](/doc/paramters_table.md) for description):

- $\text{T}_{avg}$: Average temperature.
- $\text{T}_{day}$: Daytime temperature.
- $\text{T}_{night}$: Nighttime temperature.
- $\text{T}_{min}$: Minimum teperature.
- $\text{VPD}$: Vepor pressure deficit.
- $\text{Month}$: Month index.
- $\text{Dayspan}$: Number of days between two time steps.
- $\text{Daylenhr}$: Day length in hours.
- $\text{Daylen}$: Day length in seconds.
- $\text{Nightlen}$: Night length in seconds.
- $\text{GDD}$: Growing degree day.
- $\text{GDDTot}$: Annual accumulated GDD.

This rountine uses site latitude ($\text{Lat}$), day-of-year ($\text{DOY}$), max & min temperatures ($\text{T}_{max}$, $\text{T}_{min}$), and radiation ($\text{PAR}$ or $I_o$) to calculate day length in seconds ($\text{DayLength}$), average temperature ($\text{T}_{avg}$), daytime ($\text{T}_{day}$) & nighttime temperature ($\text{T}_{night}$), and vapor pressure deficit ($\text{VPD}$). The calculation equations are:

$$\text{DayLength} = f(\textcolor{lime}{Lat}, \textcolor{lime}{\text{DOY}})$$

$$T_{avg} = (\textcolor{lime}{T_{max}}+\textcolor{lime}{T_{min}})/2$$

$$T_{day} = (T_{avg}+\textcolor{lime}{T_{max}})/2$$

$$T_{night} = (T_{avg} + \textcolor{lime}{T_{min}})/2$$

$$\text{VPD} = f(T_{day}, \textcolor{lime}{T_{min}})$$

$$\textcolor{lime}{\text{PAR}} = \textcolor{lime}{I_o}$$

The calculated monthly mean temperatures are then used to calculate current and accumulated growing degree days ($\text{GDD}$, $\text{GDDTot}$) using 0 °C as the base temperature and Jan 1st as the start counting date.

$$\text{GDD} = \max(\text{T}_{avg}, 0) \cdot \text{Dayspan}$$

$$\text{GDDTot} = \Sigma_{i=1}^{i=t} \text{GDD}_i$$

where $\text{Dayspan}$ is simply the number of days between two time steps (e.g., monthly, daily).