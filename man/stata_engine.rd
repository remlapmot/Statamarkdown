\name{stata_engine}
\alias{stata_engine}
\title{Define a Stata engine for knitr}
\description{
This function creates a modified Stata engine.

Set up once per session (i.e. document).  Ordinarily this is run
automatically when \pkg{Statamarkdown} is loaded.
}
\usage{
stata_engine(options)
}
\arguments{
\item{options}{\code{options} are passed to the engine
function when it
is actually invoked within \pkg{knitr}.}
}

\details{
This function is used as follows.

\itemize{
\item{
\code{stata_engine(options)}
is a language engine that returns Stata log output.}

The end user should not need to use the language engine
function directly.  This is the
workhorse function that actually calls Stata and returns output.
}
}

\value{
The language engine function returns Stata code
and output internally to \pkg{knitr}.

}
\author{
Doug Hemken
}

\seealso{
\code{\link[knitr:knit_engines]{knitr:knit_engines}}
}
\examples{

indoc <- '
# An R console example
## In a first code chunk, set up with
```{r}
library(Statamarkdown)
```

## Then mark Stata code chunks with
```{stata}
sysuse auto, clear
generate gpm = 1/mpg
summarize price gpm
```
'

if (nzchar(Statamarkdown::find_stata()) &&
    requireNamespace("rmarkdown", quietly = TRUE)) {
  # To run this example, remove tempdir().
  frmd <- file.path(tempdir(), "test.Rmd")
  fhtml <- file.path(tempdir(), "test.html")

  # Knit and render in a fresh R process, so that stale knitr state in a
  # long-running session (e.g. from RStudio's "Run examples" button)
  # cannot interfere with how the document text is parsed.
  xfun::Rscript_call(
    function(indoc, frmd, fhtml) {
      writeLines(indoc, frmd)
      rmarkdown::render(frmd, "html_document", fhtml)
    },
    args = list(indoc, frmd, fhtml)
  )
  message("HTML output created at: ", fhtml)
  if (interactive()) {
    # Show in the RStudio Viewer pane if available, otherwise the browser
    viewer <- getOption("viewer", default = utils::browseURL)
    viewer(fhtml)
  }
}
}
