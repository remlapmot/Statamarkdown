#' Define a Stata engine for knitr
#'
#' This function creates a modified Stata engine.
#'
#' Set up once per session (i.e. document).  Ordinarily this is run
#' automatically when \pkg{Statamarkdown} is loaded.
#'
#' `stata_engine(options)` is a language engine that returns Stata
#' log output.  The end user should not need to use the language
#' engine function directly.  This is the workhorse function that
#' actually calls Stata and returns output.
#'
#' @param options Chunk options, passed to the engine function
#'   when it is actually invoked within \pkg{knitr}.
#'
#' @return The language engine function returns Stata code
#'   and output internally to \pkg{knitr}.
#'
#' @author Doug Hemken
#'
#' @seealso [knitr::knit_engines]
#'
#' @export
#'
#' @examples
#' indoc <- '
#' # An R console example
#' ## In a first code chunk, set up with
#' ```{r}
#' library(Statamarkdown)
#' ```
#'
#' ## Then mark Stata code chunks with
#' ```{stata}
#' sysuse auto, clear
#' generate gpm = 1/mpg
#' summarize price gpm
#' ```
#' '
#'
#' if (nzchar(Statamarkdown::find_stata()) &&
#'     requireNamespace("rmarkdown", quietly = TRUE)) {
#'   # To run this example, remove tempdir().
#'   frmd <- file.path(tempdir(), "test.Rmd")
#'   fhtml <- file.path(tempdir(), "test.html")
#'
#'   # Knit and render in a fresh R process, so that stale knitr state in a
#'   # long-running session (e.g. from RStudio's "Run examples" button)
#'   # cannot interfere with how the document text is parsed.
#'   xfun::Rscript_call(
#'     function(indoc, frmd, fhtml) {
#'       writeLines(indoc, frmd)
#'       rmarkdown::render(frmd, "html_document", fhtml)
#'     },
#'     args = list(indoc, frmd, fhtml)
#'   )
#'   message("HTML output created at: ", fhtml)
#'   if (interactive()) {
#'     # Show in the RStudio Viewer pane if available, otherwise the browser
#'     viewer <- getOption("viewer", default = utils::browseURL)
#'     viewer(fhtml)
#'   }
#' }
stata_engine <- function (options)
{
  code <- {
    if (is.null(options$savedo) || options$savedo==FALSE) {
      f <- basename(tempfile(pattern="stata", tmpdir=".", fileext=".do"))
      on.exit(unlink(f), add = TRUE)
    } else {
      f <- basename(paste0(options$label, ".do"))
    }
    if (is.numeric(options$eval)) {
      if (all(options$eval < 0)) {
        pre <- rep("", length(options$code))
        pre[abs(options$eval)] <- "* "
      } else if (all(options$eval > 0)) {
        pre <- rep("* ", length(options$code))
        pre[abs(options$eval)] <- ""
      } else {
        message("eval option must be all negative or positive")
        pre <- rep("", length(options$code))
      }
      options$code <- paste0(pre, options$code)
    }
    writeLines(options$code, f)


    logf = sub("[.]do$", ".log", f)
    if (is.null(options$savedo) || options$savedo==FALSE)
      on.exit(unlink(logf), add = TRUE)
    sysname <- Sys.info()[["sysname"]]
    paste(switch(sysname,
                 Windows = "/q /e do",
                 Darwin = "-q -e do",
                 Linux = "-q -b do",
                 "-q -b do"),
          switch(sysname,
                 Windows = shQuote(normalizePath(f)),
                 Darwin = paste0("\'\"", normalizePath(f), "\"\'"),
                 Linux  = paste0("\'\"", normalizePath(f), "\"\'"),
                 shQuote(normalizePath(f))))
  }

  if (is.list(options$engine.opts)) {
    code = paste(options$engine.opts[[options$engine]], code, options$doargs)
  } else { # backwards compatibility
    code = paste(options$engine.opts, code, options$doargs)
  }

  cmd = if (is.list(options$engine.path)) {
    options$engine.path[[options$engine]]
  } else { # backwards compatibility
    options$engine.path
  }

  out = if (!all(options$eval==FALSE)) {
    if (!is.null(options$noisy) && options$noisy==TRUE) message("running: ", cmd, " ", code)
    tryCatch(system2(cmd, code, stdout = TRUE, stderr = TRUE,
                     env = options$engine.env), error = function(e) {
                       if (!options$error)
                         stop(e)
                       paste("Error in running command", cmd)
                     })
  }
  else ""
  if (!options$error && !is.null(attr(out, "status")))
    stop(paste(out, collapse = "\n"))
  if (!all(options$eval==FALSE) && options$engine == "stata" && file.exists(logf))
    out = c(readLines(logf), out)
  engine_output(options, options$code, out)
}
