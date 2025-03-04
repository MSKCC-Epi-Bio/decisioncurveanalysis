## ---- sas-install -----
/* source the dca macros from GitHub.com */
/* you can also navigate to GitHub.com and save the macros locally */
FILENAME dca URL "https://raw.githubusercontent.com/ddsjoberg/dca.sas/main/dca.sas";
FILENAME stdca URL "https://raw.githubusercontent.com/ddsjoberg/dca.sas/main/stdca.sas";
%INCLUDE dca;
%INCLUDE stdca;

## ---- sas-import_cancer -----
FILENAME cancer URL "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_cancer_dx.csv";

PROC IMPORT FILE = cancer OUT = work.data_cancer DBMS = CSV;
RUN;

* assign variable labels. these labels will be carried through in the DCA output;
DATA data_cancer;
  SET data_cancer;

  LABEL patientid = "Patient ID"
        cancer = "Cancer Diagnosis"
        risk_group = "Risk Group"
        age = "Patient Age"
        famhistory = "Family History"
        marker = "Marker"
        cancerpredmarker = "Prediction Model";
RUN;

## ---- sas-model -----
* Test whether family history is associated with cancer;
PROC LOGISTIC DATA = data_cancer DESCENDING;
  MODEL cancer = famhistory;
RUN;

## ---- sas-dca_famhistory -----
* Run the decision curve: family history is coded as 0 or 1, i.e. a probability, so no need to specify the “probability” option;
%DCA(data = data_cancer, outcome = cancer, predictors = famhistory, graph = yes);

## ---- sas-dca_famhistory2 -----
%DCA(data = data_cancer, outcome = cancer, predictors = famhistory, graph = yes, xstop = 0.35);

## ---- sas-model_multi -----
* run the multivariable model;
PROC LOGISTIC DATA = data_cancer DESCENDING;
  MODEL cancer = marker age famhistory;
  * save out predictions in the form of probabilities;
  SCORE CLM OUT=dca (RENAME=(P_1 = cancerpredmarker));
RUN;

## ---- sas-dca_multi -----
%DCA(data = data_cancer, outcome = cancer, predictors = cancerpredmarker famhistory, graph = yes, xstop = 0.35);

## ---- sas-dca_smooth -----
%DCA(data = data_cancer, outcome = cancer, predictors = cancerpredmarker famhistory, graph = yes, xstop = 0.35, smooth=yes);

## ---- sas-dca_smooth2 -----
%DCA(data = data_cancer, outcome = cancer, predictors = cancerpredmarker famhistory, graph = yes, xstop = 0.35, xby=0.05, smooth=no);

## ---- sas-pub_model -----
DATA data_cancer;
  SET data_cancer;
  * use the coefficients from the Brown model;
  logodds_Brown = 0.75 * (famhistory) + 0.26 * (age) - 17.5;
  * convert to predicted probability;
  phat_Brown = exp(logodds_Brown) / (1 + exp(logodds_Brown));
RUN;

* run the decision curve;
%DCA(data = data_cancer, outcome = cancer, predictors = phat_Brown, xstop = 0.35);

## ---- sas-joint -----
* Create a variable for the strategy of treating only high risk patients;
* This will be 1 for treat and 0 for don't treat;
DATA data_cancer;
  SET data_cancer;

  high_risk = (risk_group = "high");
  LABEL high_risk="Treat Only High Risk Group";

  * Treat based on joint approach;
  joint = (risk_group="high") | (cancerpredmarker > 0.15);
  LABEL joint = "Treat via Joint Approach";

  * Treat based on conditional approach;
  conditional = (risk_group = "high") | (risk_group = "intermediate" & cancerpredmarker > 0.15);
  LABEL conditional = "Treat via Conditional Approach";
RUN;

## ---- sas-dca_joint -----
%DCA(data = data_cancer, outcome = cancer,
     predictors = high_risk joint conditional,
     graph = yes, xstop = 0.35);

## ---- sas-dca_harm_simple -----
%DCA(data = data_cancer, outcome = cancer,
     predictors = risk_group,
     probability=no,
     harm = 0.0333,
     graph = yes, xstop = 0.35);

## ---- sas-dca_harm -----
* the harm of measuring the marker is stored as a macro variable;
%LET harm_marker = 0.0333;

*in the conditional test, only patients at intermediate risk have their marker measured;
DATA data_cancer;
  SET data_cancer;
  intermediate_risk = (risk_group = "intermediate");
RUN;

* calculate the proportion of patients who have the marker and save out mean risk;
PROC MEANS DATA = data_cancer;
 VAR intermediate_risk;
 OUTPUT OUT = meanrisk MEAN = meanrisk;
RUN;

DATA _NULL_;
  SET meanrisk;
  CALL SYMPUT("meanrisk", meanrisk);
RUN;

* harm of the conditional approach is proportion of patients who have the marker measured multiplied by the harm;
%LET harm_conditional = %SYSEVALF(&meanrisk.*&harm_marker.);

* Run the decision curve;
%DCA(data = data_cancer, outcome = cancer, predictors = high_risk,
     probability=no,
     harm = &harm_conditional., xstop = 0.35);

## ---- sas-dca_table -----
* Run the decision curve and save out net benefit results, specify xby=0.05 since we want 5% increments;
%DCA(data = data_cancer, outcome = cancer, predictors = marker,
     probability = no, xstart = 0.05,
     xstop = 0.35, xby = 0.05, graph = no, out = dcamarker);

* Load the data set with the net benefit results;
DATA dcamarker;
  SET dcamarker;
  * Calculate difference between marker and treat all;
  * Our standard approach is to biopsy everyone so this tells us how much better we do with the marker;
  advantage = marker - all;
RUN;

## ---- sas-dca_intervention -----
%DCA(data = data_cancer, outcome = cancer, predictors = marker, probability = no,
     intervention = yes, xstart = 0.05, xstop = 0.35);

## ---- sas-import_ttcancer -----
FILENAME ttcancer URL "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_time_to_cancer_dx.csv";

PROC IMPORT FILE = ttcancer OUT = work.data_ttcancer DBMS = CSV;
RUN;

DATA data_ttcancer;
  SET data_ttcancer;

  LABEL patientid = "Patient ID"
        cancer = "Cancer Diagnosis"
        ttcancer = "Years to Diagnosis/Censor"
        risk_group = "Risk Group"
        age = "Patient Age"
        famhistory = "Family History"
        marker = "Marker"
        cancerpredmarker = "Prediction Model"
        cancer_cr = "Cancer Diagnosis Status";

RUN;

## ---- sas-coxph -----
* Run the Cox model;
PROC PHREG DATA=data_ttcancer;
  MODEL ttcancer*cancer(0) = age famhistory marker;
  BASELINE OUT=baseline COVARIATES=data_ttcancer SURVIVAL=surv_func / NOMEAN METHOD=pl;
RUN;

* the probability of failure at 1.5 years is calculated by subtracting the probability of survival from 1;
PROC SQL NOPRINT UNDO_POLICY=none;
  CREATE TABLE base_surv2 AS
  SELECT DISTINCT
  patientid, age, famhistory, marker, 1-min(surv_func) AS pr_failure18
  FROM baseline (WHERE=(ttcancer<=1.5))
  GROUP BY patientid, age, famhistory, marker
  ;

  * merge survival estimates with original data;
  CREATE TABLE data_ttcancer AS
  SELECT A.*, B.pr_failure18
  FROM data_ttcancer A
  LEFT JOIN base_surv2 B
    ON (A.patientid=B.patientid) and (A.age=B.age) and
    (A.famhistory=B.famhistory) and (A.marker=B.marker);
  ;
QUIT;

DATA data_ttcancer;
  SET data_ttcancer;
  LABEL pr_failure18 = "Probability of Failure at 18 months";
RUN;

## ---- sas-stdca_coxph -----
%STDCA(data = data_ttcancer, out = survivalmult,
       outcome = cancer, ttoutcome = ttcancer,
       timepoint = 1.5, predictors = pr_failure18, xstop = 0.5);

## ---- sas-stdca_cmprsk -----
* Define the competing events status variable;
DATA data_ttcancer;
  SET data_ttcancer;
  status = 0;
  IF cancer_cr = "diagnosed with cancer" THEN status=1;
  ELSE IF cancer_cr = "dead other causes" THEN status=2;
RUN;

* Run the decision curve specifying the competing risk option;
%STDCA(data = data_ttcancer, outcome = status,
       ttoutcome = ttcancer, timepoint = 1.5,
       predictors = pr_failure18, competerisk = yes, xstop = 0.5);

## ---- sas-import_case_control -----
FILENAME case_con URL "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_cancer_dx_case_control.csv";

PROC IMPORT FILE = case_con OUT = work.data_case_control DBMS = CSV;
RUN;

DATA data_case_control;
  SET data_case_control;

  LABEL patientid = "Patient ID"
        casecontrol = "Case-Control Status"
        risk_group = "Risk Group"
        age = "Patient Age"
        famhistory = "Family History"
        marker = "Marker"
        cancerpredmarker = "Probability of Cancer Diagnosis";
RUN;

## ---- sas-dca_case_control -----
%DCA(data = data_case_control, outcome = casecontrol,
     predictors = cancerpredmarker, prevalence = 0.20);

## ---- sas-cross_validation -----
%MACRO CROSSVAL(data=,             /*Name of input dataset*/
                out=,              /*Name of output dataset containing calculated net benefit*/
                outcome=,          /*outcome variable, 1=event, 0=nonevent*/
                predictors=,       /*Covariates in the model*/
                v = 10,            /*number of folds in the cross validation*/
                repeats = 200,     /*Number of repeated cross validations that will be run*/
                /*arguments passed to %DCA() */
                xstart=0.01, xstop=0.99, xby=0.01, harm=);

  %DO x = 1 %TO &repeats.;
    *Load original data and create a variable to be used to 'randomize' patients;
    DATA CROSSVAL_dca_of;
      SET &data.;
      u = RAND("Uniform");
    RUN;

    *Sort by the event to ensure equal number of patients with the event are in each group;
    PROC SORT DATA = CROSSVAL_dca_of;
      BY &outcome. u;
    RUN;

    *Assign each patient into one of ten groups;
    DATA CROSSVAL_dca_of;
      SET CROSSVAL_dca_of;
      group = MOD(_n_, &v.) + 1;
    RUN;

    *Loop through to run through for each of the ten groups;
    %DO y = 1 %TO &v.;
      * First, fit the model excluding the yth group.;
      PROC LOGISTIC DATA = CROSSVAL_dca_of OUTMODEL = CROSSVAL_df_model&y. DESCENDING NOPRINT;
        MODEL &outcome. = &predictors.;
        WHERE group ne &y.;
      RUN;

      *Put yth group into base test dataset;
      DATA CROSSVAL_df_test&y.;
        SET CROSSVAL_dca_of;
        WHERE group = &y.;
      RUN;

       *Apply the model to the yth group and save the predicted probabilities of the yth group (that was not used in creating the model);
      PROC LOGISTIC INMODEL=CROSSVAL_df_model&y. NOPRINT;
        SCORE DATA = CROSSVAL_df_test&y. OUT = CROSSVAL_model_pr&y.;
      RUN;
    %END;

    * Combine model predictions for all 10 groups;
    DATA CROSSVAL_model_pr(RENAME = (P_1=model_pred));
      SET CROSSVAL_model_pr1-CROSSVAL_model_pr&v.;
    RUN;

    * Run decision curve and save out results;
    * For those excluding the optional multiple cross validation, this decision curve (to be seen by using "graph=yes") and the results (saved under the name of your choosing) would be the decision curve corrected for overfit;
    %DCA(data=CROSSVAL_model_pr, out=CROSSVAL_dca&x., outcome=&outcome., predictors=model_pred,
         graph=no, xstart=&xstart., xstop=&xstop., xby=&xby., harm=&harm.);

  *This "%END" statement ends the initial loop for the multiple cross validation. It is also necessary for those who avoided the multiple cross validation by changing the value in the DO loop from 200 to 1;
  %END;

  DATA CROSSVAL_allcv_pr;
    SET CROSSVAL_dca1-CROSSVAL_dca&repeats.;
  RUN;

  * Calculate the average net benefit across all iterations of the multiple cross validation;
  PROC MEANS DATA=CROSSVAL_allcv_pr NOPRINT;
    CLASS threshold;
    VAR all none model_pred;
    OUTPUT OUT=CROSSVAL_minfinal MEAN=all none model_pred;
  RUN;

  * Save out average net benefit and label variables so that the plot legend will have the proper labels.;
  DATA &out. (KEEP=model_pred all none threshold);
    SET CROSSVAL_minfinal;
    LABEL all="Treat All";
    LABEL none="Treat None";
    LABEL model_pred="Cross-validated Prediction Model";
  RUN;

  PROC DATASETS LIB=WORK;
	DELETE CROSSVAL_:;
  RUN;
  QUIT;
%MEND CROSSVAL;

* Run the crossvalidation macro;
%CROSSVAL(data = data_cancer,
          out = allcv_pr,
          outcome = cancer,
          predictors= age famhistory marker,
          xstop = 0.5);

* Plotting the figure of all the net benefits;
PROC GPLOT DATA=allcv_pr;
  axis1 ORDER=(-0.05 to 0.15 by 0.05) LABEL=(ANGLE=90 "Net Benefit") MINOR=none;
  axis2 ORDER=(0 to 0.5 by 0.1) LABEL=("Threshold Probability") MINOR=none;
  legend LABEL=NONE ACROSS=1 CBORDER=BLACK;
  PLOT all*threshold
  none*threshold
  model_pred*threshold /
  VAXIS=axis1
  HAXIS=axis2
  LEGEND=legend OVERLAY;
  SYMBOL INTERPOL=JOIN;
RUN;
QUIT;
