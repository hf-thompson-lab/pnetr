# AtmEnviron

Here are the variable involved (See [variables_table](/doc/paramters_table.md) for description):

- Tavg
- Tday
- Tnight
- VPD
- Tmin
- Month
- Dayspan
- Daylenhr
- Daylen
- Nightlen
- GDD
- GDDTot

This module uses site latitude ($\text{Lat}$), day-of-year ($\text{DOY}$), monthly max & min temperature ($T_{max}$, $T_{min}$), and radiation ($\text{PAR}$ or $I_o$) to calculate day length ($\text{DayLength}$), monthly average temperature ($T_{avg}$), daytime ($T_{day}$) & nighttime temperature ($T_{night}$), and vapor pressure deficit ($\text{VPD}$).

$$
\text{DayLength} = f(\textcolor{lime}{Lat}, \textcolor{lime}{\text{DOY}})
$$
$$
T_{avg} = (\textcolor{lime}{T_{max}}+\textcolor{lime}{T_{min}})/2
$$
$$
T_{day} = (T_{avg}+\textcolor{lime}{T_{max}})/2
$$
$$
T_{night} = (T_{avg} + \textcolor{lime}{T_{min}})/2
$$
$$
\text{VPD} = f(T_{day}, \textcolor{lime}{T_{min}})
$$
$$
\textcolor{lime}{I_o}
$$

The calculated monthly mean temperatures are then used to calculate current and accumulated growing degree days ($\text{GDD}$, $\text{GDD}_{\text{total}}$) using 0 °C as the base temperature and Jan 1st as the start counting date.

$$
\text{GDD} = \max(T_{avg}, 0) \cdot \text{Dayspan}
$$
$$
\text{GDD}_{\text{total}} = \Sigma_{i=1}^{i=m} \text{GDD}_i
$$

where $\text{Dayspan}$ is simply the number of days in the month.