// Add target="_blank" to external links in the navbar
(function() {
  // Function to add target="_blank" to links
  function addTargetBlank() {
    console.log("Running external links script");
    
    // Get all links in the navbar
    var navbarLinks = document.querySelectorAll('.navbar-nav a[href*="github.com"]');
    console.log("Found " + navbarLinks.length + " GitHub links in navbar");
    
    // Add target="_blank" to each external link
    navbarLinks.forEach(function(link) {
      link.setAttribute('target', '_blank');
      console.log("Set target='_blank' on:", link.href);
    });
  }

  // Execute when DOM is fully loaded
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", addTargetBlank);
  } else {
    // DOM is already ready
    addTargetBlank();
  }
  
  // Also try after a short delay to ensure all elements are loaded
  setTimeout(addTargetBlank, 1000);
})(); 