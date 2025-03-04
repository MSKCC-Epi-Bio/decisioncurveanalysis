library(mice)    # For multiple imputation
library(dcurves) # For decision curve analysis
library(dplyr)   # For data manipulation
library(ggplot2) # For plotting

# Example: Simulating a dataset with missing values
set.seed(123) # For reproducibility
data <- tibble(
  patientid = 1:100,
  cancer = rbinom(100, 1, 0.3),
  risk_group = sample(c("low", "intermediate", "high"), 100, replace = TRUE),
  age = rnorm(100, mean = 65, sd = 10),
  famhistory = sample(c(NA, 1, 0), 100, replace = TRUE),
  marker = runif(100),
  cancerpredmarker = runif(100, 0, 0.6)
)

# Impute missing values (this is a simplistic approach for illustration)
# 'mice' = 'Multivariate Imputation by Chained Equations'
# Adjust 'm' as needed for the number of imputations
num_imputations <- 5 # Make this dynamic based on your requirements
mice_data <- mice(data, m = num_imputations, method = 'pmm', maxit = 5, print = FALSE)

# Create one large dataset from all imputed datasets using the dynamic 'm'
all_imputed_data <- do.call(rbind, lapply(1:num_imputations, function(i) complete(mice_data, action = i)))

# Now perform DCA on this combined dataset
dca(cancer ~ cancerpredmarker + famhistory, 
    data = all_imputed_data,
    thresholds = seq(0, 0.35, by = 0.01)) %>%
  plot(smooth = TRUE)
