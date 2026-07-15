# Skip a test when no Stata executable can be found (e.g. on CI machines).
# As a side effect find_stata() sets the engine.path chunk option, so
# knitting Stata chunks works in the tests that follow the skip.
skip_if_no_stata <- function() {
  stataexe <- suppressMessages(find_stata(message = FALSE))
  testthat::skip_if(!nzchar(stataexe), "Stata not available")
  invisible(stataexe)
}

# Run a test inside a fresh temporary directory, since the Stata engine
# writes its do-file, log file, and any profile.do into the working directory
local_test_dir <- function(env = parent.frame()) {
  dir <- withr::local_tempdir(.local_envir = env)
  withr::local_dir(dir, .local_envir = env)
  invisible(dir)
}
