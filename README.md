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

### Using build_site.sh (Shell Script)

For a more streamlined development experience, you can use the included `build_site.sh` script:

```bash
# Make the script executable (only needed once)
chmod +x build_site.sh

# Build and preview the entire site
./build_site.sh
```

This script:
- Renders the tutorial for all languages (R, Stata, SAS, Python)
- Builds all site pages with proper navigation
- Keeps all output in the `_site` directory (keeps repo root clean)
- Automatically cleans up temporary files
- Opens your browser to preview the site when done

It's the recommended way to preview the site locally during development as it closely matches how the site is built during deployment.

## Example Workflow

Here's a common workflow for contributing to this site:

1. Make your changes (edit content, add examples, fix bugs)
2. Run `./build_site.sh` to preview the changes
3. Check the site in your browser (automatically opened by the script)
4. Make further adjustments if needed
5. Commit your changes to your branch
6. Create a pull request

The GitHub Actions workflow will automatically build and deploy the site when changes are merged to the main branch.
