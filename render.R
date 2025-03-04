# Render script for the Decision Curve Analysis site
# Run this from the root of the repository

# Function to check and kill process on port 8000 (macOS specific)
kill_port_process <- function(port = 8000) {
  # Check if any process is using port 8000
  port_check <- system(sprintf("lsof -i :%d -t", port), intern = TRUE)
  
  if (length(port_check) > 0) {
    cat(sprintf("Process found on port %d. Attempting to kill...\n", port))
    # Kill the process
    system(sprintf("kill -9 %s", paste(port_check, collapse = " ")))
    Sys.sleep(1) # Give it a moment to release the port
    cat("Process terminated.\n")
  } else {
    cat(sprintf("No process found on port %d.\n", port))
  }
}

# Clear the docs directory
if(dir.exists("docs")) {
  unlink("docs", recursive = TRUE, force = TRUE)
}
dir.create("docs", showWarnings = FALSE)

# Build the site using R Markdown's site generator
# This will use the _site.yml configuration file in the pages directory
setwd("pages")
rmarkdown::render_site()
setwd("..")

# The tutorial with parameters needs special handling
# Render the language-specific tutorials
rmarkdown::render("pages/dca-tutorial.Rmd",
                  params = list(language = "r"),
                  output_file = "../docs/dca-tutorial-r.html")
rmarkdown::render("pages/dca-tutorial.Rmd",
                  params = list(language = "stata"),
                  output_file = "../docs/dca-tutorial-stata.html")
rmarkdown::render("pages/dca-tutorial.Rmd",
                  params = list(language = "sas"),
                  output_file = "../docs/dca-tutorial-sas.html")
rmarkdown::render("pages/dca-tutorial.Rmd",
                  params = list(language = "python"),
                  output_file = "../docs/dca-tutorial-python.html")

# Create a redirect from dca-tutorial.html to dca-tutorial-r.html
# This ensures users landing on dca-tutorial.html will see the R version by default
file.copy("docs/dca-tutorial-r.html", "docs/dca-tutorial.html", overwrite = TRUE)

# Copy assets to the docs directory if needed
if(!dir.exists("docs/assets")) {
  dir.create("docs/assets", recursive = TRUE, showWarnings = FALSE)
  file.copy("assets", "docs", recursive = TRUE)
}

# Site is built successfully
cat("Site built successfully!\n")

# Kill any existing process on port 8000
kill_port_process(8000)

# Start a new server in the docs directory
cat("Starting server on http://localhost:8000\n")
cat("Press Ctrl+C to stop the server when done.\n")

# Change to the docs directory and start a server
# This approach depends on the OS
if (Sys.info()["sysname"] == "Darwin" || Sys.info()["sysname"] == "Linux") {
  # For macOS or Linux
  system("cd docs && python -m http.server 8000", wait = FALSE)
} else {
  # For Windows
  shell("cd docs && python -m http.server 8000", wait = FALSE)
}

cat("Server started. Open your browser and navigate to: http://localhost:8000\n") 