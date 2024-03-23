# Phenology

Phenology controls the variation of variables in the carbon cycle, it divides the whole year into 4 different stages:

- **winter - early spring**: during which no photosynthesis since there are no leaves, but maintenance respiration exists.
- **spring - summer**: during which leaves start to develop so do photosynthesis and growth respiration.
- **summer - autumn**: during which leaves start to senesce and fall off.
- **autumn - winter**: during which no photosynthesis b/c the growing season ends.
 
Here are the variables involved (See [variables_table](/doc/paramters_table.md) for description):

- $\text{GDDFolEff}$: The growing degree day effect on foliar development.
- $\text{FolMass}$: Foliar biomass.
- $\text{FolProdCMo}$: Foliar carbon produced at this time step.
- $\text{FolGRespMo}$: Foliar growth respiration at this time step.
- $\text{LAI}$: Leaf area index.
- $\text{FolLitM}$: Foliar litter biomass.


## Winter - early spring (before SOS)

This period is under the condition $\text{GDDTot}^t < \textcolor{cyan}{\text{GDDFolStart}}$. During this period no leaves are present, thus no photosynthesis is included in the process. Therefore, the following variables are 0:

- $\text{GDDFolEff} = 0$
- $\text{FolProdCMo} = 0$
- $\text{FolGRespMo} = 0$
- $\text{FolLitM} = 0$

And, foliar biomass and LAI are just the same as the last time step:

- $\text{FolMass}^t = \text{FolMass}^{t-1}$
- $\text{LAI}^t = \text{LAI}^{t-1}$


## Spring - summer (SOS - Senesce)

This period is under the condition $\text{GDDTot}^t \ge \textcolor{cyan}{\text{GDDFolStart}}$ and $\text{DOY}^t < \textcolor{cyan}{\text{SenescStart}}$. During this period, leaves are produced, and photosynthesis has started.

We calculate a GDD foliage effect by a linear function:

$$\text{GDDFolEff}^t = \frac{\text{GDDTot}^t - \textcolor{cyan}{\text{GDDFolStart}}}{\textcolor{cyan}{\text{GDDFolEnd} - \textcolor{cyan}{\text{GDDFolStart}}}}$$
Note that $\text{GDDFolEff} \in [0, 1]$. 

Then, a $\Delta \text{GDDFolEff}$ ($\text{delGDDFolEff}$) can be calculated with: 
$$\text{delGDDFolEff}^t = \text{GDDFolEff}^t - \text{GDDFolEff}^{t-1}$$

Using this $\Delta \text{GDDFolEff}$ we can get current amount of foliar growth at this time step:

$$\text{FolMass}^t = \text{FolMass}^{t-1} + \text{BudC} \cdot \text{delGDDFolEff}^t / \textcolor{cyan}{\text{CFracBiomass}}$$

where $\textcolor{cyan}{\text{CFracBiomass}}$ is the carbon fraction of the foliar biomass. 

So, the current time step's foliar carbon production and respiration would be:

$$\text{FolProdCMo}^t = (\text{FolMass}^t - \text{FolMass}^{t-1}) \cdot \textcolor{cyan}{\text{CFracBiomass}}$$

$$\text{FolGRespMo}^t = \text{FolProdCMo}^t \cdot \textcolor{cyan}{\text{GRespFrac}}$$

where $\textcolor{cyan}{\text{GRespFrac}}$ is growth respiration as a fraction of allocation.


## Summer - autumn (Senesce - EOS)

This period is under the condition $\text{GDDTot}^t \ge \textcolor{cyan}{\text{GDDFolStart}}$ and $\text{DOY}^t \ge \textcolor{cyan}{\text{SenescStart}}$ and $\text{GDDTot}^t < \textcolor{cyan}{\text{GDDFolEnd}}$. During this period, leaves are falling.

The new foliar biomass is:
$$\text{FolMassNew}^t = \max(\text{PosCBalMass}, \text{FolMassMin})$$
where $\text{PosCBalMass}$ is calculated in the [Photosynthesis module](/doc/Photosynthesis.md), and $\text{FolMassMin}$ is the minimum foliar biomass of the tree species during the year (e.g., $\text{FolMassMin} = 0$ for deciduous trees). 

<!-- # HACK: LAI is not calculated in the spring? -->
Then, leaf area index at this time step ($\text{LAI}^t$) can be calculated as:
$$\text{LAI}^t = \text{LAI}^{t-1} \cdot \frac{\text{FolMassNew}^t}{\text{FolMass}^{t-1}} \ (0 \le \text{FolMassNew}^t \le \text{FolMass}^{t-1})$$
<!-- \\$$\text{LAI}^t = \begin{cases} -->
<!-- \text{LAI}^{t-1} \cdot \text{FolMassNew}^t / \text{FolMass}^t & 0 < \text{FolMassNew}^t < \text{FolMass}^t \\
	0 & \text{FolMassNew}^t = 0
\end{cases}$$ -->

If $\text{FolMassNew}^t < \text{FolMass}^{t-1}$, it means leaf litter was produced:
$$\text{FolLitM}^t = \text{FolMass}^{t-1} - \text{FolMassNew}^t$$

At last, we update $\text{FolMass}^t = \text{FolMassNew}^t$.

## Autumn - winter (after EOS)

This period is under the condition $\text{GDDTot}^t \ge \textcolor{cyan}{\text{GDDFolEnd}}$. During this period the growing season has ended thus no photosynthesis and the following variables are 0:

- $\text{GDDFolEff} = 0$
- $\text{FolProdCMo} = 0$
- $\text{FolGRespMo} = 0$
- $\text{FolLitM} = 0$

And, foliar biomass and LAI are just the same as the last time step:

- $\text{FolMass}^t = \text{FolMass}^{t-1}$
- $\text{LAI}^t = \text{LAI}^{t-1}$


