# R Markdown to Quarto Migration Guide

This document outlines the process of migrating the Decision Curve Analysis website from R Markdown to Quarto, including issues encountered and their solutions.

## Migration Steps

1. **Creating the Quarto project structure**
   - Created a `_quarto.yml` configuration file
   - Set up an organized directory structure with `pages/`, `assets/`, etc.
   - Moved CSS to `assets/css/`

2. **Converting R Markdown files to Quarto**
   - Updated YAML headers to use Quarto format
   - Created .qmd versions of all .Rmd files
   - Updated relative paths in links and image references

3. **Issues Encountered and Solutions**

### CSS Display Issue

**Problem**: CSS code was being displayed directly on the page instead of being applied as styling.

**Solution**: In Quarto, CSS needs to be included in a raw HTML block using the `{=html}` syntax:

```qmd
```{=html}
<style>
/* CSS rules here */
</style>
```

Instead of using R Markdown's CSS chunk:

```rmd
```{css}
/* CSS rules here */
```
```

### Template Issues

**Problem**: The tabset template had variable placeholders like `{{echo}}` that weren't defined.

**Solution**: Updated the template to use fixed values instead of placeholder variables:

```diff
- ```{r, r-{{chunk_label}}, eval = {{eval}}, echo = {{echo}}, message = {{message}}, include = {{include}}}
+ ```{r, r-{{chunk_label}}, eval = TRUE, echo = FALSE, message = FALSE, include = TRUE}
```

### Python Environment Issues

**Problem**: Quarto requires certain Python packages (yaml, jupyter) for rendering.

**Solution**: Created a Python virtual environment and installed required packages:

```bash
python3 -m venv quarto_env
source quarto_env/bin/activate
pip install jupyter pyyaml
```

### File Path Issues

**Problem**: Quarto couldn't find output directories during rendering.

**Solution**: Ensured required directories like `docs/` existed before rendering:

```bash
mkdir -p docs
```

## Best Practices for Future Updates

1. **CSS Management**:
   - Keep global styles in `assets/css/custom.css`
   - Page-specific styles should be included in HTML style blocks

2. **Content Updates**:
   - Edit .qmd files in the root or pages/ directory
   - Run `quarto render` to rebuild the site
   - Only commit source files (.qmd, .yml, etc.), not generated files

3. **Interactive Examples**:
   - Use Quarto's support for interactive components like panel-tabsets

4. **Python Integration**:
   - Activate the virtual environment before rendering:
   ```bash
   source quarto_env/bin/activate
   quarto render
   ``` 