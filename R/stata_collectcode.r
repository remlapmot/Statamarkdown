stata_collectcode <- function(stataexe) {
  # Message when Statamarkdown loads
  statadir <- dirname(stataexe)
  if (file.exists(file.path(statadir, "sysprofile.do"))) {
    packageStartupMessage("Found a 'sysprofile.do'")
  }
  if (file.exists(file.path(statadir, "profile.do"))) {
    packageStartupMessage("Found a 'profile.do' in the STATA executable directory.")
    packageStartupMessage("  This prevents 'collectcode' from working.")
    packageStartupMessage("  Please rename this 'sysprofile.do'.")
  }
  if (file.exists("profile.do")){
#    print(sys.frames())
#    print(sys.calls())
#    print(sys.nframe())
    assign("oprofile", readLines("profile.do"), pos=2)
#    oprofile <- readLines("profile.do")
    packageStartupMessage("Found an existing 'profile.do'")
    packageStartupMessage(paste("  ", oprofile, "\n"))
  }
  else {
    oprofile <- NULL
  }
  knitr_frame <- if (utils::packageVersion('knitr') >= '1.45') -10L else -9L

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
            packageStartupMessage("Found a 'profile.do' in the STATA executable directory.")
            packageStartupMessage("  This prevents 'collectcode' from working properly.")
            packageStartupMessage("  Please rename this 'sysprofile.do'.")
          }
            autoexec <- file("profile.do", open="at")
            writeLines(options$code, autoexec)
            close(autoexec)
# print(sys.frames())
# print(sys.calls())
          do.call("on.exit",
                  list(quote(unlink("profile.do")), add=TRUE),
                  envir = sys.frame(knitr_frame))

        if (!is.null(oprofile)) { # replace the original "profile.do"
          do.call("on.exit",
                  list(quote(writeLines(oprofile, "profile.do")), add=TRUE),
                  envir = sys.frame(knitr_frame))
# sys.frame(1) or sys.frame(-10) is rmarkdown::render()
# sys.frame(-9) is knitr::knit()
        }
        }
    }
})
}
