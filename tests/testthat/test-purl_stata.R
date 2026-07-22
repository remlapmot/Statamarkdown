indoc <- paste(c(
  "Some text.",
  "",
  "```{r setup}",
  "library(Statamarkdown)",
  "```",
  "",
  "```{stata first-Stata, collectcode=TRUE}",
  "sysuse auto, clear",
  "generate gpm = 1/mpg",
  "```",
  "",
  "```{stata second-Stata}",
  "regress price gpm",
  "```"
), collapse = "\n")

test_that("purl_stata() extracts only the Stata chunks", {
  res <- purl_stata(text = indoc)

  expect_true(any(grepl("sysuse auto, clear", res, fixed = TRUE)))
  expect_true(any(grepl("regress price gpm", res, fixed = TRUE)))
  # R chunk code is not extracted
  expect_false(any(grepl("library(Statamarkdown)", res, fixed = TRUE)))
})

test_that("documentation = TRUE records the chunk headers as comments", {
  res <- purl_stata(text = indoc)
  expect_true(any(grepl("* ---- stata first-Stata, collectcode=TRUE ----",
                        res, fixed = TRUE)))

  res2 <- purl_stata(text = indoc, documentation = FALSE)
  expect_false(any(grepl("* ----", res2, fixed = TRUE)))
})

test_that("purl_stata() writes a do-file which is overwritten on re-run", {
  local_test_dir()
  writeLines(indoc, "doc.Rmd")

  out <- purl_stata("doc.Rmd")
  expect_identical(out, "doc.do")
  expect_true(file.exists("doc.do"))
  first <- readLines("doc.do")

  # running again overwrites rather than appends
  purl_stata("doc.Rmd")
  expect_identical(readLines("doc.do"), first)
})

test_that("purl = FALSE and eval = FALSE chunks are skipped", {
  doc <- paste(c(
    "```{stata yes}",
    "display 1",
    "```",
    "",
    "```{stata no-purl, purl=FALSE}",
    "display 2",
    "```",
    "",
    "```{stata no-eval, eval=FALSE}",
    "display 3",
    "```",
    "",
    "```{stata yaml-opts}",
    "#| purl: false",
    "display 4",
    "```"
  ), collapse = "\n")

  res <- purl_stata(text = doc)
  expect_true(any(grepl("display 1", res, fixed = TRUE)))
  expect_false(any(grepl("display 2", res, fixed = TRUE)))
  expect_false(any(grepl("display 3", res, fixed = TRUE)))
  expect_false(any(grepl("display 4", res, fixed = TRUE)))
})

test_that("#| option comments are not copied into the do-file", {
  doc <- paste(c(
    "```{stata opts}",
    "#| collectcode: true",
    "sysuse auto",
    "```"
  ), collapse = "\n")

  res <- purl_stata(text = doc)
  expect_true(any(grepl("sysuse auto", res, fixed = TRUE)))
  expect_false(any(grepl("#|", res, fixed = TRUE)))
})

test_that("the older engine='stata' chunk syntax is recognised", {
  doc <- paste(c(
    "```{r old-style, engine='stata'}",
    "sysuse auto",
    "```"
  ), collapse = "\n")

  res <- purl_stata(text = doc)
  expect_true(any(grepl("sysuse auto", res, fixed = TRUE)))
})

test_that("a document without Stata chunks warns and writes nothing", {
  local_test_dir()
  writeLines("```{r}\n1 + 1\n```", "doc.Rmd")

  expect_warning(res <- purl_stata("doc.Rmd"), "No Stata code chunks")
  expect_identical(res, character())
  expect_false(file.exists("doc.do"))
})

test_that("output must differ from input", {
  local_test_dir()
  writeLines(indoc, "doc.Rmd")
  expect_error(purl_stata("doc.Rmd", output = "doc.Rmd"), "different")
})
