check: docs
    R -e "devtools::check()"
docs:
    R -e "devtools::document()"
install: docs
    R CMD INSTALL .
vigs:
    R -e "source('vignettes/render_vignette_source.R')"
test:
    R -e "devtools::test()"
