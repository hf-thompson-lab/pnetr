% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/hlp_decomp.R
\name{Decomp}
\alias{Decomp}
\title{The Decomp module in PnET-CN}
\usage{
Decomp(climate_dt, sitepar, vegpar, share, rstep)
}
\arguments{
\item{climate_dt}{A table that contains monthly climate data.}

\item{sitepar}{A table that contains site-specific variables.}

\item{vegpar}{A table that contains vegetation-specific variables.}

\item{share}{The shared object containing intermittent variables.}

\item{rstep}{current time step}
}
\description{
The following variables are calculated/updated:
\itemize{
\item NO3
\item NH4
\item NdepTot
\item GrossNMinYr
\item SoilDecResp
\item SoilDecRespYr
\item NetCBal
\item GrossNImmobYr
\item HON
\item HOM
\item PlantN
\item PlantNUptakeYr
\item NetNMinYr
\item NetNitrYr
}
}
