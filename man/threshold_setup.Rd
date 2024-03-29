% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/thresholdr.r
\name{threshold_setup}
\alias{threshold_setup}
\title{Set up thresholdr}
\usage{
threshold_setup(pkg_check = TRUE, ...)
}
\arguments{
\item{pkg_check}{logical, check that ThresholdStability.jl is
installed, and install if necessary.}

\item{...}{arguments passed down to JuliaCall::julia_setup}
}
\description{
This function initializes Julia and ThresholdStability.jl,
installing them if necessary and creating wrappers for the
functions in ThresholdStability.jl.
}
\examples{
\dontrun{
thresholdr::threshold_setup()
}

}
