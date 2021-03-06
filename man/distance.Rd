% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/h_clustering.R
\name{distance}
\alias{distance}
\title{Hierarchical Clustering Implementation}
\usage{
distance(x)
}
\arguments{
\item{x}{matrix; columns are vectors}
}
\value{
vector of all dissimilarities
}
\description{
calculates all dissimilarities from a data point
}
\details{
Distance function to compute a full Euclidean distance matrix for
the input matrix x to measure the dissimilarities. The output\code{[i,j]} gives
the Euclidean distance between rows \code{x[i,]} and \code{x[j,]}.
dissimilarity.
}
\examples{
data <- matrix(c(1,1.1,1,1,2,2,2,2.1), ncol=4)
distance(data)
}
