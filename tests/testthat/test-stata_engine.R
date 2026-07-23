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

test_that("the engine falls back to the session cache when engine.path is unset", {
  skip_on_cran()
  skip_if_no_stata()
  local_test_dir()

  # simulate the state after a previous knit in the same session:
  # knitr has restored the chunk options, wiping engine.path
  old <- knitr::opts_chunk$get("engine.path")
  withr::defer(knitr::opts_chunk$set(engine.path = old))
  knitr::opts_chunk$delete("engine.path")

  md <- knitr::knit(text = "```{stata}\ndisplay 40 + 2\n```", quiet = TRUE)
  expect_match(md, "42", fixed = TRUE)
})
