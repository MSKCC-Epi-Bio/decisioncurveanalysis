# Migration Guide: R Markdown to Quarto

This guide documents the process of migrating the Decision Curve Analysis website from R Markdown to Quarto.

## Migration Summary

The migration involved:

1. Creating a new Quarto project structure
2. Converting R Markdown (.Rmd) files to Quarto Markdown (.qmd)
3. Reorganizing assets and templates
4. Updating configuration and navigation
5. Enhancing content and fixing layout issues

## Directory Structure Changes

### Old Structure:
```
decisioncurveanalysis/
├── _site.yml
├── index.Rmd
├── literature.Rmd
├── dca-tutorial.Rmd
├── images/
├── data/
└── templates/
```

### New Structure:
```
decisioncurveanalysis/
├── _quarto.yml
├── index.qmd
├── pages/
│   ├── literature.qmd
│   ├── dca-tutorial.qmd
│   └── resources.qmd
├── assets/
│   ├── css/
│   ├── images/
│   └── data/
└── templates/
```

## Key Configuration Changes

1. Replaced `_site.yml` with `_quarto.yml`
2. Updated output directory to `docs/` for GitHub Pages compatibility
3. Added explicit render list for all pages
4. Enhanced navigation and formatting options

## Content Enhancements

### Literature Page
- Fixed card layout CSS to properly align years with headers
- Completed all content sections from the original site
- Improved styling and readability

### Tutorial Page
- Enhanced with comprehensive code examples for all programming languages
- Added detailed explanations of DCA implementation
- Created tabbed interface for language-specific examples
- Added interpretation guidelines and advanced topics

### Resources Page
- Created a new dedicated resources page
- Added comprehensive information about software packages
- Included educational resources and example datasets
- Added FAQ section and community resources

## Common Issues Encountered

1. **CSS Layout Problems**: Some CSS styles needed adjustments to work properly in Quarto
   - Solution: Updated CSS selectors and properties for better compatibility

2. **Content Organization**: Needed to ensure all content was properly transferred
   - Solution: Systematically reviewed all original files and enhanced content where needed

3. **Template Integration**: Some templates needed adjustment for Quarto
   - Solution: Updated template files and ensured proper inclusion

4. **Rendering Configuration**: Initial rendering errors due to directory structure
   - Solution: Created necessary output directories and updated paths

## Best Practices for Future Updates

1. **Content Updates**: 
   - Edit the .qmd files directly in the repository
   - Run `quarto preview` to test changes locally
   - Run `quarto render` to build the site
   - Commit only source files (.qmd, .yml, etc.)

2. **Adding New Pages**:
   - Create new .qmd files in the appropriate directory
   - Add them to the render list in _quarto.yml
   - Update navigation as needed

3. **CSS Changes**:
   - Make changes to assets/css/custom.css
   - Test thoroughly with various screen sizes

4. **Repository Management**:
   - Consider using pull requests for significant changes
   - Document changes in commit messages
   - Update README.md when appropriate

## Resources for Quarto

- [Quarto Documentation](https://quarto.org/docs/guide/)
- [Quarto Website Tutorial](https://quarto.org/docs/websites/)
- [Quarto GitHub Pages Deployment](https://quarto.org/docs/publishing/github-pages.html) 