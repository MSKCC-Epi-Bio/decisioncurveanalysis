# ---- install ----- 
# install dcurves to perform DCA from CRAN
install.packages("dcurves")

# install other packages used in this tutorial
install.packages(
  c("tidyverse", "survival", "gt", "broom",
    "gtsummary", "rsample", "labelled")
)

# load packages
library(dcurves)
library(tidyverse)
library(gtsummary)

# ---- import_cancer ----- 
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

# ---- model ----- 
# build logistic regression model
mod1 <- glm(cancer ~ famhistory, data = df_cancer_dx, family = binomial)

# model summary
mod1_summary <- tbl_regression(mod1, exponentiate = TRUE)
mod1_summary

# ---- dca_famhistory ----- 
dca(cancer ~ famhistory, data = df_cancer_dx) %>%
  plot()

# ---- dca_famhistory2 ----- 
dca(cancer ~ famhistory,
    data = df_cancer_dx,
    thresholds = seq(0, 0.35, 0.01)
) %>%
  plot()

# ---- model_multi ----- 
# build multivariable logistic regression model
mod2 <- glm(cancer ~ marker + age + famhistory, data = df_cancer_dx, family = binomial)

# summarize model
tbl_regression(mod2, exponentiate = TRUE)

# add predicted values from model to data set
df_cancer_dx <-
  df_cancer_dx %>%
  mutate(
    cancerpredmarker =
      broom::augment(mod2, type.predict = "response") %>%
      pull(".fitted")
  )

# ---- dca_multi ----- 
dca(cancer ~ famhistory + cancerpredmarker,
    data = df_cancer_dx,
    thresholds = seq(0, 0.35, 0.01),
    label = list(cancerpredmarker = "Prediction Model")
) %>%
  plot(smooth = FALSE)

# ---- dca_smooth ----- 
dca(cancer ~ famhistory + cancerpredmarker,
    data = df_cancer_dx,
    thresholds = seq(0, 0.35, 0.01),
    label = list(cancerpredmarker = "Prediction Model")
) %>%
  plot(smooth = TRUE)

# ---- dca_smooth2 ----- 
dca(cancer ~ famhistory + cancerpredmarker,
    data = df_cancer_dx,
    thresholds = seq(0, 0.35, 0.05),
    label = list(cancerpredmarker = "Prediction Model")
) %>%
  plot(smooth = FALSE)

# ---- pub_model ----- 
# Use the coefficients from the Brown model
df_cancer_dx <-
  df_cancer_dx %>%
  mutate(
    logodds_brown = 0.75 * famhistory + 0.26 * age - 17.5,
    phat_brown = exp(logodds_brown) / (1 + exp(logodds_brown))
  )

# Run the decision curve
dca(cancer ~ phat_brown,
    data = df_cancer_dx,
    thresholds = seq(0, 0.35, 0.01),
    label = list(phat_brown = "Brown Model")
) %>%
  plot(smooth = TRUE)

# ---- joint ----- 
# Create a variable for the strategy of treating only high risk patients
df_cancer_dx <-
  df_cancer_dx %>%
  mutate(
    # This will be 1 for treat and 0 for don’t treat
    high_risk = ifelse(risk_group == "high", 1, 0),
    # Treat based on Joint Approach
    joint = ifelse(risk_group == "high" | cancerpredmarker > 0.15, 1, 0),
    # Treat based on Conditional Approach
    conditional =
      ifelse(risk_group == "high" | (risk_group == "intermediate" & cancerpredmarker > 0.15), 1, 0)
  )

# ---- dca_joint ----- 
dca(cancer ~ high_risk + joint + conditional,
    data = df_cancer_dx,
    thresholds = seq(0, 0.35, 0.01),
    label = list(
      high_risk = "High Risk",
      joint = "Joint Test",
      conditional = "Conditional Approach"
    )
) %>%
  plot(smooth = TRUE)

# ---- dca_harm_simple ----- 
# Run the decision curve
dca(cancer ~ marker,
    data = df_cancer_dx,
    thresholds = seq(0, 0.35, 0.01),
    as_probability = "marker",
    harm = list(marker = 0.0333)
) %>%
  plot(smooth = TRUE)

# ---- dca_harm ----- 
# the harm of measuring the marker is stored in a scalar
harm_marker <- 0.0333
# in the conditional test, only patients at intermediate risk
# have their marker measured
# harm of the conditional approach is proportion of patients who have the marker
# measured multiplied by the harm
harm_conditional <- mean(df_cancer_dx$risk_group == "intermediate") * harm_marker

# Run the decision curve
dca(cancer ~ risk_group,
    data = df_cancer_dx,
    thresholds = seq(0, 0.35, 0.01),
    as_probability = "risk_group",
    harm = list(risk_group = harm_conditional)
) %>%
  plot(smooth = TRUE)


# ---- dca_table ----- 
dca(cancer ~ marker,
    data = df_cancer_dx,
    as_probability = "marker",
    thresholds = seq(0.05, 0.35, 0.15)
) %>%
  as_tibble() %>%
  select(label, threshold, net_benefit) %>%
  gt::gt() %>%
  gt::fmt_percent(columns = threshold, decimals = 0) %>%
  gt::fmt(columns = net_benefit, fns = function(x) style_sigfig(x, digits = 3)) %>%
  gt::cols_label(
    label = "Strategy",
    threshold = "Decision Threshold",
    net_benefit = "Net Benefit"
  ) %>%
  gt::cols_align("left", columns = label)

# ---- dca_intervention ----- 
dca(cancer ~ marker,
    data = df_cancer_dx,
    as_probability = "marker",
    thresholds = seq(0.05, 0.35, 0.01),
    label = list(marker = "Marker")
) %>%
  net_intervention_avoided() %>%
  plot(smooth = TRUE)

# ---- import_ttcancer ----- 
# import data
df_time_to_cancer_dx <-
  readr::read_csv(
    file = "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_time_to_cancer_dx.csv"
  ) %>%
  # assign variable labels. these labels will be carried through in the `dca()` output
  labelled::set_variable_labels(
    patientid = "Patient ID",
    cancer = "Cancer Diagnosis",
    ttcancer = "Years to Diagnosis/Censor",
    risk_group = "Risk Group",
    age = "Patient Age",
    famhistory = "Family History",
    marker = "Marker",
    cancerpredmarker = "Prediction Model",
    cancer_cr = "Cancer Diagnosis Status"
  )

# ---- coxph ----- 
# Load survival library
library(survival)

# Run the cox model
coxmod <- coxph(Surv(ttcancer, cancer) ~ age + famhistory + marker, data = df_time_to_cancer_dx)

df_time_to_cancer_dx <-
  df_time_to_cancer_dx %>%
  mutate(
    pr_failure18 =
      1 - summary(survfit(coxmod, newdata = df_time_to_cancer_dx), times = 1.5)$surv[1, ]
  )

# ---- stdca_coxph ----- 
dca(Surv(ttcancer, cancer) ~ pr_failure18,
    data = df_time_to_cancer_dx,
    time = 1.5,
    thresholds = seq(0, 0.5, 0.01),
    label = list(pr_failure18 = "Prediction Model")
) %>%
  plot(smooth = TRUE)


# ---- stdca_cmprsk ----- 
# status variable must be a factor with first level coded as 'censor',
# and the second level the outcome of interest.
df_time_to_cancer_dx <-
  df_time_to_cancer_dx %>%
  mutate(
    cancer_cr =
      factor(cancer_cr,
             levels = c("censor", "diagnosed with cancer", "dead other causes")
      )
  )

dca(Surv(ttcancer, cancer_cr) ~ pr_failure18,
    data = df_time_to_cancer_dx,
    time = 1.5,
    thresholds = seq(0, 0.5, 0.01),
    label = list(pr_failure18 = "Prediction Model")
) %>%
  plot(smooth = TRUE)

# ---- import_case_control ----- 
# import data
df_cancer_dx_case_control <-
  readr::read_csv(
    file = "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_cancer_dx_case_control.csv"
  ) %>%
  # assign variable labels. these labels will be carried through in the `dca()` output
  labelled::set_variable_labels(
    patientid = "Patient ID",
    casecontrol = "Case-Control Status",
    risk_group = "Risk Group",
    age = "Patient Age",
    famhistory = "Family History",
    marker = "Marker",
    cancerpredmarker = "Prediction Model"
  )

# summarize data
df_cancer_dx_case_control %>%
  select(-patientid) %>%
  tbl_summary(
    by = casecontrol,
    type = all_dichotomous() ~ "categorical"
  ) %>%
  modify_spanning_header(all_stat_cols() ~ "**Case-Control Status**")

# ---- dca_case_control ----- 
dca(casecontrol ~ cancerpredmarker,
    data = df_cancer_dx_case_control,
    prevalence = 0.20,
    thresholds = seq(0, 0.5, 0.01)
) %>%
  plot(smooth = TRUE)

# ---- cross_validation ----- 
# set seed for random process
set.seed(112358)

formula = cancer ~ marker + age + famhistory
dca_thresholds = seq(0,0.36, 0.01)

# create a 10-fold cross validation set, 1 repeat which is the base case, change to suit your use case
cross_validation_samples <- rsample::vfold_cv(df_cancer_dx, v = 10, repeats = 1)

df_crossval_predictions <- 
  cross_validation_samples %>% 
  # for each cut of the data, build logistic regression on the 90% (analysis set)
  rowwise() %>% 
  mutate(
    # build regression model on analysis set
    glm_analysis =
      glm(formula = formula,
          data = rsample::analysis(splits),
          family = binomial
      ) %>%
      list(),
    # get predictions for assessment set
    df_assessment =
      broom::augment(
        glm_analysis,
        newdata = rsample::assessment(splits),
        type.predict = "response"
      ) %>%
      list()
  ) %>%
  ungroup() %>%
  # pool results from the 10-fold cross validation
  pull(df_assessment) %>%
  bind_rows() %>% # Concatenate all cross validation predictions
  group_by(patientid) %>%
  summarise(cv_pred = mean(.fitted), .groups = "drop") %>% # Generate mean prediction per patient
  ungroup()

df_cv_pred <-
  df_cancer_dx %>%
  left_join(
    df_crossval_predictions,
    by = 'patientid'
  )

dcurves::dca( # calculate net benefit scores on mean cross validation predictions
  data = df_cv_pred,
  formula = cancer ~ cv_pred,
  thresholds = dca_thresholds,
  label = list(
    cv_pred = "Cross-validated Prediction Model"
  ))$dca |> 
  # plot cross validated net benefit values
  ggplot(aes(x = threshold, y = net_benefit, color = label)) +
  stat_smooth(method = "loess", se = FALSE, formula = "y ~ x", span = 0.2) +
  coord_cartesian(ylim = c(-0.014, 0.14)) +
  scale_x_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(x = "Threshold Probability", y = "Net Benefit", color = "") +
  theme_bw()
