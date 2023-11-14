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
  
  df_cancer_dx = pd.read_csv('https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_cancer_dx.csv')
  
# ---- model ----- 
  
  mod1 = sm.GLM.from_formula('cancer ~ famhistory', data=df_cancer_dx, family=sm.families.Binomial())
  mod1_results = mod1.fit()
  
  print(mod1_results.summary())
  
# ---- dca_famhistory ----- 

  dca_famhistory_df = \
        dca(
            data=df_cancer_dx,
            outcome='cancer',
            modelnames=['famhistory']
        )

    plot_graphs(
        plot_df=dca_famhistory_df,
        graph_type='net_benefit',
        y_limits=[-0.05, 0.2]
    )

# ---- dca_famhistory2 ----- 

dca_famhistory2_df = \
        dca(
            data=df_cancer_dx,
            outcome='cancer',
            modelnames=['famhistory'],
            thresholds=np.arange(0, 0.36, 0.01),
        )

plot_graphs(
    plot_df=dca_famhistory2_df,
    graph_type='net_benefit',
    y_limits=[-0.05, 0.2]
)

# ---- model_multi ----- 

mod2 = sm.GLM.from_formula('cancer ~ marker + age + famhistory', data=df_cancer_dx, family=sm.families.Binomial())
mod2_results = mod2.fit()

print(mod2_results.summary())

# ---- dca_multi ----- 

# Following 3 Steps Coming Soon! 
# build multivariable logistic regression model
# summarize model
# add predicted values from model to data set

# Run dca on multivariable model
dca_multi_df = \
    dca(
        data=df_cancer_dx,
        outcome='cancer',
        modelnames=['famhistory', 'cancerpredmarker'],
        thresholds=np.arange(0,0.36,0.01)
    )

plot_graphs(
    plot_df=dca_multi_df,
    y_limits=[-0.05, 0.2],
    graph_type='net_benefit'
    )

# ---- dca_smooth ----- 

# Coming Soon!

# ---- dca_smooth2 ----- 

# Coming Soon!

# ---- pub_model ----- 

  df_cancer_dx['logodds_brown'] = 0.75 * df_cancer_dx['famhistory'] + 0.26*df_cancer_dx['age'] - 17.5
  df_cancer_dx['phat_brown'] = np.exp(df_cancer_dx['logodds_brown']) / (1 + np.exp(df_cancer_dx['logodds_brown']))
  
  dca_pub_model_df = \
      dca(
          data=df_cancer_dx,
          outcome='cancer',
          modelnames=['phat_brown'],
          thresholds=np.arange(0,0.36,0.01),
      )
  
  plot_graphs(
      plot_df=dca_pub_model_df,
      y_limits=[-0.05, 0.2],
      graph_type='net_benefit'
  )

# ---- joint ----- 

df_cancer_dx['high_risk'] = np.where(df_cancer_dx['risk_group'] == "high", 1, 0)

df_cancer_dx['joint'] = np.where((df_cancer_dx['risk_group'] == 'high') |
                                 (df_cancer_dx['cancerpredmarker'] > 0.15), 1, 0)

df_cancer_dx['conditional'] = np.where((df_cancer_dx['risk_group'] == "high") |
                                       ((df_cancer_dx['risk_group'] == "intermediate") &
                                        (df_cancer_dx['cancerpredmarker'] > 0.15)), 1, 0)

# ---- dca_joint ----- 

  dca_joint_df = \
      dca(
          data=df_cancer_dx,
          outcome='cancer',
          modelnames=['high_risk', 'joint', 'conditional'],
          thresholds=np.arange(0, 0.36, 0.01)
      )
  
  plot_graphs(
      plot_df=dca_joint_df,
      graph_type='net_benefit'
  )

# ---- dca_harm_simple ----- 

  dca_harm_simple_df = \
      dca(
          data=df_cancer_dx,
          outcome='cancer',
          modelnames=['marker'],
          thresholds=np.arange(0, 0.36, 0.01),
          harm={'marker': 0.0333},
          models_to_prob=['marker']
      )
  
  plot_graphs(
      plot_df=dca_harm_simple_df,
      graph_type='net_benefit'
  )

# ---- dca_harm ----- 

  harm_marker = 0.0333
  harm_conditional = (df_cancer_dx['risk_group'] == "intermediate").mean() * harm_marker
  
  dca_harm_df = \
      dca(
          data=df_cancer_dx,
          outcome='cancer',
          modelnames=['risk_group'],
          models_to_prob=['risk_group'],
          thresholds=np.arange(0, 0.36, 0.01),
          harm={'risk_group': harm_conditional}
      )
  
  plot_graphs(
      plot_df=dca_harm_df
  )

# ---- dca_table ----- 

  dca_table_df = \
      dca(
          data=df_cancer_dx,
          outcome='cancer',
          modelnames=['marker'],
          models_to_prob=['marker'],
          thresholds=np.arange(0.05, 0.36, 0.15)
      )
  
  print('\n', dca_table_df[['model', 'threshold', 'net_benefit']])

# ---- dca_intervention ----- 

  dca_intervention_df = \
      dca(
          data=df_cancer_dx,
          outcome='cancer',
          modelnames=['marker'],
          thresholds=np.arange(0.05, 0.36, 0.01),
          models_to_prob=['marker']
      )
  
  plot_graphs(
      plot_df=dca_intervention_df,
      graph_type='net_intervention_avoided'
  )
  
# ---- import_ttcancer ----- 

  df_time_to_cancer_dx = \
      pd.read_csv(
          "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_time_to_cancer_dx.csv"
      )
    
# ---- coxph ----- 

  cph = lifelines.CoxPHFitter()
  cph.fit(df=df_time_to_cancer_dx,
          duration_col='ttcancer',
          event_col='cancer',
          formula='age + famhistory + marker')
  
  cph_pred_vals = \
      cph.predict_survival_function(
          df_time_to_cancer_dx[['age',
                                'famhistory',
                                'marker']],
          times=[1.5])
  
  df_time_to_cancer_dx['pr_failure18'] = [1 - val for val in cph_pred_vals.iloc[0, :]]

# ---- stdca_coxph ----- 

  stdca_coxph_results = \
          dca(
              data=df_time_to_cancer_dx,
              outcome='cancer',
              modelnames=['pr_failure18'],
              thresholds=np.arange(0, 0.51, 0.01),
              time=1.5,
              time_to_outcome_col='ttcancer'
          )
  
  plot_graphs(
    plot_df=stdca_coxph_results,
    graph_type='net_benefit',
    y_limits=[-0.05, 0.25]
  )

# ---- stdca_cmprsk ----- 

# Coming Soon!

# ---- import_case_control ----- 

  df_case_control = \
    pd.read_csv(
                "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_cancer_dx_case_control.csv"
            )
 
  # Summarize Data With Column Medians
  medians = df_case_control.drop(columns='patientid').groupby(['casecontrol']).median()
  print('\n', medians.to_string())

# ---- dca_case_control ----- 

  dca_case_control_df = \
    dca(
      data=df_case_control,
      outcome='casecontrol',
      modelnames=['cancerpredmarker'],
      prevalence=0.20,
      thresholds=np.arange(0, 0.51, 0.01)
    )
  
  plot_graphs(
    plot_df=dca_case_control_df,
    graph_type='net_benefit',
    y_limits=[-0.05, 0.25]
  )

# ---- cross_validation ----- 

# Load dependencies for cross validation
import random
import pandas as pd
import numpy as np
from sklearn.model_selection import RepeatedKFold
from sklearn.metrics import log_loss
import statsmodels.api as sm
import dcurves

# Set seed for random processes
random.seed(112358)

# Load simulation data
df_cancer_dx = \
    pd.read_csv(
        "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_cancer_dx.csv"
    )

# Create a 10-fold cross validation set
cv = RepeatedKFold(n_splits=10, n_repeats=25, random_state=112358)

# Define the formula (make sure the column names in your DataFrame match these)
formula = 'cancer ~ marker + age + famhistory'

# Create cross-validation object
rkf = RepeatedKFold(n_splits=10, n_repeats=1, random_state=112358)

# Placeholder for predictions
cv_predictions = []

# Perform cross-validation
for train_index, test_index in rkf.split(df_cancer_dx):
    # Split data into training and test sets
    train, test = df_cancer_dx.iloc[train_index], df_cancer_dx.iloc[test_index]

    # Fit the model
    model = sm.Logit.from_formula(formula, data=train).fit(disp=0)

    # Make predictions on the test set
    test['cv_prediction'] = model.predict(test)

    # Store predictions
    cv_predictions.append(test[['patientid', 'cv_prediction']])

# Concatenate predictions from all folds
df_predictions = pd.concat(cv_predictions)

# Calculate mean prediction per patient
df_mean_predictions = df_predictions.groupby('patientid')['cv_prediction'].mean().reset_index()

# Join with original data
df_cv_pred = pd.merge(df_cancer_dx, df_mean_predictions, on='patientid', how='left')

# Decision curve analysis
# Generate net benefit score for each threshold value
df_dca_cv = dcurves.dca(
        data=df_cv_pred, modelnames=['cv_prediction'], outcome='cancer'
    )
# Plot DCA curves
dcurves.plot_graphs(plot_df=df_dca_cv, graph_type='net_benefit', y_limits=[-0.01, 0.15], color_names=['blue', 'red', 'green'])
