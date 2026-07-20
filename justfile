check: docs
    R -e "devtools::check()"
docs:
    R -e "devtools::document()"
vigs:
    R -e "source('vignettes/render_vignette_source.R')"
test:
    R -e "devtools::test()"
