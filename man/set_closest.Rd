% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/k_medoids.R
\name{set_closest}
\alias{set_closest}
\title{set closest medoid}
\usage{
set_closest(data, medoids)
}
\arguments{
\item{data}{matrix; columns are vectors}

\item{medoids}{vector; datapoints that are set as medoids}
}
\value{
input data with attribute "cluster" assigning a cluster to every column-vector and "mindissims" assigning the dissimilarity to the medoid
}
\description{
assigns each vector to the closest medoid
}
\examples{
data <- matrix(c(1,1.1,1,1,2,2,2,2.1), ncol=4)
medoids <- round(runif(3, 1, ncol(data)))
set_closest(data, medoids)
}
