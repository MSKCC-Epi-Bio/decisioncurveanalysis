# Decision Curve Analysis Website

This repository contains the source code for the Decision Curve Analysis website, which provides resources, tutorials, and literature on decision curve analysis methodology.

## Project Structure

The repository is organized as follows:

- **assets/** - Static assets for the website
  - **css/** - Custom CSS styles
  - **highlight/** - Code highlighting resources
  - **images/** - Images used throughout the site

- **build/** - Build scripts and configuration
  - **render.R** - Main script for building the site

- **data/** - Data files used in examples

- **docs/** - Generated site (output directory)

- **pages/** - Source R Markdown files
  - **dca-tutorial.Rmd** - Software tutorial with language-specific versions
  - **index.Rmd** - Homepage
  - **literature.Rmd** - Peer-reviewed literature
  - **resources.Rmd** - Other resources
  - **_site.yml** - Site configuration for the pages directory

- **rmd_chunks/** - Code chunks included in the R Markdown files

- **templates/** - HTML templates and includes

## Building the Site

To build the site:

1. Make sure you have R installed with the required packages:
   ```r
   install.packages(c("rmarkdown", "knitr", "tidyverse", "gtsummary", "dcurves", "gt"))
   ```

2. Run the render script from the root of the repository:
   ```r
   source("build/render.R")
   ```

This will:
- Clear the existing docs directory
- Build the site using R Markdown's site generator
- Render language-specific versions of the tutorial
- Copy assets to the docs directory
- Start a local server on port 8000

## Language-Specific Tutorials

The site includes tutorials for multiple programming languages:
- R
- Stata
- SAS
- Python

Each language version is generated from the same source file (`pages/dca-tutorial.Rmd`) using parameters.

## Contributing

If you'd like to contribute to this project, please:
1. Fork the repository
2. Make your changes
3. Submit a pull request

## License

[Add license information here]

## Contact

[Add contact information here]

# DCA Tutorial

<!-- badges: start -->

<!-- badges: end -->

Decision Curve Analysis Tutorial 

To do list....
- SAS
    - [X] Update to work with case control data
    - [X] Add a NEWS.md file to track updates and version releases
    - [X] Review+merge PR
- Stata
    - [X] Update to work with case control data
    - [X] Add a NEWS.md file to track updates and version releases
    - [X] Review+merge PR
- Python
    - [X] Finish module
    - [X] Implement unit testing
    - [ ] Add a module website?
- Tutorial
    - [X] Add tabsets with each language is its own tab
    - [X] Add language-specific code highlighting
    - [X] Update the dataset(?s?) used in the tutorial. We previously used a single data set and modfied the interpretation of the variables depending on the setting, .e.g binary outcome, time to event, case-control, but I think this is more confusing than 3 separate data sets.
    - [X] Update the the case-control data analysis section to utilize user-passed population prevalence
    - [X] Refresh the previous tutorial as needed.
    - [X] Add the R code
    - [X] Add the Stata code
    - [X] Add the SAS code
    - [ ] Add the Python code

