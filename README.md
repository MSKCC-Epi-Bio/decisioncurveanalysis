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
# Clean the site (remove generated files)
rmarkdown::clean_site(preview = FALSE)

# Render main site
rmarkdown::render_site()

# Render language-specific versions of tutorial
languages <- c("r", "stata", "sas", "python")
for (lang in languages) {
  rmarkdown::render("dca-tutorial.Rmd", 
                    output_file = paste0("dca-tutorial-", lang, ".html"),
                    params = list(language = lang))
}
```

### From Terminal

```bash
# Clean the site
Rscript -e 'rmarkdown::clean_site(preview = FALSE)'

# Render main site
Rscript -e 'rmarkdown::render_site()'

# Render language-specific versions (all in one command)
Rscript -e 'languages <- c("r", "stata", "sas", "python"); for (lang in languages) { rmarkdown::render("dca-tutorial.Rmd", output_file = paste0("dca-tutorial-", lang, ".html"), params = list(language = lang)) }'
```


