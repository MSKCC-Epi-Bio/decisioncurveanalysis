/* ---- install ----- */
* install dca functions from GitHub.com
net install dca, from("https://raw.github.com/ddsjoberg/dca.stata/master/") replace

/* ---- import_cancer ----- */
* import data
import delimited "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_cancer_dx.csv", clear

* assign variable labels. these labels will be carried through in the DCA output
label variable patientid "Patient ID"
label variable cancer "Cancer Diagnosis"
label variable risk_group "Risk Group"
label variable age "Patient Age"
label variable famhistory "Family History"
label variable marker "Marker"
label variable cancerpredmarker "Prediction Model"

/* ---- model ----- */
* Test whether family history is associated with cancer
logit cancer famhistory

/* ---- dca_famhistory ----- */
* Run the decision curve: family history is coded as 0 or 1, i.e. a probability
* so no need to specify the “probability” option
dca cancer famhistory

/* ---- dca_famhistory2 ----- */
dca cancer famhistory, xstop(0.35) xlabel(0(0.05)0.35)

/* ---- model_multi ----- */
* run the multivariable model
logit cancer marker age famhistory

* save out predictions in the form of probabilities
capture drop cancerpredmarker
predict cancerpredmarker

/* ---- dca_multi ----- */
dca cancer cancerpredmarker famhistory, xstop(0.35) xlabel(0(0.01)0.35)

/* ---- dca_smooth ----- */
dca cancer cancerpredmarker famhistory, xstop(0.35) xlabel(0(0.01)0.35) smooth

/* ---- dca_smooth2 ----- */
dca cancer cancerpredmarker famhistory, xstop(0.35) xlabel(0(0.05)0.35)

/* ---- pub_model ----- */
* Use the coefficients from the Brown model
g logodds_Brown = 0.75*(famhistory) + 0.26*(age) - 17.5

* Convert to predicted probability
g phat_Brown = invlogit(logodds_Brown)
label var phat_Brown "Risk from Brown Model"

* Run the decision curve
dca cancer phat_Brown, xstop(0.35) xlabel(0(0.05)0.35)

/* ---- joint ----- */
* Create a variable for the strategy of treating only high risk patients
* This will be 1 for treat and 0 for don’t treat
g high_risk = risk_group=="high"
label var high_risk "Treat Only High Risk Group"

* Treat based on Joint Approach
g joint = risk_group =="high" | cancerpredmarker > 0.15
label var joint "Treat via Joint Approach"

* Treat based on Conditional Approach
g conditional = risk_group=="high" | ///
  (risk_group == "intermediate" & cancerpredmarker > 0.15)
label var conditional "Treat via Conditional Approach"

/* ---- dca_joint ----- */
dca cancer high_risk joint conditional, xstop(0.35) xlabel(0(0.05)0.35)

/* ---- dca_harm_simple ----- */
dca cancer high_risk, probability(no) harm(0.0333) xstop(0.35) xlabel(0(0.05)0.35)

/* ---- dca_harm ----- */
* the harm of measuring the marker is stored in a local
local harm_marker = 0.0333
* in the conditional test, only patients at intermediate risk have their marker measured
g intermediate_risk = (risk_group=="intermediate")

* harm of the conditional approach is proportion of patients who have the marker measured multiplied by the harm
sum intermediate_risk
local harm_conditional = r(mean)*`harm_marker'

* Run the decision curve
dca cancer high_risk joint conditional, ///
 probability(no) harm(`harm_conditional') xstop(0.35) xlabel(0(0.05)0.35)

/* ---- dca_table ----- */
* Run the decision curve and save out net benefit results
* Specifying xby(.05) since we’d want 5% increments
dca cancer marker, prob(no) xstart(0.05) xstop(0.35) xby(0.05) nograph ///
 saving("DCA Output marker.dta", replace)

* Load the data set with the net benefit results
use "DCA Output marker.dta", clear

* Calculate difference between marker and treat all
* Our standard approach is to biopsy everyone so this tells us
* how much better we do with the marker
g advantage = marker - all
label var advantage "Increase in net benefit from using Marker model"

/* ---- dca_intervention ----- */
* import data
import delimited "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_cancer_dx.csv", clear
label variable marker "Marker"

* net interventions avoided
dca cancer marker, prob(no) intervention xstart(0.05) xstop(0.35)

/* ---- import_ttcancer ----- */
* import data
import delimited "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_time_to_cancer_dx.csv", clear

* assign variable labels. these labels will be carried through in the DCA output
label variable patientid "Patient ID"
label variable cancer "Cancer Diagnosis"
label variable ttcancer "Years to Diagnosis/Censor"
label variable risk_group "Risk Group"
label variable age "Patient Age"
label variable famhistory "Family History"
label variable marker "Marker"
label variable cancerpredmarker "Prediction Model"
label variable cancer_cr "Cancer Diagnosis Status"

* Declaring survival time data: follow-up time variable is ttcancer and the event is cancer
stset ttcancer, f(cancer)

/* ---- coxph ----- */
* Run the cox model and save out baseline survival in the “surv_func” variable
stcox age famhistory marker, basesurv(surv_func)

* get linear predictor for calculation of risk
predict xb, xb

* Obtain baseline survival at 1.5 years = 18 months
sum surv_func if _t <= 1.5

* We want the survival closest to 1.5 years
* This will be the lowest survival rate for all survival times ≤1.5
local base = r(min)

* Convert to a probability
g pr_failure18 = 1 - `base'^exp(xb)
label var pr_failure18 "Probability of Failure at 18 months"

/* ---- stdca_coxph ----- */
stdca pr_failure18, timepoint(1.5) xstop(0.5) smooth

/* ---- stdca_cmprsk ----- */
* Define the competing events status variable
g status = 0 if cancer_cr == "censor"
	replace status = 1 if cancer_cr == "dead other causes"
	replace status = 2 if cancer_cr == "diagnosed with cancer"

* We declare our survival data with the new event variable
stset ttcancer, f(status=1)

* Run the decision curve specifying the competing risk option
stdca pr_failure18, timepoint(1.5) compet1(2) smooth xstop(.5)

/* ---- import_case_control ----- */
* import data
import delimited "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_cancer_dx_case_control.csv", clear

label variable patientid "Patient ID"
label variable casecontrol "Case-Control Status"
label variable risk_group "Risk Group"
label variable age "Patient Age"
label variable famhistory "Family History"
label variable marker "Marker"
label variable cancerpredmarker "Probability of Cancer Diagnosis"

/* ---- dca_case_control ----- */
dca casecontrol cancerpredmarker, prevalence(0.20) xstop(0.50)

/* ---- cross_validation ----- */
* Load Original Dataset
import delimited "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_cancer_dx.csv", clear

* To skip this optional loop used for running the cross validation multiple times
* either 1) change it to “forvalues i=1(1)1 {” or
* 2) omit this line of code and take care to change any code which references “i”
forvalues i=1(1)2 {
  * Local macros to store the names of model.
  local prediction1 = "model"
  * Create variables to later store probabilities from each prediction model
  quietly g `prediction1'=.

  * Create a variable to be used to ‘randomize’ the patients.
  quietly g u = uniform()
  * Sort by the event to ensure equal number of patients with the event are in each
  * group
  sort cancer u
  * Assign each patient into one of ten groups
  g group = mod(_n, 10) + 1

  * Loop through to run through for each of the ten groups
  forvalues j=1(1)10 {
  	* First for the “base” model:
  	* Fit the model excluding the jth group.
  	quietly logit cancer age famhistory marker if group!=`j'
  	* Predict the probability of the jth group.
  	quietly predict ptemp if group==`j'
  	* Store the predicted probabilities of the jth group (that was not used in
  	* creating the model) into the variable previously created
  	quietly replace `prediction1' = ptemp if group==`j'
  	* Dropping the temporary variable that held predicted probabilities for all
  	* patients
  	drop ptemp
  }

  * Creating a temporary file to store the results of each of the iterations of our
  * decision curve for the multiple the 10 fold cross validation
  * This step may omitted if the optional forvalues loop was excluded.
  tempfile dca`i'

  * Run decision curve, and save the results to the tempfile.
  * For those excluding the optional multiple cross validation, this decision curve
  * (to be seen by excluding “nograph”) and the results (saved under the name of your
  * choosing) would be the decision curve corrected for overfit.
  quietly dca cancer `prediction1', xstop(.5) nograph ///
  saving("`dca`i''")
  drop u group `prediction1'
} // This closing bracket ends the initial loop for the multiple cross validation.

* It is also necessary for those who avoided the multiple cross validation
* by changing the value of the forvalues loop from 200 to 1*/
* The following is only used for the multiple 10 fold cross validations.
use "`dca1'", clear
forvalues i=2(1)2 {
  * Append all values of the multiple cross validations into the first file
  append using "`dca`i''"
}

* Calculate the average net benefit across all iterations of the multiple
* cross validation
collapse all none model model_i, by(threshold)
save "Cross Validation DCA Output.dta", replace

* Labeling the variables so that the legend will have the proper labels
label var all "Treat All"
label var none "Treat None"
label var model "Cross-validated Prediction Model"

* Plotting the figure of all the net benefits.
twoway (line all threshold if all>-0.05, sort) || (line none model threshold, sort)
