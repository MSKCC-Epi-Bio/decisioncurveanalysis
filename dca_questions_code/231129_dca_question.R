

# install dcurves to perform DCA from CRAN
# install.packages("dcurves")
# 
# # install other packages used in this tutorial
# install.packages(
#   c("tidyverse", "survival", "gt", "broom",
#     "gtsummary", "rsample", "labelled")
# )

# load packages
library(dcurves)
library(tidyverse)
library(gtsummary)

# import data
df_cancer_dx <-
  readr::read_csv(
    file = "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_cancer_dx.csv"
  ) %>%
  # assign variable labels. these labels will be carried through in the `dca()` output
  labelled::set_variable_labels(
    patientid = "Patient ID",
    cancer = "Cancer Diagnosis",
    risk_group = "Risk Group",
    age = "Patient Age",
    famhistory = "Family History",
    marker = "Marker",
    cancerpredmarker = "Prediction Model"
  )

# summarize data
df_cancer_dx %>%
  select(-patientid) %>%
  tbl_summary(type = all_dichotomous() ~ "categorical")

# build logistic regression model
mod1 <- glm(cancer ~ famhistory, data = df_cancer_dx, family = binomial)

# model summary
mod1_summary <- tbl_regression(mod1, exponentiate = TRUE)
mod1_summary


dca(cancer ~ famhistory, data = df_cancer_dx, as_probability = 'famhistory') %>%
  plot(smooth=TRUE)



