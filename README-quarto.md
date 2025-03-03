# Decision Curve Analysis Website (Quarto Version)

This repository contains the source code for the [Decision Curve Analysis](https://www.decisioncurveanalysis.org/) website, rebuilt using Quarto.

## Repository Structure

The repository is organized as follows:

```
decisioncurveanalysis/
├── _quarto.yml           # Quarto site configuration
├── index.qmd             # Home page
├── pages/                # Content pages
│   ├── dca-tutorial.qmd  # Tutorial page
│   ├── literature.qmd    # Literature page
│   └── resources.qmd     # Resources page
├── src/                  # Source files
│   ├── assets/           # Static assets
│   │   ├── css/          # CSS stylesheets
│   │   ├── images/       # Images
│   │   └── js/           # JavaScript files
│   ├── chunks/           # Reusable code chunks
│   ├── data/             # Data files for examples
│   ├── scripts/          # Utility scripts
│   └── templates/        # HTML templates
└── docs/                 # Generated website (output)
```

## Building the Website

To build the website locally:

1. Install [Quarto](https://quarto.org/docs/get-started/)
2. Clone this repository
3. Run the following commands:

```bash
# Preview the site (with live reloading)
quarto preview

# Build the site
quarto render
```

## Conversion from R Markdown

This website was converted from R Markdown to Quarto. The main changes include:

1. Updated YAML front matter to use Quarto syntax
2. Reorganized file structure for better maintainability
3. Updated code chunk options to use Quarto's execution options
4. Improved TOC styling

## Contributing

Contributions are welcome! Please see the Issues tab for ways to contribute.

## License

This website is licensed under the [MIT License](LICENSE). 