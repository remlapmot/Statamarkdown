\name{spinstata}
\alias{spinstata}
\title{
Convert a specially marked up Stata "do" file to Markdown and HTML.
}
\description{
This function takes a Stata file containing special markup in
its comments, and converts it to
Markdown and HTML documents (or one of several other formats).
}
\usage{
spinstata(statafile, text=NULL, keep=FALSE, ...)
}
\arguments{
\item{statafile}{A character string with the name of a Stata
"do" file, containing markup in its comments.}
\item{text}{A character string in place of a file.}
\item{keep}{Whether to save intermediate files.}
\item{...}{options passed to \code{knitr::spin}}
}

\details{
This function takes a Stata file containing special markup in
its comments, and converts it into knitr's "spin" format.
This is in turn sent to \code{knitr::spin}, and converted to
Markdown and HTML (or one of several other formats).

Special Markup:
\itemize{
\item{\code{"/*' "} - Begin document text, ends with \code{"'*/"}}
\item{\code{"/*+ "} - Begin chunk header, ends with \code{"+*/"}}
\item{\code{"/*R "} - Begin a chunk of R code, ends with \code{"R*/"}}
\item{\code{"/** "} - Dropped from document, ends with
\code{"*/*"}}
}

}
\value{
The path to the output file.

If given text instead of a file, returns the compiled document as a
character string.
}
\author{
Doug Hemken
}
\seealso{
\code{\link{Statamarkdown-package}}
}
\examples{
indoc <- "/*'
# Statamarkdown Example

This is a special Stata script which can be used to generate a report.
You can write normal text in command-style comments.

First we load Statamarkdown.
'*/

  /*+  setup +*/
  /*R
library(Statamarkdown)
R*/

  /*' The report begins here. '*/

  /*+  example1, engine='stata' +*/
  sysuse auto
/* Stata comment */
  summarize

/*' You can use the ***usual*** Markdown to mark up text.'*/
"
if (nzchar(Statamarkdown::find_stata())) {
  # To run this example, remove tempdir().
  fhtml <- file.path(tempdir(), "test.html")
  # Spin in a fresh R process, so that stale knitr state in a
  # long-running session (e.g. from RStudio's "Run examples" button)
  # cannot interfere with how the document text is parsed.
  x <- xfun::Rscript_call(
    function(indoc) Statamarkdown::spinstata(text = indoc),
    args = list(indoc)
  )
  writeLines(x, fhtml)
  message("HTML output created at: ", fhtml)
  if (interactive()) {
    # Show in the RStudio Viewer pane if available, otherwise the browser
    viewer <- getOption("viewer", default = utils::browseURL)
    viewer(fhtml)
  }
}

}
