# PnET model family

PnET stands for **P**hotosy**n**thesis and **E**vapo**T**ranspiration, it's a simple lumped-parameter forest ecosystem model designed to simulate the effects of climate change, disturbance, and biogeochemical perturbations on coupled $C$, $H_2O$, and $N$ cycling.

The PnET model family consists of several models including:

- [The original PnET](https://doi.org/10.1007/BF00317837)
- [PnET-II](https://doi.org/10.1007/BF00317837)
- [PnET-Day](http://www.jstor.org/stable/4221255)
- [PnET-CN](https://linkinghub.elsevier.com/retrieve/pii/S0304380097019534)
- [PnET-Daily]() (2013)
- [PnET-SOM]() (2013-present).

In this package, we currently provide PnET-II, PnET-Day, and PnET-CN. Note that the PnET-II model is actually an improved version of the original paper ([Aber et al 1995](https://doi.org/10.1007/BF00317837)), it also incorporates some parts of the PnET-Day model ([Aber et al 1996](http://www.jstor.org/stable/4221255)).

## Model Overview

> The model equations were extracted from the MATLAB code downloaded from the [official website](https://www.pnet.sr.unh.edu/).

Notations:

> A table of all variables and descriptions can be found [here](/doc/paramters_table.md).

I sometimes use the following superscripts to specifically represent the time scale of a variable:

- $d$ is day
- $m$ is month
- $k$ is year

Colors are used to distinguish different variable types:

- $\textcolor{lime}{Observation}$
- $\textcolor{cyan}{Prescribed}$

The following are the major modules encoded in the PnET model framework:

- **[AtmEnviron](/doc/AtmEnviron.md)**: atmospheric environmental variables.
- **[Phenology](/doc/Phenology.md)**: controls growing season timing and length, mainly consists of start-of-season (SOS), start of woody growth, senescence, and end-of-season (EOS).
- **[Photosynthesis](/doc/Photosynthesis.md)**: determines carbon productivity, respiration, and leaf development.
- **[Water Balance](/doc/Water%20Balance.md)**: controls water availability and impacts of water on photosynthesis.
- **[Soil Respiration](/doc/Soil%20Respiration.md)**: carbon reparation in soil.
- **[Allocation](/doc/Allocation.md)**: allocates monthly and annual carbon gain for growth.
- **[CNTrans](/doc/CNTrans.md)**: calculates litterfall and transfers to soil organic matter.
- **[Decomp](/doc/Decomp.md)**: calculates C and N mineralization and nitrification and also matches N availability with plant N demand to determine N uptake. In the code scripts, the NUptake routine in Aber et al 1997, which combines N availability with the strength of plant demand to determine the uptake of N into the PlantN pool, is also included in this module.
- **[Leach](/doc/Leach.md)**: calculates leaching losses of nitrate.

Different models include different modules above and may adapt particular parts, except for **[AtmEnviron](/doc/AtmEnviron.md)**, which is the same across models.

### PnET-Day

PnET-Day is the simplest model in this family, it only simulates [Photosynthesis](/doc/Photosynthesis.md). So, this model only includes [AtmEnviron](/doc/AtmEnviron.md), [Phenology](/doc/Phenology.md), and [Photosynthesis](/doc/Photosynthesis.md).

### PnET-II

PnET-II includes all 6 modules sequentially ([AtmEnviron](/doc/AtmEnviron.md), [Phenology](/doc/Phenology.md), [Photosynthesis](/doc/Photosynthesis.md), [Water Balance](/doc/Water%20Balance.md), [Soil Respiration](/doc/Soil%20Respiration.md), [Allocation](/doc/Allocation.md)). 

### PnET-CN

PnET-CN builds upon PnET-II and includes nitrogen cycling. It introduces [CNTrans](/doc/CNTrans.md), [Decomp](/doc/Decomp.md), [Leach](/doc/Leach.md) modules and modifies the [Allocation](/doc/Allocation.md) module.

### PnET-Daily

PnET-Daily is a daily scale model while other models in the family are monthly scale.

### PnET-SOM
