# GitHub Pages Branch for Decision Curve Analysis

This branch contains the built version of the [Decision Curve Analysis website](https://www.decisioncurveanalysis.org/).

## Important Note

This branch is **automatically generated** by GitHub Actions. Do not make manual changes to this branch, as they will be overwritten the next time the workflow runs.

All changes should be made in the `main` branch of the repository, and this branch will be updated automatically when changes are pushed to `main`.

## Website Build Process

The website is built using R Markdown. The GitHub Actions workflow:

1. Checks out the `main` branch
2. Sets up R and Pandoc
3. Installs dependencies
4. Renders the R Markdown files with `rmarkdown::render_site()`
5. Copies the generated HTML and supporting files to this branch

The source code for the website is available in the `main` branch.
