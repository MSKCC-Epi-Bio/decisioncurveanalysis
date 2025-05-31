# ---- install ----- 

# install dcurves to perform DCA (first install package via pip)
# pip install dcurves
from dcurves import dca, plot_graphs

# install other packages used in this tutorial
# pip install pandas numpy statsmodels lifelines
import pandas as pd
import numpy as np
import statsmodels.api as sm
import lifelines

# ---- import_cancer ----- 

# No table for this chunk
df_cancer_dx = pd.read_csv(
    "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_cancer_dx.csv"
)

# ---- model ----- 

mod1 = sm.GLM.from_formula(
    "cancer ~ famhistory", data=df_cancer_dx, family=sm.families.Binomial()
)
mod1_results = mod1.fit()

print(mod1_results.summary())

# ---- dca_famhistory ----- 

dca_famhistory_df = dca(data=df_cancer_dx, outcome="cancer", modelnames=["famhistory"])

plot_graphs(plot_df=dca_famhistory_df, graph_type="net_benefit", y_limits=[-0.05, 0.2])

# ---- dca_famhistory2 ----- 

dca_famhistory2_df = dca(
    data=df_cancer_dx,
    outcome="cancer",
    modelnames=["famhistory"],
    thresholds=np.arange(0, 0.36, 0.01),
)

plot_graphs(plot_df=dca_famhistory2_df, graph_type="net_benefit", y_limits=[-0.05, 0.2])

# ---- model_multi ----- 

mod2 = sm.GLM.from_formula(
    "cancer ~ marker + age + famhistory",
    data=df_cancer_dx,
    family=sm.families.Binomial(),
)
mod2_results = mod2.fit()

print(mod2_results.summary())

df_cancer_dx["cancerpredmarker"] = mod2_results.predict(df_cancer_dx)

# ---- dca_multi ----- 

# Run dca on multivariable model
dca_multi_df = dca(
    data=df_cancer_dx,
    outcome="cancer",
    modelnames=["famhistory", "cancerpredmarker"],
    thresholds=np.arange(0, 0.36, 0.01),
)

plot_graphs(plot_df=dca_multi_df, y_limits=[-0.05, 0.2], graph_type="net_benefit")

# ---- dca_formatting ----- 

dca_formatting_df = dca(
    data=df_cancer_dx,
    outcome="cancer",
    modelnames=["cancerpredmarker"],
    thresholds=np.arange(0, 0.26, 0.01),
)

plot_graphs(
    plot_df=dca_formatting_df,
    graph_type="net_benefit",
    y_limits=[-0.05, 0.15],
    color_names=["blue", "red", "green"],
    linestyles=["--", "-", "--"],
    linewidths=[0.75, 3, 2],
)

# ---- dca_legend_off ----- 

# Turn off the legend for a cleaner publication-ready figure
dca_legend_off_df = dca(
    data=df_cancer_dx,
    outcome="cancer",
    modelnames=["cancerpredmarker"],
    thresholds=np.arange(0, 0.26, 0.01),
)

plot_graphs(
    plot_df=dca_legend_off_df,
    graph_type="net_benefit",
    y_limits=[-0.05, 0.15],
    color_names=["blue", "red", "green"],
    linestyles=["--", "-", "--"],
    linewidths=[0.75, 3, 2],
    show_legend=False,
)

# ---- dca_create_low_incidence ----- 

np.random.seed(123)

df_cancer_dx_low = df_cancer_dx.copy()
u = np.random.rand(len(df_cancer_dx_low))

# copy → cancer_temp, then blank out 90 % of cancers
df_cancer_dx_low["cancer_temp"] = df_cancer_dx_low["cancer"]
mask_na = (df_cancer_dx_low["cancer"] == 1) & (u < 0.9)
df_cancer_dx_low.loc[mask_na, "cancer_temp"] = np.nan

# drop rows missing in *either* outcome or predictor
df_for_dca = df_cancer_dx_low.dropna(subset=["cancer_temp", "cancerpredmarker"])

dca_low_incidence_df = dca(
    data=df_for_dca,
    outcome="cancer_temp",
    modelnames=["cancerpredmarker"],
    thresholds=np.arange(0, 0.26, 0.01),
)

plot_graphs(
    plot_df=dca_low_incidence_df,
    graph_type="net_benefit",
    color_names=["blue", "red", "green"],
)

# ---- dca_adjust_axes ----- 

dca_low_incidence_small = dca(
    data=df_for_dca,
    outcome="cancer_temp",
    modelnames=["cancerpredmarker"],
    thresholds=np.arange(0, 0.05, 0.01),
)

plot_graphs(
    plot_df=dca_low_incidence_small,
    graph_type="net_benefit",
    y_limits=[-0.005, 0.0225],
    color_names=["blue", "red", "green"],
)

# ---- dca_smooth ----- 


plot_graphs(
    plot_df=dca_multi_df,
    y_limits=[-0.025, 0.15],
    graph_type="net_benefit",
    smooth_frac=0.5,  # Set the smoothing fraction to 0.5
)

# ---- dca_smooth2 ----- 

dca_smooth2_df = dca(
    data=df_cancer_dx,
    outcome="cancer",
    modelnames=["cancerpredmarker", "famhistory", "risk_group"],
    thresholds=np.arange(0, 0.36, 0.05),
    models_to_prob=["risk_group"],  # Specify risk_group is not a probability
)

plot_graphs(
    plot_df=dca_smooth2_df,
    graph_type="net_benefit",
    smooth_frac=0,
    y_limits=[-0.025, 0.15],
)

# ---- pub_model ----- 

df_cancer_dx["logodds_brown"] = (
    0.75 * df_cancer_dx["famhistory"] + 0.26 * df_cancer_dx["age"] - 17.5
)
df_cancer_dx["phat_brown"] = np.exp(df_cancer_dx["logodds_brown"]) / (
    1 + np.exp(df_cancer_dx["logodds_brown"])
)

dca_pub_model_df = dca(
    data=df_cancer_dx,
    outcome="cancer",
    modelnames=["phat_brown"],
    thresholds=np.arange(0, 0.36, 0.01),
)

plot_graphs(
    plot_df=dca_pub_model_df,
    y_limits=[-0.05, 0.15],
    graph_type="net_benefit",
    smooth_frac=0.5,
    color_names=["blue", "red", "green"],
)

# ---- joint ----- 

df_cancer_dx["high_risk"] = np.where(df_cancer_dx["risk_group"] == "high", 1, 0)

df_cancer_dx["joint"] = np.where(
    (df_cancer_dx["risk_group"] == "high") | (df_cancer_dx["cancerpredmarker"] > 0.15),
    1,
    0,
)

df_cancer_dx["conditional"] = np.where(
    (df_cancer_dx["risk_group"] == "high")
    | (
        (df_cancer_dx["risk_group"] == "intermediate")
        & (df_cancer_dx["cancerpredmarker"] > 0.15)
    ),
    1,
    0,
)

# ---- dca_joint ----- 

dca_joint_df = dca(
    data=df_cancer_dx,
    outcome="cancer",
    modelnames=["high_risk", "joint", "conditional"],
    thresholds=np.arange(0, 0.36, 0.01),
)

plot_graphs(
    plot_df=dca_joint_df,
    graph_type="net_benefit",
    y_limits=[-0.05, 0.15],
    color_names=["green", "cyan", "violet", "red", "gold"],
)

# ---- dca_table ----- 

dca_table_df = dca(
    data=df_cancer_dx,
    outcome="cancer",
    modelnames=["marker"],
    models_to_prob=["marker"],
    thresholds=np.arange(0.05, 0.36, 0.15),
)

print("\n", dca_table_df[["model", "threshold", "net_benefit"]])

# ---- dca_intervention ----- 

dca_intervention_df = dca(
    data=df_cancer_dx,
    outcome="cancer",
    modelnames=["marker"],
    thresholds=np.arange(0.05, 0.36, 0.01),
    models_to_prob=["marker"],
)

plot_graphs(
    plot_df=dca_intervention_df,
    graph_type="net_intervention_avoided",
    smooth_frac=0.2,
    color_names=["blue", "red", "green"],
)

# ---- import_ttcancer ----- 

df_time_to_cancer_dx = pd.read_csv(
    "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_time_to_cancer_dx.csv"
)

# ---- coxph ----- 

cph = lifelines.CoxPHFitter()
cph.fit(
    df=df_time_to_cancer_dx,
    duration_col="ttcancer",
    event_col="cancer",
    formula="age + famhistory + marker",
)

cph_pred_vals = cph.predict_survival_function(
    df_time_to_cancer_dx[["age", "famhistory", "marker"]], times=[1.5]
)

df_time_to_cancer_dx["pr_failure18"] = [1 - val for val in cph_pred_vals.iloc[0, :]]

# ---- stdca_coxph ----- 

stdca_coxph_results = dca(
    data=df_time_to_cancer_dx,
    outcome="cancer",
    modelnames=["pr_failure18"],
    thresholds=np.arange(0, 0.51, 0.01),
    time=1.5,
    time_to_outcome_col="ttcancer",
)

plot_graphs(
    plot_df=stdca_coxph_results,
    graph_type="net_benefit",
    y_limits=[-0.05, 0.25],
    smooth_frac=0.5,
    color_names=["blue", "red", "green"],
)

# ---- stdca_cmprsk ----- 

# Python library doesn't support competing risks

# ---- import_case_control ----- 

df_case_control = pd.read_csv(
    "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_cancer_dx_case_control.csv"
)

# Summarize Data With Column Medians
# drop 'patientid', then group and take medians of numeric columns only
medians = (
    df_case_control.drop(columns="patientid")
    .groupby("casecontrol")
    .median(numeric_only=True)
)
print(medians)

# ---- dca_case_control ----- 

dca_case_control_df = dca(
    data=df_case_control,
    outcome="casecontrol",
    modelnames=["cancerpredmarker"],
    prevalence=0.20,
    thresholds=np.arange(0, 0.51, 0.01),
)

plot_graphs(
    plot_df=dca_case_control_df,
    graph_type="net_benefit",
    y_limits=[-0.05, 0.25],
    smooth_frac=0.1,
)

# ---- dca_harm_simple ----- 

dca_harm_simple_df = dca(
    data=df_cancer_dx,
    outcome="cancer",
    modelnames=["marker"],
    thresholds=np.arange(0, 0.36, 0.01),
    harm={"marker": 0.0333},
    models_to_prob=["marker"],
)

plot_graphs(
    plot_df=dca_harm_simple_df,
    graph_type="net_benefit",
    y_limits=[-0.05, 0.15],
    color_names=["blue", "red", "green"],
    smooth_frac=0.2,
)

# ---- dca_harm ----- 

harm_marker = 0.0333
harm_conditional = (df_cancer_dx["risk_group"] == "intermediate").mean() * harm_marker

dca_harm_df = dca(
    data=df_cancer_dx,
    outcome="cancer",
    modelnames=["risk_group"],
    models_to_prob=["risk_group"],
    thresholds=np.arange(0, 0.36, 0.01),
    harm={"risk_group": harm_conditional},
)

plot_graphs(plot_df=dca_harm_df)

# ---- cross_validation ----- 

# Load dependencies for cross validation
import random  # Library to generate random seed
from sklearn.model_selection import (
    RepeatedKFold,
)  # Cross validation data selection and segregation function

# Set seed for random processes
random.seed(112358)

# Load simulation data
df_cancer_dx = pd.read_csv(
    "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_cancer_dx.csv"
)

# Define the formula (make sure the column names in your DataFrame match these)
formula = "cancer ~ marker + age + famhistory"

# Create cross-validation object
rkf = RepeatedKFold(n_splits=10, n_repeats=1, random_state=112358)

# Placeholder for predictions
cv_predictions = []

# Perform cross-validation
for train_index, test_index in rkf.split(df_cancer_dx):
    # Split data into training and test sets
    train = df_cancer_dx.iloc[train_index]
    test = df_cancer_dx.iloc[test_index].copy()  # ← make an explicit copy

    # Fit the model
    model = sm.Logit.from_formula(formula, data=train).fit(disp=0)

    # Make predictions on the test set
    test["cv_prediction"] = model.predict(test)

    # Store predictions
    cv_predictions.append(test[["patientid", "cv_prediction"]])

# Concatenate predictions from all folds
df_predictions = pd.concat(cv_predictions)

# Calculate mean prediction per patient
df_mean_predictions = (
    df_predictions.groupby("patientid")["cv_prediction"].mean().reset_index()
)

# Join with original data
df_cv_pred = pd.merge(df_cancer_dx, df_mean_predictions, on="patientid", how="left")

# Decision curve analysis
df_dca_cv = dca(
    data=df_cv_pred,
    modelnames=["cv_prediction"],
    outcome="cancer",
    thresholds=np.arange(0, 0.36, 0.01),
)

# Plot DCA curves
plot_graphs(
    plot_df=df_dca_cv,
    graph_type="net_benefit",
    y_limits=[-0.01, 0.15],
    color_names=["blue", "red", "green"],
    smooth_frac=0.5,
)
