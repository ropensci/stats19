% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/format.R
\name{format_ppp}
\alias{format_ppp}
\title{Convert STATS19 data into ppp (spatstat) format.}
\usage{
format_ppp(data, window = NULL, ...)
}
\arguments{
\item{data}{A STATS19 dataframe to be converted into ppp format.}

\item{window}{A windows of observation, an object of class \code{owin()}. If
\code{window = NULL} (i.e. the default) then the function creates an approximate
bounding box covering the whole UK. It can also be used to filter only the
events occurring in a specific region of UK (see the examples of
\code{\link{get_stats19}}).}

\item{...}{Additional parameters that should be passed to
\code{\link[spatstat.geom:ppp]{spatstat.geom::ppp()}} function. Read the help page of that function
for a detailed description of the available parameters.}
}
\value{
A ppp object.
}
\description{
This function is a wrapper around the \code{\link[spatstat.geom:ppp]{spatstat.geom::ppp()}} function and
it is used to transform STATS19 data into a ppp format.
}
\examples{
if (requireNamespace("spatstat.geom", quietly = TRUE)) {
  x_ppp = format_ppp(accidents_sample)
  x_ppp
}

}
\seealso{
\code{\link{format_sf}} for an analogous function used to convert
data into sf format and \code{\link[spatstat.geom:ppp]{spatstat.geom::ppp()}} for the original function.
}
