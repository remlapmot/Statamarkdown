# Precompute the vignettes, which require Stata, following
# https://ropensci.org/blog/2019/12/08/precompute-vignettes/
# Run from the package root directory:
#   source("vignettes/render_vignette_source.R")
#
# Each vignette is knit in a fresh R process (as R CMD build does)
# because Statamarkdown sets the engine.path chunk option in .onAttach,
# and knitr::knit() restores chunk options when it finishes -- so a
# second knit in the same session would find engine.path unset.
#
# The knits are run from within vignettes/ so that the chunks, the
# knitr hooks, and Stata itself all share the same working directory
# (the collectcode option in linkblocks relies on this).
#
# The display-only examples in the .qmd.orig files use Quarto's
# "unexecuted block" syntax, ```{{stata ...}}, which knitr passes
# through untouched here and quarto renders as a ```{stata ...}
# fence when the vignettes are built.
xfun::in_dir("vignettes", {
  for (v in c("basicuse", "linkblocks", "randstata")) {
    xfun::Rscript_call(
      knitr::knit,
      list(input = paste0(v, ".qmd.orig"), output = paste0(v, ".qmd"), quiet = TRUE)
    )
  }
})
