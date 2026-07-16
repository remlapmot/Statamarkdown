# Find the frame of the outermost knitr::knit() call, so that cleanup
# can be registered (via on.exit) to run when knitting completes
knit_frame <- function() {
  for (i in seq_len(sys.nframe())) {
    if (identical(sys.function(i), knitr::knit)) return(sys.frame(i))
  }
  NULL
}

stata_collectcode <- function(stataexe) {
  # Message when Statamarkdown loads
  statadir <- dirname(stataexe)
  if (file.exists(file.path(statadir, "sysprofile.do"))) {
    packageStartupMessage("Found a 'sysprofile.do'")
  }
  if (file.exists(file.path(statadir, "profile.do"))) {
    packageStartupMessage("Found a 'profile.do' in the Stata executable directory.")
    packageStartupMessage("  This prevents 'collectcode' from working.")
    packageStartupMessage("  Please rename this to 'sysprofile.do'.")
  }
  if (file.exists("profile.do")){
    oprofile <- readLines("profile.do")
    packageStartupMessage("Found an existing 'profile.do'")
    packageStartupMessage(paste("  ", oprofile, "\n"))
  }
  else {
    oprofile <- NULL
  }

  # Hook for code processing
  knitr::knit_hooks$set(collectcode = function(before, options, envir) {
    if (!before) {
        if (options$engine == "stata") {
          enginepath <- if (is.list(options$engine.path)) {
            options$engine.path$stata
          } else { # backwards compatibility
            options$engine.path
          }
          if (!is.null(enginepath) && file.exists(file.path(dirname(enginepath), "profile.do"))) {
            message("Found a 'profile.do' in the Stata executable directory.")
            message("  This prevents 'collectcode' from working properly.")
            message("  Please rename this to 'sysprofile.do'.")
          }
            autoexec <- file("profile.do", open="at")
            writeLines(options$code, autoexec)
            close(autoexec)
          # Register cleanup to run when the document has finished
          # knitting, locating the knitr::knit() frame on the call
          # stack rather than assuming it sits at a fixed depth
          knitframe <- knit_frame()
          if (!is.null(knitframe)) {
            do.call("on.exit",
                    list(quote(unlink("profile.do")), add=TRUE),
                    envir = knitframe)

            if (!is.null(oprofile)) { # replace the original "profile.do"
              # bquote() splices in the value of oprofile, so the cleanup
              # expression does not depend on any name being visible in
              # the knit frame when it eventually runs
              do.call("on.exit",
                      list(bquote(writeLines(.(oprofile), "profile.do")), add=TRUE),
                      envir = knitframe)
            }
          }
        }
    }
})
}
