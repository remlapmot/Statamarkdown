\docType{package}
\name{Statamarkdown-package}
\alias{Statamarkdown-package}
\alias{Statamarkdown}

\title{Settings and functions to extend the knitr Stata engine.}

\description{
Using the "Stata" language engine in \code{knitr} has a number of limitations.
Each Stata code chunk is run as a separate batch file, and source
code is part of the output returned to the document being knit.

A function here sets up a chunk hook, that silently repeats selected
code chunks
at the beginning of later code chunks.  This allows
the code in one chunk to use the results of a previous chunk.  See
\code{\link{stata_collectcode}}.

A second function here sets up an output hook.  This removes Stata
code from the output by default.  To leave Stata commands in the
output, specify the chunk option \code{cleanlog=FALSE}.
}

\references{
More documentation and examples:
\url{https://www.ssc.wisc.edu/~hemken/Stataworkshops/stata.html#stata-and-r-markdown}
}
\seealso{
The package that this extends: \code{\link{knitr-package}}.
}
\author{
Doug Hemken
}
