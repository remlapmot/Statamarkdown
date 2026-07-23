# Convert a specially marked up Stata "do" file to Markdown and HTML.

This function takes a Stata file containing special markup in its
comments, and converts it to Markdown and HTML documents (or one of
several other formats).

## Usage

``` r
spinstata(statafile, text=NULL, keep=FALSE, ...)
```

## Arguments

- statafile:

  A character string with the name of a Stata "do" file, containing
  markup in its comments.

- text:

  A character string in place of a file.

- keep:

  Whether to save intermediate files.

- ...:

  options passed to
  [`knitr::spin`](https://rdrr.io/pkg/knitr/man/spin.html)

## Details

This function takes a Stata file containing special markup in its
comments, and converts it into knitr's "spin" format. This is in turn
sent to [`knitr::spin`](https://rdrr.io/pkg/knitr/man/spin.html), and
converted to Markdown and HTML (or one of several other formats).

Special Markup:

- `"/*' "` - Begin document text, ends with `"'*/"`

- `"/*+ "` - Begin chunk header, ends with `"+*/"`

- `"/*R "` - Begin a chunk of R code, ends with `"R*/"`

- `"/** "` - Dropped from document, ends with `"*/*"`

## Value

The path to the output file.

If given text instead of a file, returns the compiled document as a
character string.

## Author

Doug Hemken

## See also

[`Statamarkdown-package`](https://hemken.github.io/Statamarkdown/reference/Statamarkdown-package.md)

## Examples

``` r
if (FALSE) { # \dontrun{
indoc <- "/*'
# Statamarkdown Example

This is a special Stata script which can be used to generate a report.
You can write normal text in command-style comments.

First we load Statamarkdown.
'*/

  /*+  setup +*/
  /*R
library(Statamarkdown)
R*/

  /*' The report begins here. '*/

  /*+  example1, engine='stata' +*/
  sysuse auto
/* Stata comment */
  summarize

/*' You can use the ***usual*** Markdown to mark up text.'*/
"
if (nzchar(Statamarkdown::find_stata())) {
  # To run this example, remove tempdir().
  fhtml <- file.path(tempdir(), "test.html")
  x<-Statamarkdown::spinstata(text=indoc)
  writeLines(x, fhtml)
}
} # }
```
