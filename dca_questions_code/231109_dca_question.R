# set seed for random process
set.seed(112358)

library(rsample)
library(broom)
library(dplyr)
library(pROC)
library(dcurves)
library(ggplot2)
library(readr)
library(purrr)
library(tidyr)

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

model_list <- list(
  cancer ~ age + risk_group + famhistory,
  cancer ~ marker + age,
  cancer ~ cancerpredmarker + age
)

output_crossvalidation_metrics <- function(data, formula, v = 10, repeats = 25, dca_thresholds = seq(0, 0.35, 0.01)){
  
  cross_validation_samples <- rsample::vfold_cv(df_cancer_dx, v = v, repeats = repeats)
  
  df_crossval_predictions <- 
    cross_validation_samples %>% 
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
    pull(df_assessment) %>%
    bind_rows() %>%
    group_by(patientid) %>%
    summarise(cv_pred = mean(.fitted), .groups = "drop") %>%
    ungroup()
  
  df_cv_pred <-
    df_cancer_dx %>% 
    left_join(
      df_crossval_predictions,
      by = 'patientid'
    )
  
  # Calculate the ROC object
  roc_obj <- roc(response = df_cv_pred$cancer, predictor = df_cv_pred$cv_pred)
  
  # Extract the ROC curve coordinates
  roc_coords <- 
    coords(roc_obj, "all", ret = c("threshold", "sensitivity", "specificity"), transpose = FALSE) %>% 
    mutate(
      x = 1 - specificity,
      y = sensitivity
    )
  
  roc_curve_objects =
    list(
      'auc_score' = roc_obj,
      'roc_coords' = roc_coords
    )
  
  dca_results <- dca(df_cv_pred,
                     formula = cancer ~ cv_pred,
                     thresholds = dca_thresholds)$dca
  
  cv_metrics <-
    list(
      'pred_df' = df_cv_pred,
      'roc_objects' = roc_curve_objects,
      'dca_results' = dca_results
      
    )
  
  return(cv_metrics)
}

metrics_per_model <- purrr::map(model_list, ~ output_crossvalidation_metrics(data = df_cancer_dx, formula = .x))


df_cancer_dx_cv <-
  df_cancer_dx |> 
  mutate(
    cv_pred_1 = 
      metrics_per_model[[1]]$pred_df$cv_pred,
    cv_pred_2 = 
      metrics_per_model[[2]]$pred_df$cv_pred,
    cv_pred_3 = 
      metrics_per_model[[3]]$pred_df$cv_pred
  )

dca(
  formula = cancer ~ cv_pred_1 + cv_pred_2 + cv_pred_3,
  data = df_cancer_dx_cv
)


plot_dca <- function(dca_dataframe){
  
  dca_dataframe %>%
    ggplot(aes(x = threshold, y = net_benefit, color = label)) +
    stat_smooth(method = "loess", se = FALSE, formula = "y ~ x", span = 0.2) +
    coord_cartesian(ylim = c(-0.014, 0.14)) +
    scale_x_continuous(labels = scales::percent_format(accuracy = 1)) +
    labs(x = "Threshold Probability", y = "Net Benefit", color = "") +
    theme_bw()
  
}

plot_roc <- function(roc_obj){
  # Extract the ROC curve coordinates
  roc_coords <- 
    coords(roc_obj, "all", ret = c("threshold", "sensitivity", "specificity"), transpose = FALSE) %>% 
    mutate(
      x = 1 - specificity,
      y = sensitivity
    )
  
  # Plot the ROC curve
  roc_plot <- ggplot(data = roc_coords, aes(x = x, y = y)) +
    geom_line(color = 'blue') +
    geom_abline(linetype = 'dashed') +
    labs(x = '1 - Specificity', y = 'Sensitivity', title = 'ROC Curve') +
    theme_minimal()
  
  # Optionally: Add AUC to the plot
  auc_value <- auc(roc_obj)
  auc_text <- paste0("AUC = ", round(auc_value, 2))
  roc_plot <- roc_plot + annotate("text", x = .2, y = .8, label = auc_text, color = 'red')
  
  return(roc_plot)
}

dca_plots <- purrr::map(metrics_per_model, ~ plot_dca(dca_dataframe = .x$dca_results))

roc_plots <- purrr::map(metrics_per_model, ~ plot_roc(roc_obj = .x$roc_objects$auc_score))


##### DO ABOVE BUT JUST FOR A SINGLE MODEL (FOR DCA TUTORIAL)

# set seed for random process
set.seed(112358)

formula = cancer ~ marker + age + famhistory
dca_thresholds = seq(0,0.36, 0.01)

cross_validation_samples <- rsample::vfold_cv(df_cancer_dx, v = 10, repeats = 1)

df_crossval_predictions <- 
  cross_validation_samples %>% 
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

dca(
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

