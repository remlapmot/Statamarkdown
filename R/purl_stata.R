#' Extract Stata code from a dynamic document
#'
#' The Stata analogue of [knitr::purl()]: extracts the code from the
#' Stata code chunks of an R Markdown or Quarto document and writes it
#' to a Stata do-file.
#'
#' Chunks are recognised with knitr's own chunk patterns, so indented
#' chunks and fences of more than three backticks are handled.  A chunk
#' is extracted when its header engine is `stata`, or when it uses the
#' older `r` chunk form with an `engine = "stata"` option.  Chunks with
#' the `purl = FALSE` or `eval = FALSE` options (either in the chunk
#' header or in `#|` option comments) are skipped, and `#|` option
#' comments are not copied into the do-file.
#'
#' @param input A character string with the name of the input document.
#' @param output A character string with the name of the do-file to
#'   write.  Defaults to the name of the input document with its
#'   extension changed to `.do`.
#' @param text A character string with the document text to use in
#'   place of a file.
#' @param documentation (logical) Whether to precede the code of each
#'   chunk with a Stata comment giving the chunk's header (its label
#'   and options).
#'
#' @return If a do-file is written, the path to the do-file, invisibly.
#'   If `text` is given and `output` is `NULL`, a character vector of
#'   the extracted lines.
#'
#' @seealso [knitr::purl()], [Statamarkdown-package]
#'
#' @export
#'
#' @examples
#' indoc <- '
#' Some text.
#'
#' ```{r}
#' library(Statamarkdown)
#' ```
#'
#' ```{stata first-Stata, collectcode=TRUE}
#' sysuse auto, clear
#' generate gpm = 1/mpg
#' ```
#'
#' ```{stata second-Stata}
#' regress price gpm
#' ```
#' '
#' purl_stata(text = indoc)
purl_stata <- function(input, output = NULL, text = NULL, documentation = TRUE) {
  if (is.null(text)) {
    x <- xfun::read_utf8(input)
    if (is.null(output)) output <- xfun::with_ext(input, "do")
    if (identical(normalizePath(output, mustWork = FALSE),
                  normalizePath(input, mustWork = FALSE)))
      stop("'output' must be different from 'input'")
  } else {
    x <- xfun::split_lines(text)
  }

  pat <- knitr::all_patterns$md
  begin <- grep(pat$chunk.begin, x)
  end <- grep(pat$chunk.end, x)

  res <- character()
  pos <- 0L
  for (b in begin) {
    if (b <= pos) next # inside the previous chunk
    e <- end[end > b][1L]
    if (is.na(e)) break # unclosed chunk
    pos <- e

    # the chunk header: engine, label and options inside the braces
    header <- sub(pat$chunk.begin, "\\1", x[b])
    is_stata <- grepl("^stata([ ,].*)?$", header) ||
      # older syntax: an r chunk with the engine option set to stata
      grepl("^r[ ,].*engine\\s*=\\s*['\"]stata['\"]", header)
    if (!is_stata) next
    if (grepl("(purl|eval)\\s*=\\s*F(ALSE)?\\b", header)) next

    code <- if (e - b > 1L) x[(b + 1L):(e - 1L)] else character()
    # remove (and inspect) leading #| option comments
    opts <- character()
    while (length(code) && grepl("^\\s*#\\|", code[1L])) {
      opts <- c(opts, code[1L])
      code <- code[-1L]
    }
    if (any(grepl("(purl|eval)\\s*:\\s*false", opts))) next

    if (documentation) code <- c(paste0("* ---- ", header, " ----"), code)
    res <- c(res, code, "")
  }
  res <- res[-length(res)] # drop the trailing blank line

  if (length(res) == 0L) {
    warning("No Stata code chunks found in the document")
    return(invisible(character()))
  }

  if (is.null(output)) res else {
    xfun::write_utf8(res, output)
    invisible(output)
  }
}
