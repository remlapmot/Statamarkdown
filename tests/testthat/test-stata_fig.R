test_that("stata.fig=TRUE exports the graph and honours fig.cap and fig.alt", {
  skip_on_cran()
  skip_if_no_stata()
  local_test_dir()

  doc <- paste(c(
    "```{stata scatterplot, stata.fig=TRUE, fig.cap='Mileage against weight', fig.alt='Scatter plot of car mileage falling as weight rises'}",
    "sysuse auto",
    "scatter mpg weight",
    "```"
  ), collapse = "\n")

  md <- knitr::knit(text = doc, quiet = TRUE)

  # the figure file is created under fig.path with the chunk label
  expect_true(file.exists("figure/scatterplot-1.svg"))
  # the image is included in the output
  expect_match(md, "figure/scatterplot-1.svg", fixed = TRUE)
  # caption and alternative text are carried through
  expect_match(md, "Mileage against weight", fixed = TRUE)
  expect_match(md, "Scatter plot of car mileage falling as weight rises",
               fixed = TRUE)
  # the appended graph export command is not echoed with the chunk code
  expect_no_match(md, "graph export", fixed = TRUE)
})

test_that("a stata.fig chunk which draws no graph messages and omits the figure", {
  skip_on_cran()
  skip_if_no_stata()
  local_test_dir()

  doc <- paste(c(
    "```{stata nograph, stata.fig=TRUE}",
    "display 1 + 1",
    "```"
  ), collapse = "\n")

  expect_message(
    md <- knitr::knit(text = doc, quiet = TRUE),
    "did not export a graph"
  )
  expect_false(file.exists("figure/nograph-1.svg"))
  expect_no_match(md, "figure/nograph-1.svg", fixed = TRUE)
  # the chunk's ordinary output is unaffected
  expect_match(md, "2", fixed = TRUE)
})

test_that("stata.fig.format selects the export format", {
  skip_on_cran()
  skip_if_no_stata()
  local_test_dir()

  doc <- paste(c(
    "```{stata pdfplot, stata.fig=TRUE, stata.fig.format='pdf'}",
    "sysuse auto",
    "scatter mpg weight",
    "```"
  ), collapse = "\n")

  md <- knitr::knit(text = doc, quiet = TRUE)

  expect_true(file.exists("figure/pdfplot-1.pdf"))
  expect_match(md, "figure/pdfplot-1.pdf", fixed = TRUE)
})

test_that("chunks without stata.fig are unchanged", {
  skip_on_cran()
  skip_if_no_stata()
  local_test_dir()

  doc <- paste(c(
    "```{stata plain}",
    "display 42",
    "```"
  ), collapse = "\n")

  md <- knitr::knit(text = doc, quiet = TRUE)

  expect_match(md, "42", fixed = TRUE)
  expect_no_match(md, "!\\[") # no figure include
  expect_false(dir.exists("figure"))
})

test_that("the hyphenated Quarto spellings stata-fig and stata-fig-format work", {
  skip_on_cran()
  skip_if_no_stata()
  local_test_dir()

  doc <- paste(c(
    "```{stata hyphens}",
    "*| stata-fig: true",
    "*| stata-fig-format: pdf",
    "sysuse auto",
    "scatter mpg weight",
    "```"
  ), collapse = "\n")

  md <- knitr::knit(text = doc, quiet = TRUE)

  expect_true(file.exists("figure/hyphens-1.pdf"))
  expect_match(md, "figure/hyphens-1.pdf", fixed = TRUE)
})
