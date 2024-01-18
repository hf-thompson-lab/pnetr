# Phenology

Here are the variables involved (See [variables_table](/doc/paramters_table.md) for description):

- GDDFolEff
- FolMass
- FolProdCMo
- FolGRespMo
- PosCBalMass
- LAI
- FolLitM

Phenology controls the variation of variables in the carbon cycle, it divides the whole year into 4 different stages:

- winter - early spring: during which no photosynthesis since there are no leaves, but maintenance respiration exists.
- spring - summer: during which leaves start to develop do does photosynthesis and growth respiration.
- summer - autumn: during which leaves start to senesce and fall off.
- autumn - winter: during which no photosynthesis b/c the growing season ends.

## Winter - early spring (before SOS)

This period is under the condition $\text{GDD}_{\text{total}}^m < \textcolor{cyan}{\text{GDDFolStart}}$. During this period no leaves are present, thus no photosynthesis is included in the process. Therefore, the following variables are 0:

- $\text{GDDFolEff}^m = 0$
- $\text{FolMass}_\text{grow}^m = 0$
- $\text{FolProdC}^m = 0$
- $\text{FolGResp}^m = 0$
- $\text{FolMass}^m = \text{FolMass}^{m-1}$
- $\text{LAI}^m = \text{LAI}^{m-1}$
- $\text{FolLitM}^m = 0$

## Spring - summer (SOS - Senesce)

This period is under the condition $\text{GDD}_{\text{total}}^m \ge \textcolor{cyan}{\text{GDDFolStart}}$ and $\text{DOY}^m < \textcolor{cyan}{\text{SenescStart}}$. During this period, leaves are produced, and photosynthesis has started.

We calculate a GDD foliage effect by
$$
\text{GDDFolEff}^m = \frac{\text{GDD}_{\text{total}}^m - \textcolor{cyan}{\text{GDDFolStart}}}{\textcolor{cyan}{\text{GDDFolEnd} - \textcolor{cyan}{\text{GDDFolStart}}}} - \text{GDDFolEff}^{m-1}
$$

Then, we use the GDD foliage effect to estimate a foliage biomass production for the month:
$$\text{FolMass}_\text{grow}^m = \text{BudC} \cdot \text{GDDFolEff}^m / \textcolor{cyan}{\text{CFracBiomass}}$$
where $\textcolor{cyan}{\text{CFracBiomass}^{sp}}$ is the carbon fraction of foliage mass. And, the current month's total foliar mass would be:
$$\text{FolMass}^m = \text{FolMass}^{m-1} + \text{FolMass}_\text{grow}^m$$
And, the current month's foliar carbon production and respiration would be:
$$\text{FolProdC}^m = \text{FolMass}_\text{grow}^m \cdot \textcolor{cyan}{\text{CFracBiomass}}$$
$$\text{FolGResp}^m = \text{FolProdC}^m \cdot \textcolor{cyan}{\text{GRespFrac}}$$
where $\textcolor{cyan}{\text{GRespFrac}}$ is growth respiration as a fraction of allocation.

## Summer - autumn (Senesce - EOS)

This period is under the condition $\text{GDD}_{\text{total}}^m \ge \textcolor{cyan}{\text{GDDFolStart}}$ and $\text{DOY}^m \ge \textcolor{cyan}{\text{SenescStart}}$ and $\text{GDD}_{\text{total}}^m < \textcolor{cyan}{\text{GDDFolEnd}}$. During this period, leaves are falling.
$$\text{FolMassNew}^m = \max(\text{PosCBalMass}, \text{FolMassMin})$$
Then, $\text{LAI}^m$ can be calculated as:
$$\text{LAI}^m = \begin{cases}
	\text{LAI}^{m-1} \cdot \text{FolMassNew}^m / \text{FolMass}^m & 0 < \text{FolMassNew}^m < \text{FolMass}^m \\
	0 & \text{FolMassNew}^m = 0
\end{cases}$$
Then, we can update $\text{FolMass}^m = \text{FolMassNew}^m$.

## Autumn - winter (after EOS)

This period is under the condition $\text{GDD}_{\text{total}}^m \ge \textcolor{cyan}{\text{GDDFolEnd}}$. During this period the growing season has ended thus no photosynthesis and the following variables are 0:

- $\text{GDDFolEff}^m = 0$
- $\text{FolMass}_\text{grow}^m = 0$
- $\text{FolProdC}^m = 0$
- $\text{FolGResp}^m = 0$
- $\text{FolMass}^m = \text{FolMass}^{m-1}$
- $\text{LAI}^m = \text{LAI}^{m-1}$


