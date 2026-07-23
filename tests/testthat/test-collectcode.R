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

test_that("collectcode works when a previous knit has restored the knit hooks", {
  skip_on_cran()
  skip_if_no_stata()
  local_test_dir()

  # simulate the state after a previous knit in the same session:
  # knitr has restored the hooks and chunk options
  old_hook <- knitr::knit_hooks$get("collectcode")
  old_path <- knitr::opts_chunk$get("engine.path")
  withr::defer({
    knitr::knit_hooks$set(collectcode = old_hook)
    knitr::opts_chunk$set(engine.path = old_path)
  })
  knitr::knit_hooks$restore()
  knitr::opts_chunk$delete("engine.path")

  doc <- paste(c(
    "```{stata first, collectcode=TRUE}",
    "sysuse auto, clear",
    "generate gpm = 1/mpg",
    "```",
    "",
    "```{stata second}",
    "summarize gpm",
    "```"
  ), collapse = "\n")

  md <- knitr::knit(text = doc, quiet = TRUE)
  expect_match(md, ".0501928", fixed = TRUE)
})
