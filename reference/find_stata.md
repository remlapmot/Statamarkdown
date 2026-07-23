# A helper function that seeks to locate your Stata executable. Ordinarily this is run automatically when Statamarkdown is loaded.

This function searches for recent versions of Stata (\>= Stata 11), in
some of the usual default installation locations.

If Stata is not found, you will have to specify its correct location
yourself.

## Usage

``` r
find_stata(message=TRUE)
```

## Arguments

- message:

  (logical) Whether or not to print a message when Stata is found.

## Value

A character string with the path and name of the Stata executable.

## Author

Doug Hemken

## See also

[`Statamarkdown-package`](https://hemken.github.io/Statamarkdown/reference/Statamarkdown-package.md)

## Examples

```` r
indoc <- '
# An R console example
## In a first code chunk, set up with
```{r}
library(Statamarkdown)
```

## Then mark Stata code chunks with
```{stata}
sysuse auto, clear
generate gpm = 1/mpg
summarize price gpm
```
'

if (nzchar(Statamarkdown::find_stata())) {
  # To run this example, remove tempdir().
  fmd <- file.path(tempdir(), "test.md")
  fhtml <- file.path(tempdir(), "test.html")

  knitr::knit(text=indoc, output=fmd)
  rmarkdown::render(fmd, "html_document", fhtml)
}
#> Stata found at /Applications/StataNow/StataMP.app/Contents/MacOS/StataMP
#> 1/5                  
#> 2/5 [unnamed-chunk-1]
#> 3/5                  
#> 4/5 [unnamed-chunk-2]
#> 5/5                  
#> /opt/homebrew/bin/pandoc +RTS -K512m -RTS test.md --to html4 --from markdown+autolink_bare_uris+tex_math_single_backslash --output /var/folders/kt/7xskrb1n4_x2jkd9lt0rhybh0000gp/T//Rtmp7tOL6T/test.html --lua-filter /Users/eptmp/Library/R/arm64/4.6/library/rmarkdown/rmarkdown/lua/pagebreak.lua --lua-filter /Users/eptmp/Library/R/arm64/4.6/library/rmarkdown/rmarkdown/lua/latex-div.lua --lua-filter /Users/eptmp/Library/R/arm64/4.6/library/rmarkdown/rmarkdown/lua/table-classes.lua --embed-resources --standalone --variable bs3=TRUE --section-divs --template /Users/eptmp/Library/R/arm64/4.6/library/rmarkdown/rmd/h/default.html --syntax-highlighting none --variable highlightjs=1 --variable theme=bootstrap --mathjax --variable 'mathjax-url=https://mathjax.rstudio.com/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML' --include-in-header /var/folders/kt/7xskrb1n4_x2jkd9lt0rhybh0000gp/T//Rtmp7tOL6T/rmarkdown-str915a5fe9b5ef.html 
#> 
#> Output created: /var/folders/kt/7xskrb1n4_x2jkd9lt0rhybh0000gp/T//Rtmp7tOL6T/test.html
````
