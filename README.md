# DCA Website Repo

<!-- badges: start -->
| Python (PyPI) | R (CRAN) |
| :-----------: | :------: |
| ![PyPI Downloads](https://static.pepy.tech/badge/dcurves) | ![CRAN downloads](https://cranlogs.r-pkg.org/badges/grand-total/dcurves?color=blue) |
<!-- badges: end -->

This repository contains the source code and materials used to build the Decision Curve Analysis website ([decisioncurveanalysis.org](https://decisioncurveanalysis.org)).

## Essential Commands

### In R Console

```r
# 1. Clean the site (remove generated files, especially cache)
rmarkdown::clean_site(preview = FALSE)

# 2. Render main site (this builds index.html and other core pages)
rmarkdown::render_site()

# Optional: Render language-specific versions of the tutorial
# (Run this *after* render_site)
languages <- c("r", "stata", "sas", "python")
for (lang in languages) {
  rmarkdown::render("dca-tutorial.Rmd",
                    output_file = paste0("dca-tutorial-", lang, ".html"),
                    params = list(language = lang))
}
```
