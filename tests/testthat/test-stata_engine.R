test_that("a Stata chunk knits and returns its output, respecting cleanlog", {
  skip_on_cran()
  skip_if_no_stata()
  local_test_dir()

  doc <- c("```{stata}", "display 6*7", "```")
  out <- knitr::knit(text = doc, quiet = TRUE)

  expect_match(out, "42")
  # with the default cleanlog=TRUE the command echo is removed from the log
  expect_no_match(out, "[.] display")

  doc_echo <- c("```{stata, cleanlog=FALSE}", "display 6*7", "```")
  out_echo <- knitr::knit(text = doc_echo, quiet = TRUE)

  expect_match(out_echo, "42")
  expect_match(out_echo, "[.] display")
})
