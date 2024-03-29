% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/format.R
\name{format_vehicles}
\alias{format_vehicles}
\title{Format STATS19 vehicles data}
\usage{
format_vehicles(x)
}
\arguments{
\item{x}{Data frame created with \code{read_vehicles()}}
}
\description{
Format STATS19 vehicles data
}
\section{Details}{

This function formats raw STATS19 data
}

\examples{
\donttest{
if(curl::has_internet()) {
dl_stats19(year = 2022, type = "vehicle", ask = FALSE)
x = read_vehicles(year = 2022, format = FALSE)
vehicles = format_vehicles(x)
}
}
}
