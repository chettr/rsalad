% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/tolowerfirst.R
\name{tolowerfirst}
\alias{tolowerfirst}
\title{Convert first character to lower case}
\usage{
tolowerfirst(x)
}
\arguments{
\item{x}{A character vector}
}
\value{
The original character vector with the first character of every
  element converted to lower case
}
\description{
Given a character vector, convert the first character to lower case.
}
\examples{
tolowerfirst("CamelCase")
tolowerfirst("ALLCAPS")
tolowerfirst(c("First", "_Second"))
}

