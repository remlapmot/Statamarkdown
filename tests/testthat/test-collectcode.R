test_that("collectcode carries results from one chunk to a later chunk", {
  skip_on_cran()
  skip_if_no_stata()
  local_test_dir()

  doc <- c("```{stata, collectcode=TRUE}",
           "global answer 42",
           "```",
           "",
           "```{stata}",
           "display $answer",
           "```")
  out <- knitr::knit(text = doc, quiet = TRUE)

  # the second chunk can only display the macro if the collected code
  # from the first chunk was re-run before it
  expect_match(out, "42")

  # the profile.do used to replay collected code is cleaned up after knitting
  expect_false(file.exists("profile.do"))
})
