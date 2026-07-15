test_that("find_stata() locates a Stata executable", {
  skip_on_cran()
  stataexe <- suppressMessages(find_stata(message = FALSE))
  skip_if(!nzchar(stataexe), "Stata not available")

  expect_true(file.exists(stataexe))
  # the found executable is registered as the knitr engine path
  expect_identical(knitr::opts_chunk$get("engine.path")$stata, stataexe)
})
