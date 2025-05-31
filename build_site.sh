#!/usr/bin/env bash
set -e

# Directory where all generated HTML (and *_files dirs) will go
BUILD_DIR="_site"

# Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Run the R parts
Rscript - <<'RSCRIPT'
# Install any missing packages
needed <- c("rmarkdown","knitr","dcurves","tidyverse","gtsummary",
            "here","reticulate","rsample")
missing <- setdiff(needed, rownames(installed.packages()))
if (length(missing)) install.packages(missing, repos = "https://cloud.r-project.org")

# Build language-specific tutorial pages
languages <- c("r","stata","sas","python")
for (lang in languages) {
  rmarkdown::render(
    input       = "dca-tutorial.Rmd",
    output_file = sprintf("dca-tutorial-%s.html", lang),
    output_dir  = "_site",
    params      = list(language = lang),
    quiet       = TRUE
  )
}

# Render each .Rmd file with output dir set to _site
site_files <- list.files(pattern = "\\.(R|r)md$", 
                        include.dirs = FALSE, 
                        recursive = FALSE)

# Skip dca-tutorial.Rmd (already handled above)
site_files <- site_files[site_files != "dca-tutorial.Rmd"]

# Render each file to _site
for (file in site_files) {
  cat("Rendering:", file, "\n")
  rmarkdown::render(
    input = file,
    output_dir = "_site",
    quiet = TRUE
  )
}
RSCRIPT

# After R is done, clean up any stray files
find . -maxdepth 1 -type f -name "*.html" ! -path "./_site/*" -exec rm -f {} \;
find . -maxdepth 1 -type d -name "*_files" ! -path "./_site" -exec rm -rf {} \;
# Clean up temporary knit files
find . -maxdepth 1 -type f -name "*.knit*.md" -exec rm -f {} \;
find . -maxdepth 1 -type f -name "*.utf8.md" -exec rm -f {} \;

# Create a default tutorial page (copy of R version) to make navigation work
cp "$BUILD_DIR/dca-tutorial-r.html" "$BUILD_DIR/dca-tutorial.html" 2>/dev/null || true

echo -e "\n✅ Local site built in ${BUILD_DIR}/"

# Check for any remaining temporary files
TEMP_FILES=$(find . -maxdepth 1 -type f \( -name "*.knit*" -o -name "*.utf8.md" -o -name "*.md.bak" \))
if [ -n "$TEMP_FILES" ]; then
  echo -e "\n⚠️  Warning: These temporary files still exist:"
  echo "$TEMP_FILES"
fi

# Open the site
if command -v open &>/dev/null; then
  open "${BUILD_DIR}/index.html"
elif command -v xdg-open &>/dev/null; then
  xdg-open "${BUILD_DIR}/index.html" &>/dev/null &
fi