# Find the frame of the outermost knitr::knit() call, so that cleanup
# can be registered (via on.exit) to run when knitting completes
knit_frame <- function() {
  for (i in seq_len(sys.nframe())) {
    if (identical(sys.function(i), knitr::knit)) return(sys.frame(i))
  }
  NULL
}

# The directory in which knitr evaluates chunk code, and therefore the
# directory in which Stata is run: the root.dir option if set (e.g. by
# RStudio's "Evaluate chunks in directory: Project" setting or
# rmarkdown::render(knit_root_dir=)), otherwise the document directory.
# Chunk hooks run in the knitting process's own working directory, which
# can differ from this (issue #17), so 'profile.do' must be addressed
# explicitly rather than with a bare relative path.
evaluation_dir <- function() {
  dir <- knitr::opts_knit$get("root.dir")
  if (is.null(dir)) {
    input <- tryCatch(knitr::current_input(dir = TRUE), error = function(e) NULL)
    if (!is.null(input)) dir <- dirname(input)
  }
  if (is.null(dir)) dir <- "."
  dir
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

  # Per-knit state: whether cleanup has been registered for the current
  # knit, so that a pre-existing 'profile.do' is snapshot exactly once
  collect <- new.env(parent = emptyenv())
  collect$active <- FALSE

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

          # Collect code where the chunks (and therefore Stata) run,
          # which is not necessarily this hook's working directory
          profile <- file.path(evaluation_dir(), "profile.do")

          if (!collect$active) {
            # First collectcode chunk of this knit: snapshot any
            # pre-existing 'profile.do' and register cleanup to run
            # when the document has finished knitting, locating the
            # knitr::knit() frame on the call stack rather than
            # assuming it sits at a fixed depth
            oprofile <- if (file.exists(profile)) readLines(profile) else NULL
            if (!is.null(oprofile)) {
              message("Found an existing 'profile.do'")
              message(paste("  ", oprofile, "\n"))
            }
            knitframe <- knit_frame()
            if (!is.null(knitframe)) {
              collect$active <- TRUE
              reset <- function() collect$active <- FALSE
              # bquote() splices in the values of profile, oprofile and
              # reset, so the cleanup expression does not depend on any
              # name being visible in the knit frame when it eventually
              # runs; writeLines() restores the original 'profile.do'
              cleanup <- if (is.null(oprofile)) {
                bquote({ unlink(.(profile)); (.(reset))() })
              } else {
                bquote({ writeLines(.(oprofile), .(profile)); (.(reset))() })
              }
              do.call("on.exit", list(cleanup, add = TRUE), envir = knitframe)
            }
          }

          autoexec <- file(profile, open="at")
          writeLines(options$code, autoexec)
          close(autoexec)
        }
    }
})
}
