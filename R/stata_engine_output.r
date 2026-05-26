stata_engine_output <- function(x, options) {
    if (!is.null(options$noisy) && options$noisy==TRUE) { # debugging option
      message(paste("\n", options$engine, "output from chunk", options$label))
      message("input to stata_engine_output()")
      message(x)
    }

  if (options$engine=="stata" && (length(options$eval) > 1 || options$eval!=FALSE)) {
      # Remove "running profile ..." (including sysprofile)
      #  Done as a single string because a deep folder path can create awkward line breaks
      #  within the word "profile"
      if (length(x) != 1) x = single_string(x)
      noprofile <- sub("^.*[R|r]unning[[:space:]].*p(\\\n>[[:space:]])?r(\\\n>[[:space:]])?o(\\\n>[[:space:]])?f(\\\n>[[:space:]])?i(\\\n>[[:space:]])?l(\\\n>[[:space:]])?e(\\\n>[[:space:]])?\\.(\\\n>[[:space:]])?d(\\\n>[[:space:]])?o(\\\n>[[:space:]])?[[:space:]](\\\n>[[:space:]])?\\.(\\\n>[[:space:]])?\\.(\\\n>[[:space:]])?\\.[[:space:]]?[[:space:]]?", "", x)
      x <- unlist(strsplit(noprofile, "\n"))
      # remove "end of do-file"
      endofdofile <- grep("end of do-file", x)
      x <- x[-endofdofile]
      y <- x

      # Remove command echo in Stata log
      if ((is.null(options$cleanlog) || length(options$cleanlog)==0) || options$cleanlog==TRUE) {

        # Find command lines
        commandlines <- grep("^[[:space:]]?\\.[[:space:]]", y)
        # Loop commands appear on more than one line, with line numbers
        if (length(commandlines)>0) {
          loopcommands <- grep("^[[:space:]]+[[:digit:]]+\\.", y)
        }
        if (length(commandlines)>0 && length(loopcommands)>0) {
          commandlines <- c(commandlines, loopcommands[(loopcommands - 1L) %in% commandlines])
        }
        # Long command lines are wrapped, with an initial ">"
        if (length(commandlines)>0) {
          continuations <- grep("^>[[:space:]]", y)
        }
        if (length(commandlines)>0 && length(continuations)>0) {
          commandlines <- c(commandlines, continuations[(continuations - 1L) %in% commandlines])
        }
        # remove
        if (length(commandlines)>0) {y <- y[-(commandlines)]}

        # Some command lines have a leading space?
        if (length(grep("^[[:space:]*]\\.", y))>0) {
          y <- y[-(grep("^[[:space:]*]\\.", y))]
        }
      }

      # Ensure a trailing blank line for the document
      if (length(y)>0 && y[length(y)] != "") { y <- c(y, "") }

      # Remove blank lines at the top of any Stata log
      alnum_lines <- grep("[[:alnum:]]", y)
      firsttext <- if (length(alnum_lines) > 0) min(alnum_lines) else Inf
      if (firsttext != Inf && firsttext != 1) {
        y <- y[-(1:(firsttext-1))]
        }
    } else { # if it's not Stata ...
      y <- x
    }
    if (!is.null(options$noisy) && options$noisy==TRUE) {
      message("output from stata_engine_output()")
      message(single_string(y))
    }
# Now return the result as a single character value
    single_string(y)
}
