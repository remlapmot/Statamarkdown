test_that("spinstata() converts marked-up Stata comments to a knitr document", {
  skip_on_cran()

  indoc <- paste(c("/*' ",
                   "# Spin Example",
                   "",
                   "Some explanatory text.",
                   "'*/",
                   "",
                   "/*+ dosomething, engine='stata' +*/",
                   "sysuse auto",
                   "summarize"),
                 collapse = "\n")

  res <- spinstata(text = indoc, knit = FALSE)
  txt <- paste(res, collapse = "\n")

  # document text is passed through as markdown
  expect_match(txt, "# Spin Example", fixed = TRUE)
  expect_match(txt, "Some explanatory text.", fixed = TRUE)
  # the chunk header comment becomes a fenced code chunk
  expect_match(txt, "```{r dosomething, engine='stata'}", fixed = TRUE)
  # the Stata code is inside the document
  expect_match(txt, "sysuse auto", fixed = TRUE)
  expect_match(txt, "summarize", fixed = TRUE)
})
