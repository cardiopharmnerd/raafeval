texdoc init raafeval, replace logdir(log) gropts(optagrs(width=0.8\textwidth))
set linesize 100

/***
\documentclass[11pt]{article}
\usepackage{fullpage}
\usepackage{siunitx}
\usepackage{hyperref,graphicx,booktabs,dcolumn}
\usepackage{natbib}
\usepackage{chngcntr}
\usepackage{pgfplotstable}
\usepackage{pdflscape}
\usepackage{multirow}
\usepackage{booktabs}
\usepackage{stata}

  
\newcommand{\thedate}{\today}
\counterwithin{figure}{section}
\bibliographystyle{unsrt}
\hypersetup{%
    pdfborder = {0 0 0}
}

\begin{document}

\begin{titlepage}
  \begin{flushright}
        \Huge
		\textbf{Evaluation of pharmacist-physician rapid access atrial fibrillation clinic model of care}
\color{violet}
\rule{16cm}{2mm} \\
\Large
\color{black}
Protocol \\
\thedate \\
\color{blue}
\url{https://github.com/cardiopharmnerd/raaf} \\
\color{black}
		\vfill
	\end{flushright}
		\Large
\noindent
Adam Livori \\
Lead pharmacist - cardiology \\
PhD Candidate \\
\color{blue}
\href{mailto:adam.livori1@monash.edu}{adam.livori1@monash.edu} \\
\color{black}
\\
Grampians Health Ballarat | Monash University
\\
Center for Medication Use and Safety, Faculty of Pharmacy and Pharmaceutical Sciences, Monash Unviersity, Melbourne, Australia \\
\\
\end{titlepage}

\pagebreak
\tableofcontents
\pagebreak

\section{Preface}


The is the protocol for the paper Evaluation of pharmacist-physician rapid access atrial fibrillation clinic model of care\\
To generate this document, the Stata package texdoc \cite{Jann2016Stata} was used, which is  available from: \color{blue} \url{http://repec.sowi.unibe.ch/stata/texdoc/} \color{black} (accessed 14 November 2022).  The final Stata do file and this pdf are available at: \color{blue} \url{https://github.com/cardiopharmnerd/raaf} \color{black} 

\pagebreak

\section{Abbreviations}
\begin{itemize}
	\item AF - Atrial fibrillation
	\item CHADSVA - Risk score for determning stroke risk in AF
	\item DCR - Direct current reversion
	\item ED - Emergency department
	\item EP - Electrophysiologist	
	\item EQ5D - European Quality of Life survey - 5 dimension version
	\item GP - General practitioner
	\item NOAC - Non-vitamin K oral anticoagulant
	\item NPS - Net promoter score
	\item RAAF - Rapid Access Atrial Fibrillation Clinic	
	item URN - Unique registrations number
	\item WebPAS - Web-based Patient Adminsitration System
\end{itemize}
	

\pagebreak
		
\section{Introduction} \label{introduction}
People with atrial fibrillation, the most common cardiac arrythmia worldwide, are at increased risk of hospitalization from both symptoms of atrial fibrillation, as well as higher risk of stroke and heart failure. It is important that when people are diagnosed with atrial fibrillation are risk assessed as soon as possible to ensure appropriate and safe treatment can be provided. This assessment should include stroke risk calculation and provision of anticoagulation, arrythmia symptom control plans, and comorbidity assessment, in combination with patient education. From 2022 to 2023, Grampians Health Ballarat participated in a Safer Care Victoria funded initiative to establish rapid access atrial fibrillation (RAAF) clinics. This project is a retrospective review of how the RAAF clinic provided care to patients referred to the service, both in quality of service, clinic outcomes, and patient acceptance of service, as well as investigating the costs and benefits of the RAAF clinic as a sustainable model of care. 

\pagebreak
\section{Data source and import}
The data for this project was generated via an audit of all indivudals seen in the RAAF clinic. Data was extracted from a REDCap collection tool and stata file exported for analysis. \cite{redcap1,redcap2} A second dataset was used from the outpatient module of the hospital booking system (WebPAS) that listed all medical appointments and referrals to the RAAF clinic. 
\color{violet}
***/

texdoc stlog, cmdlog nodo

set rmsg on
cd "\\ad.monash.edu\home\User007\acliv1\Documents\GitHub\raaf\output"



*First dataset from REDCap export

clear 

import excel "C:\Users\acliv1\Dropbox\~ADAM\PhD\4. Project 4 RAAF implementation and ROI\Data\raaf_ads.xlsx", firstrow

ta ref_n

*There are 10 patients where they were referred into the clinic twice, this will be important for collecting appointment statistics. 


*Save a local copy of the dataset for checks and cleaning
save pre_ads, replace

*Second dataset from outpatient booking system

clear 

import excel "C:\Users\acliv1\Dropbox\~ADAM\PhD\4. Project 4 RAAF implementation and ROI\Data\raaf_att.xlsx", firstrow

rename (UR Attendance Mode)  (urn att mode)

drop N

drop if att == .

save pre_appt, replace



texdoc stlog close

/***
\color{black}
\section{Data cleaning}

For a description of the data, we first inspected each variable to ensure there are no unusual pieces of data, and to check missing data to ensure it is intentionally blank or if there is an error in the data entry component of the REDCap tool. We took the following steps:
\begin{enumerate}
	\item Ensure all indivudals accounted for
	\item Review date based variables
	\item Review categorical variables
\end{enumerate}

\subsection{RAAF REDCap data}
Although CHADSVA scores are shown as a continious variable, they are really an ordinal variable, and so were checked and cleaned as part of the categorical varaible review. The same approach was considered for NPS scores.
\color{violet}
***/

texdoc stlog, cmdlog nodo

*Open pre-cleaned dataset and check variables
use pre_ads, clear
br
de

texdoc stlog close

/***
\color{black}
\subsubsection{Ensure all indivudals accounted for}
We wanted to ensure no duplicate entries based on the id numbers generated for each URN entered into the original dataset. We also needed to drop anyone who received no consults as part of this service. These were likely indivudals who originally consented to clinic, but changed their mind later. 
\color{violet}
***/

texdoc stlog, cmdlog nodo

ta id

*No duplicates

keep if either_att == "Yes"

*Twelve people dropped, leaving 275 indivudals who attended the service at least once.  

bysort urn date_dc : gen nghost = _n
ta nghost
bysort urn appt_pharm : gen nghost1 = _n
ta nghost1

br urn nghost nghost1 if nghost == 2

*Same person entered twice, they will be dropped

drop if nghost == 2
br

drop nghost nghost1



texdoc stlog close

/***
\color{black}
\subsubsection{Review date based variables}
We checked each of the date variables to ensure all appointments occurred after the referral date, and that the first appoointment occurred within the implementation phase of 1/4/2022 and 1/11/2023. 
\color{violet}
***/

texdoc stlog, cmdlog nodo

foreach i in date_dc date_ref appt_pharm appt_phys  date_fup {
format `i' %td	
}


hist  date_dc, color(black) graphregion(color(white)) frequency xtitle("Discharge date")
graph export "\\ad.monash.edu\home\User007\acliv1\Documents\GitHub\raaf\output\hist_discharge.pdf", as(pdf) name("Graph") replace

hist  date_ref, color(black) graphregion(color(white)) frequency xtitle("Referral date")
graph export "\\ad.monash.edu\home\User007\acliv1\Documents\GitHub\raaf\output\hist_referral.pdf", as(pdf) name("Graph") replace

hist  appt_pharm, color(black) graphregion(color(white)) frequency xtitle("Pharmacist apopointment date")
graph export "\\ad.monash.edu\home\User007\acliv1\Documents\GitHub\raaf\output\hist_appt_pharm.pdf", as(pdf) name("Graph") replace

hist  appt_phys, color(black) graphregion(color(white)) frequency xtitle("Physician apopointment date")
graph export "\\ad.monash.edu\home\User007\acliv1\Documents\GitHub\raaf\output\hist_appt_phys.pdf", as(pdf) name("Graph") replace


/***
\color{black}
\begin{figure} [H]
	\centering
	\includegraphics[width=0.8\textwidth]{hist_discharge.pdf}
	\caption{Histogram of discharge date}
	\label{hist_discharge}
\end{figure}

\begin{figure} [H]
	\centering
	\includegraphics[width=0.8\textwidth]{hist_referral.pdf}
	\caption{Histogram of referral dates}
	\label{hist_referral.pdf}
\end{figure}

\begin{figure} [H]
	\centering
	\includegraphics[width=0.8\textwidth]{hist_appt_pharm.pdf
	\caption{Histogram of pharmacist appointment dates}
	\label{hist_appt_pharm.pdf}
\end{figure}

\begin{figure} [H]
	\centering
	\includegraphics[width=0.8\textwidth]{hist_appt_phys.pdf}
	\caption{Histogram of physician appointment dates}
	\label{hist_discharge}
\end{figure}


All looks reasonable, now to check time from referral to first appointment. 
\color{violet}
***/

gen appt_first = appt_pharm 
format appt_first %td
replace appt_first = appt_phys if appt_phys < appt_pharm

gen tts_ref = appt_first - date_ref
gen tts_dc = appt_first - date_dc
gen tts_pharmphys = appt_phys - appt_pharm if pharm_att == "Yes" & phys_att == "Yes"

su tts_ref, detail

su tts_dc, detail

su tts_pharmphys, detail

texdoc stlog close

/***
\color{black}
There are no negative numbers when looking at the time difference between referral/dc and first seen, so data makes sense from this perspective.

\subsection{Review categorical variables}
The majority of variables in this dataset are categorical, so we inspected each one to ensure repsonses were complete and made sense for the question being asked. We also created labels and encoded ordinal variables such as age group to make creating and merging tables easier down the track. 
\color{violet}
***/

texdoc stlog, cmdlog nodo


label define order 1 "Under 50" 2 "50-59" 3 "60-69" 4 "70-79" 5 "80-89" 6 "Over 90"
encode age_group, gen(age) label(order)
drop age_group
ta age
ta sex
ta refsource
ta refgen
ta pharm_att
ta phys_att
ta either_att
ta careset
ta tte
ta chadsva_done
ta hasbled
ta oac_prior_binary
ta oac_prior

*There are some missing, need to ensure they are intentionally blank and if so, mark them as blank

count if oac_prior == "" & oac_prior_binary != "No"

*All good intentionally blank, so will change to "None"

replace oac_prior = "none" if oac_prior == ""
replace oac_prior = "none" if oac_prior == "None"
ta oac_prior

ta oac_post
br if oac_post == ""

*All appear to be intentionally blank , so will replace with "None"

replace oac_post = "none" if oac_post == ""
replace oac_post = "none" if oac_post == "None"
br
ta oac_post




texdoc stlog close

/***
\color{black}
This next section required some recoding due to "0" and "No" being used as values of "None", we will check all the medication data and ensure it either lists the drug or none if no drug present. This was done both pre and post RAAF attendance for the following anti-arrythmic drug classes:
\begin{itemize}
	\item Beta blockers
	\item Calcium channel blockers (non-dihydropyridine)
	\item Flecainide
	\item Amiodarone
	\item Digoxin
\end{itemize}

We also created a variable to group individuals into CHADSVA of 0, 1 and greater than 2, which are strifications often use to dictate whether anticoagulation is required \cite{escaf2024}. 
\color{violet}
***/

texdoc stlog, cmdlog nodo

*Beta blockers prior to RAAF
ta bb_prior
replace bb_prior = "none" if bb_prior == "0"
replace bb_prior = lower(bb_prior)
ta bb_prior

gen bb_prior_sot = "No"
replace bb_prior_sot = "Yes" if bb_prior == "sotalol"

*Calcium channels blockers prior to RAAF
ta cc_prior
replace cc_prior = "none" if cc_prior == "0"
replace cc_prior = lower(cc_prior)
ta cc_prior

*Flecainide prior to RAAF
ta flec_prior
replace flec_prior = "none" if flec_prior == "0"
replace flec_prior = lower(flec_prior)
ta flec_prior

*Amiodarone prior to RAAF
ta amio_prior
replace amio_prior = "none" if amio_prior == "0"
replace amio_prior = lower(amio_prior)
ta amio_prior

*Digoxin prior to RAAF
ta dig_prior /// nil issues

*Beta blockers post RAAF
ta bb_post
replace bb_post = "none" if bb_post == "0"
replace bb_post = "none" if bb_post == "ceased"
replace bb_post = lower(bb_post)
ta bb_post

gen bb_post_sot = "No"
replace bb_post_sot = "Yes" if bb_prior == "sotalol"

*Calcium channels blockers post RAAF
ta cc_post
replace cc_post = "none" if cc_post == "0"
replace cc_post = lower(cc_post)
ta cc_post

*Flecainide post RAAF
ta flec_post
replace flec_post = "none" if flec_post == "0"
replace flec_post = lower(flec_post)
ta flec_post

*Amiodarone post RAAF
ta amio_post
replace amio_post = "none" if amio_post == "0"
replace amio_post = lower(amio_post)
ta amio_post

*Digoxin post RAAF
ta dig_post
replace dig_post = "yes" if dig_post == "Yes"
replace dig_post = "none" if dig_post == "0" | dig_post == "ceased"
ta dig_post

*DCR 
ta dcr_ref
replace dcr_ref = "yes" if dcr_ref == "Yes" | dcr_ref == "1"
replace dcr_ref = "no" if dcr_ref == "0"
ta dcr_ref

texdoc stlog close

/***
\color{black}
The next variables are post RAAF follow up data such as discharge management plans for symptoms, who the indivudal was discharged to (GP, specialist, etc) as well as hospital outcomes at 30 days such as unplanned ED and hospital admission presentations. 
\color{violet}
***/

texdoc stlog, cmdlog nodo

ta control_plan

ta next_appt

ta dc_clinic

ta dc_mxplan

ta ed_30

ta adm_30

ta dead_30

ta chadsva, missing

gen oac_indicated = 0
replace oac_indicated = 1 if chadsva == 1
replace oac_indicated = 2 if chadsva > 1

texdoc stlog close

/***
\color{black}
We created some tags to indicate changes made in medication pre and post RAAF clinic attendance. 
\color{violet}
***/

texdoc stlog, cmdlog nodo


*Create a binary tag for post RAAF clinic anticoagulation as not present in the dataset
gen oac_post_binary = "No"
replace oac_post_binary = "Yes" if oac_post != "none"

*Create variable that lists the anticoagulant without dosing
gen oac_prior_drug = "none"
ta oac_prior
replace oac_prior_drug = "apixaban" if oac_prior == "Apixaban 5mg bd" | oac_prior == "Apixaban 2.5mg bd"
replace oac_prior_drug = "rivaroxaban" if oac_prior == "Rivaroxaban 15mg d" | oac_prior == "Rivaroxaban 20mg d" 
replace oac_prior_drug = "dabigatran" if oac_prior == "Dabigatran 150mg bd" | oac_prior == "Dabigatran 110mg bd"
replace oac_prior_drug = "warfarin" if oac_prior == "warfarin"
ta oac_prior_drug oac_prior


gen oac_post_drug = "none"
ta oac_post
replace oac_post_drug = "apixaban" if oac_post == "Apixaban 5mg bd" | oac_post == "Apixaban 2.5mg bd"
replace oac_post_drug = "rivaroxaban" if oac_post == "Rivaroxaban 15mg d" | oac_post == "Rivaroxaban 20mg d" 
replace oac_post_drug = "dabigatran" if oac_post == "Dabigatran 150mg bd" | oac_post == "Dabigatran 110mg bd"
replace oac_post_drug = "warfarin" if oac_post == "warfarin"
ta oac_post_drug oac_post

*Create a tag to state if anticoagulation required changing following RAAF clinic attendance
gen oac_change = "No"
replace oac_change = "Dose/drug change" if oac_prior != oac_post
replace oac_change = "Ceased" if oac_prior != "none" & oac_post == "none"
replace oac_change = "Added" if oac_prior == "none" & oac_post != "none"
ta oac_change

*Create tag to state anticoagulation was appropriate
gen oac_app = 0
replace oac_app = 1 if oac_change == "No"
ta oac_app  oac_change

*Create tag for all beta blockers and calcium channel blockers
gen bb_prior_class = 0
replace bb_prior_class = 1 if bb_prior != "none"
ta bb_prior_class bb_prior

gen bb_post_class = 0
replace bb_post_class = 1 if bb_post != "none"
ta bb_post_class bb_post

gen cc_prior_class = 0
replace cc_prior_class = 1 if cc_prior != "none"
ta cc_prior_class cc_prior

gen cc_post_class = 0
replace cc_post_class = 1 if cc_post != "none"
ta cc_post_class cc_post

*Create a tag for changes made to anti-arrythmic medications

gen bb_change = "No"
replace bb_change = "Ceased" if bb_prior != "none" & bb_post == "none"
replace bb_change = "Added" if bb_prior =="none" & bb_post != "none"
replace bb_change = "Drug change" if bb_prior != "none" & bb_post != bb_prior & bb_post != "none"
replace bb_change = "Switched to sotalol" if bb_prior != "sotalol" & bb_post == "sotalol"
ta bb_change, sort

gen cc_change = "No"
replace cc_change = "Ceased" if cc_prior != "none" & cc_post == "none"
replace cc_change = "Added" if cc_prior =="none" & cc_post != "none"
replace cc_change = "Drug change" if cc_prior != "none" & cc_post != cc_prior & cc_post != "none"
ta cc_change, sort

gen flec_change = "No"
replace flec_change = "Ceased" if flec_prior != "none" & flec_post == "none"
replace flec_change = "Added" if flec_prior =="none" & flec_post != "none"
replace flec_change = "Drug change" if flec_prior != "none" & flec_post != flec_prior & flec_post != "none"
ta flec_change, sort

gen amio_change = "No"
replace amio_change = "Ceased" if amio_prior != "none" & amio_post == "none"
replace amio_change = "Added" if amio_prior =="none" & amio_post != "none"
replace amio_change = "Drug change" if amio_prior != "none" & amio_post != amio_prior & amio_post != "none"
ta amio_change, sort

gen dig_change = "No"
replace dig_change = "Ceased" if dig_prior != "none" & dig_post == "none"
replace dig_change = "Added" if dig_prior =="none" & dig_post != "none"
replace dig_change = "Drug change" if dig_prior != "none" & dig_post != dig_prior & dig_post != "none"
ta dig_change, sort

*Create tag of any change in anti-arrythmic therapy
gen aa_change = "No"
replace aa_change = "Yes" if bb_change != "No" | cc_change != "No" | flec_change != "No" | amio_change != "No" | dig_change != "No" 
ta aa_change


*create tag for any anti-arrythmic present


foreach i in prior post {
gen aa_`i' = 0
replace aa_`i' = 1 if bb_`i' != "none" | cc_`i' != "none" | flec_`i' != "none" | amio_`i' != "none" | dig_`i' != "none"
}

ta aa_prior
ta aa_post

/***
\color{black}
We checked QoL and and NPS score completion, whhich are both ordinal variables. The EQ5D variable is presented here as a 5-digit number, but it is actually the scores of 1-5 from the 5 dimensions of the EQ5D survey. We will generate a separate dataset of EQ5D scores in order to calculate utility scores across the dataset. \\
The NPS scores range from 1 to 10, and we created a variable to define indivudals as promoter (scored 9-10), detractors (scored 1-6), and neutral (scored 7-8). However for the paper we opted for analysis as mean score with 95% confidence intervals to avoid categorising the data further. 
\color{violet}
***/
*EQ5D scores

count if eq5d_prior == ""
*24 missing

count if eq5d_post == ""
*110 missing

count if eq5d_prior != "" & eq5d_post != ""
*Follow up avaiable on 165 referrals


*NPS Scores

ta nps, missing
*Follow up on 165 scores available, now to break them up into promoter, detractor and neutral

count if nps == 9 | nps == 10
count if nps < 7

gen nps_group = 3
replace nps_group = 2 if nps < 9
replace nps_group = 1 if nps < 6
replace nps_group = 0 if nps > 10
ta nps_group


save ads, replace
export excel "C:\Users\acliv1\Dropbox\~ADAM\PhD\4. Project 4 RAAF implementation and ROI\Data\raaf_ads_clean.xlsx", firstrow(var) replace

texdoc stlog close

/***
\color{black}
\subsection{Merge in GARFIELD and HASBLED scores}
Following completion of the study and preparation of the dataset, we made a decision to go back into the the records where the dataset was constructed and calculate risk scores for HASBLED and GARFIELD. This was used for the cost effectiveness analysis paper that followed this protocol, with the analysis available at \color{blue} \url{https://github.com/cardiopharmnerd/raaf} \color{black} . 
\color{violet}
***/

texdoc stlog, cmdlog nodo

use ads, clear
br

keep urn appt_pharm

export excel "C:\Users\acliv1\Dropbox\~ADAM\PhD\4. Project 4 RAAF implementation and ROI\Data\garfbled.xlsx", firstrow(var) replace

texdoc stlog close

/***
\color{black}
\subsection{Merge in booking system data}
We needed to merge in attendance data to confirm attendance of individuals to physician clincs and those who declined the service all together. It also lists some people who were seen as an adhoc appointment by the physician, but were misclassified as being part of the RAAF clinic. Lastly, we needed to reclassify attendance for people who saw the pharmacist but not the physician. This was for people who were already managed by an external specialist, so were seen by pharmacist and an external physician. 
\color{violet}
***/

texdoc stlog, cmdlog nodo

use ads, clear

bysort urn : keep if _n == 1

keep urn pharm_att phys_att

save urn_att_master, replace

use pre_appt, clear

merge m:1 urn using urn_att_master


*Remove referred appointments that are not service declines, as these are ad hoc removes not part of the RAAF clinic analysis. 
count if _merge == 1 & att == 1

drop if _merge == 1 & att == 1

count if _merge == 1 & att == 0

drop if _merge == 1 & att == 0

*Reclassify attendance of those who only saw the pharmacist, as this dataset only contains physician appointments. 

replace att = 2 if att == . 

*We created a table of people who were referred and who declined service and who attended service

bysort urn : gen nghost = _n

gen decline = 1 if att == 999
gen nocontact = 1 if att == 99
ta pharm_att if nghost == 1


ta nghost if nghost == 1, matcell(A1)
ta decline, matcell(A2)
ta nocontact, matcell(A3)
ta att if att == 1, matcell(A4)
ta att if att == 0, matcell(A5)
ta pharm_att if nghost == 1, matcell(A6)
ta att if att == 2, matcell(A7)

matrix A = (A1\A2\A3\A4\A5\A6\A7)
mat li A
clear 
svmat A

gen demo = ""
replace demo = "Total number of people referred" if _n == 1
replace demo = "Number of people seeing external specialist" if _n == 2
replace demo = "Number of people unable to be contacted" if _n == 3
replace demo = "Number of physician attendancs" if _n == 4
replace demo = "Number of physician non-attendances" if _n == 5
replace demo = "Number of pharmacist non-attendances" if _n == 6
replace demo = "Number of pharmacist attendances" if _n == 7
replace demo = "Number of pharmacist only consults" if _n == 8

*Need to remember there were 10 repeat pharamcist consults not accounted for here:

replace A1 = A1 + 10 if demo == "Number of pharmacist attendances"

order demo

rename A1 n

save table_att, replace
export excel "C:\Users\acliv1\Dropbox\~ADAM\PhD\4. Project 4 RAAF implementation and ROI\Data\table_attendance.xlsx", firstrow(var) replace

texdoc stlog close

/***
\color{black}
\subsection{EQ5D data}
We used an existing Austrlian population derived value set to attribute EQ5D scores to utility scores \cite{eq5daus}
\color{violet}
***/

texdoc stlog, cmdlog nodo

use ads, clear
keep urn ref_n eq5d_prior eq5d_post

drop if eq5d_post == ""
count if eq5d_prior == ""

bysort urn : gen nghost = _n
ta nghost
keep if nghost == 1
drop nghost

foreach i in prior post {
gen mo_`i'_og = substr(eq5d_`i', 1,1)
gen sc_`i'_og = substr(eq5d_`i', 2,1)
gen ua_`i'_og = substr(eq5d_`i', 3,1)
gen pd_`i'_og = substr(eq5d_`i', 4,1)
gen ad_`i'_og = substr(eq5d_`i', 5,1)

gen mo_`i' = 0
replace mo_`i' = -0.039 if mo_`i'_og == "2"
replace mo_`i' = -0.067 if mo_`i'_og == "3"
replace mo_`i' = -0.237 if mo_`i'_og == "4"
replace mo_`i' = -0.242 if mo_`i'_og == "5"
gen sc_`i' = 0
replace sc_`i' = -0.030 if sc_`i'_og == "2"
replace sc_`i' = -0.058 if sc_`i'_og == "3"
replace sc_`i' = -0.213 if sc_`i'_og == "4"
replace sc_`i' = -0.221 if sc_`i'_og == "5"
gen ua_`i' = 0
replace ua_`i' = -0.055 if ua_`i'_og == "3"
replace ua_`i' = -0.162 if ua_`i'_og == "4" | ua_`i'_og == "5"
gen pd_`i' = 0
replace pd_`i' = -0.044 if pd_`i'_og == "2"
replace pd_`i' = -0.081 if pd_`i'_og == "3"
replace pd_`i' = -0.276 if pd_`i'_og == "4"
replace pd_`i' = -0.285 if pd_`i'_og == "5"
gen ad_`i' = 0
replace ad_`i' = -0.032 if ad_`i'_og == "2"
replace ad_`i' = -0.066 if ad_`i'_og == "3"
replace ad_`i' = -0.238 if ad_`i'_og == "4" | ad_`i'_og == "5"
gen n5_`i' = 0
replace n5_`i' = -0.153 if mo_`i'_og == "5" | sc_`i'_og == "5" | ua_`i'_og == "5" | pd_`i'_og == "5" | ad_`i'_og == "5" 
gen utility_`i' = 1 + mo_`i' + sc_`i' + ua_`i' + pd_`i' + ad_`i' + n5_`i'
}

foreach i in mo sc ua pd ad {
gen diff_`i' = `i'_post - `i'_prior
}


hist utility_prior, width(0.05) color(black) graphregion(color(white)) frequency xtitle("EQ5D utility score")
graph export "\\ad.monash.edu\home\User007\acliv1\Documents\GitHub\raaf\output\hist_utility_prior.pdf", as(pdf) name("Graph") replace

hist utility_post, width(0.05) color(black) graphregion(color(white)) xtitle("EQ5D utility score")
graph export "\\ad.monash.edu\home\User007\acliv1\Documents\GitHub\raaf\output\hist_utility_post.pdf", as(pdf) name("Graph") replace

gen utility_diff = utility_post - utility_prior

su utility_diff, detail

hist utility_diff, width(0.05) color(black) graphregion(color(white)) frequency xtitle("Difference in utility scores")
graph export "\\ad.monash.edu\home\User007\acliv1\Documents\GitHub\raaf\output\hist_utility_diff.pdf", as(pdf) name("Graph") replace

 
gen utility_group = "no change"
replace utility_group = "improved" if utility_diff > 0
replace utility_group = "decreased" if utility_diff < 0
ta utility_group

foreach i in mo sc ua pd ad {
destring `i'_prior_og, replace
destring `i'_post_og, replace
gen diff_`i'_og = `i'_post_og - `i'_prior_og
}

su diff_mo_og, detail
su diff_sc_og, detail
su diff_ua_og, detail
su diff_pd_og, detail
su diff_ad_og, detail


*Paired t-test 
su utility_prior, detail
su utility_post, detail
ttest utility_post == utility_prior


save utility_scores, replace

/***
\color{black}
\begin{figure} [H]
	\centering
	\includegraphics[width=0.8\textwidth]{hist_utility_prior.pdf}
	\caption{Histogram of EQ5D utility scores prior to RAAF clinic}
	\label{hist_utility_prior.pdf}
\end{figure}

\begin{figure} [H]
	\centering
	\includegraphics[width=0.8\textwidth]{hist_utility_post.pdf}
	\caption{Histogram of EQ5D utility scores post RAAF clinic}
	\label{hist_utility_post.pdf}
\end{figure}

\begin{figure} [H]
	\centering
	\includegraphics[width=0.8\textwidth]{hist_utility_diff.pdf}
	\caption{Histogram of difference in utility scores}
	\label{hist_utility_diff.pdf}
\end{figure}


\color{violet}
***/

texdoc stlog close


/***
\color{black}
\section{Generate result tables}
\subsection{Model of care evaluation}
\subsubsection{RAAF clinic cohort description}
\color{violet}
***/

texdoc stlog, cmdlog nodo

use ads, clear

gen tahelp = 1

ta tahelp, matcell(A1)
ta sex if sex == "Female", matcell(A11)
ta age, matcell(A2)
ta refsource, sort matcell(A3)
ta pharm_att if pharm_att == "Yes", matcell(A4)
ta phys_att if phys_att == "Yes", matcell(A5)
ta careset if careset == "Yes", matcell(A6)
ta tte if tte == "Yes", matcell(A7)
ta chadsva_done if chadsva_done == "Yes", matcell(A8)
ta chadsva, matcell(A9)
ta hasbled if hasbled == "Yes", matcell(A10)

matrix A = (A1\A11\A2\A3\A4\A5\A6\A7\A8\A9\A10)
matrix list A
clear
svmat A

egen total = max(A)
gen A2 = string((100 * A1 / total), "%3.1f")+"%"
gen A1s = string(A1)
gen A = A1s + " (" + A2 + ")" 
replace A = A1s if _n == 1

gen demo = ""
replace demo = "Total" if _n == 1
replace demo = "Female" if _n == 2
replace demo = "Under 50" if _n == 3
replace demo = "50-59" if _n == 4
replace demo = "60-69" if _n == 5
replace demo = "70-79" if _n == 6
replace demo = "80-89" if _n == 7
replace demo = "Over 90" if _n == 8
replace demo = "Inpatient ward" if _n == 9
replace demo = "Emergency department" if _n == 10
replace demo = "General Practitioner" if _n == 11
replace demo = "External hospital" if _n == 12
replace demo = "At least one pharmacist appointment" if _n == 13
replace demo = "At least one physician appointment" if _n == 14
replace demo = "Care-set completed" if _n == 15
replace demo = "Echocardiogram completed" if _n == 16
replace demo = "CHADSVA Assessment completed" if _n == 17
replace demo = "CHADSVA = 0" if _n == 18
replace demo = "CHADSVA = 1" if _n == 19
replace demo = "CHADSVA = 2" if _n == 20
replace demo = "CHADSVA = 3" if _n == 21
replace demo = "CHADSVA = 4" if _n == 22
replace demo = "CHADSVA = 5" if _n == 23
replace demo = "CHADSVA = 6" if _n == 24
replace demo = "CHADSVA = 7" if _n == 25
replace demo = "CHADSVA = 8" if _n == 26
replace demo = "HASBLED assessment completed" if _n == 27

keep demo A

save table_demo1, replace

*Create row for median CHADSVA
use ads, clear
su chadsva, de
ret li
matrix A = r(p50), r(p25), r(p75) 
mat li A
clear 
svmat A
gen demo = "Median CHADSVA score (IQR)"
forval i = 1/3 {
gen A`i's = string(A`i')
}
gen A = A1s + " (" + A2s + "-" + A3s + ")"
keep demo A

save table_demo2, replace


*Bring tables together and finalise formatting
append using table_demo1

gen id = _n
replace id = 27.5 if id == 1
sort id
drop id

gen cat = ""
replace cat = "Age ranges" if _n ==3
replace cat = "Referral source " if _n == 9
replace cat  = "Attendance" if _n == 13
replace cat = "Risk assessments" if _n == 15
order cat demo A

save table_demo, replace
export excel "C:\Users\acliv1\Dropbox\~ADAM\PhD\4. Project 4 RAAF implementation and ROI\Data\table_demo.xlsx", firstrow(var) replace

texdoc stlog close

/***
\color{black}
\subsubsection{Timely access}
\color{violet}
***/

texdoc stlog, cmdlog nodo

*Create table of median times for appointments

use ads, clear

su tts_ref, de
return li
mat A = (r(p50),r(p25),r(p75))
su tts_dc, de
mat A  = (A\(r(p50),r(p25),r(p75)))
su tts_pharmphys, detail
mat A  = (A\(r(p50),r(p25),r(p75)))
su pharmatt_total, de
mat A = (A\(r(p50),r(p25),r(p75)))
su physatt_total, de
mat A = (A\(r(p50),r(p25),r(p75)))

mat li A

clear 
svmat A

gen demo = ""
replace demo = "Median time from referral to first appointment (IQR)" if _n == 1
replace demo = "Median time from discharge to first appointment (IQR)" if _n == 2
replace demo = "Median time between pharmacist and physician appointment* (IQR)" if _n == 3
replace demo = "Median number of pharmacist attendances per referral (IQR)" if _n == 4
replace demo = "Median number of physician attendances per referral (IQR)" if _n ==5 
forval i = 1/3 {
gen  A`i's = string(A`i') 
}
gen A = A1s + " (" + A2s + "-" + A3s + ")"

keep demo A

save table_att1, replace

*Create table for attendance and discharge outcomes statistics

use ads, clear

gen tahelp = 1

ta tahelp, matcell(A1)
ta pharm_att if pharm_att == "Yes", matcell(A2)
ta phys_att if phys_att == "Yes", matcell(A3)
ta dc_mxplan if dc_mxplan == "Yes", matcell(A4)
ta control_plan, sort matcell(A5)
ta dc_clinic, sort matcell(A6)
ta ed_30 if ed_30 == "Yes", matcell(A7)
ta adm_30 if adm_30 == "Yes", matcell(A8)

matrix A = (A1\A2\A3\A4\A5\A6\A7\A8)
matrix list A
clear
svmat A

egen total = max(A)
gen A2 = string((100 * A1 / total), "%3.1f")+"%"
gen A1s = string(A1)
gen A = A1s + " (" + A2 + ")" 
replace A = A1s if _n == 1

gen demo = ""
replace demo = "Total" if _n == 1
replace demo = "At least one pharmacist appointment" if _n == 2
replace demo = "At least one physician appointment" if _n == 3
replace demo = "Management plan present on discharge from clinic" if _n == 4
replace demo = "Rhythm control plan documented on discharge from clinic" if _n == 5
replace demo = "Rate control plan documented on discharge from clinic" if _n == 6
replace demo = "No rate/rhythm control plan documented on discharge from clinic" if _n == 7
replace demo = "General practitioner" if _n == 8
replace demo = "Public regional cardiology clinic" if _n == 9
replace demo = "Private cardiologist clinic" if _n == 10
replace demo = "Public electrophysiology clinic" if _n == 11
replace demo = "Public regional heart failure clinic" if _n == 12
replace demo = "Metropolitan cardiologist clinic" if _n == 13
replace demo = "Unplanned presentation to emergency department" if _n == 14
replace demo = "Unplanned admission to hospital" if _n == 15

keep demo A
save table_att2, replace

*Merge tables together

append using table_att1

gen id = _n


replace id = 3.5 if id > 15
sort id
drop id

gen cat = ""
replace cat = "Attendance statistics" if _n == 2
replace cat = "Discharge documentation" if _n == 9
replace cat = "Discharge from RAAF clinic to" if _n == 13
replace cat = "Representation outcomes at 30 days post discharge" if _n == 19

order cat demo A

save table_att, replace
export excel "C:\Users\acliv1\Dropbox\~ADAM\PhD\4. Project 4 RAAF implementation and ROI\Data\table_attdc.xlsx", firstrow(var) replace

texdoc stlog close

/***
\color{black}
\subsubsection{Anticoagulant use before and after RAAF clinic}
\color{violet}
***/

texdoc stlog, cmdlog nodo

*OAC use pre and post as one column table

use ads, clear

gen tahelp = 1

ta tahelp, matcell(A1)
ta oac_indicated, matcell(A2)
ta oac_prior_binary if oac_indicated == 1 & oac_prior_binary == "Yes", matcell(A3)
ta oac_prior_binary if oac_indicated == 2 & oac_prior_binary == "Yes", matcell(A4)
ta oac_prior_drug if oac_prior != "none", sort matcell(A5)
ta oac_post_binary if oac_indicated == 1 & oac_post_binary == "Yes", matcell(A6)
ta oac_post_binary if oac_indicated == 2 & oac_post_binary == "Yes", matcell(A7)
ta oac_post_drug if oac_post != "none", sort matcell(A8)
ta oac_change, sort matcell(A9)

matrix A = (A1\A2\A3\A4\A5\A6\A7\A8\A9)
matrix list A
clear
svmat A

gen demo = ""
replace demo = "Total" if _n == 1
replace demo = "CHADSVA = 0" if _n == 2
replace demo = "CHADSVA = 1" if _n == 3
replace demo = "CHADSVA > 1" if _n ==4
replace demo = "OAC prescribed with CHADSVA of 1" if _n == 5
replace demo = "OAC prescribed with CHADSVA > 1" if _n == 6
replace demo = "Apixaban" if _n == 7
replace demo = "Rivaroxaban" if _n == 8
replace demo = "Dabigatran" if _n == 9
replace demo = "Warfarin" if _n == 10
replace demo = "OAC prescribed with CHADSVA of 1" if _n == 11
replace demo = "OAC prescribed with CHADSVA > 1" if _n == 12
replace demo = "Apixaban" if _n == 13
replace demo = "Rivaroxaban" if _n == 14
replace demo = "Dabigatran" if _n == 15
replace demo = "Warfarin" if _n == 16
replace demo = "No changes made to anticoagulation" if _n == 17
replace demo = "OAC commenced" if _n == 18
replace demo = "OAC ceased" if _n == 19
replace demo = "OAC dose/drug correction made" if _n == 20

save oactab, replace

gen total = A1
replace total = A1[3] if _n == 5 | _n == 7
replace total = A1[4] if _n == 6 | _n == 8
replace total = A1[1] if _n > 8

gen A2 = string((100 * A1 / total), "%3.1f")+"%"
gen A1s = string(A1)
gen A = A1s + " (" + A2 + ")" 
replace A = A1s if _n == 1

keep demo A
gen cat = ""
replace cat = "Stroke risk assessment" if _n == 2
replace cat = "Prior to RAAF clinic" if _n == 5
replace cat = "Following RAAF clinic" if _n == 11
replace cat = "Summary of changes" if _n == 17

order cat demo A

save table_drugtotaloac1C, replace
export excel "C:\Users\acliv1\Dropbox\~ADAM\PhD\4. Project 4 RAAF implementation and ROI\Data\table_drugtotaloac1C.xlsx", firstrow(var) replace

*OAC use pre and post as two column table
use ads, clear

ta oac_indicated oac_prior_drug, matcell(A1) 
ta oac_indicated oac_post_drug, matcell(A2) 

matrix A = (A1,A2)
matrix list A
clear
svmat A



gen A0 = A1 + A2 + A3 + A4 + A5
gen A11 = A1 + A2 + A4 + A5
gen A12 = A6 + A7 + A9 +A10
forval i = 1/12 {
gen A`i'p = string((100 * A`i' / A0), "%3.1f")+"%"
}
forval i = 1/12 {
gen A`i's = string(A`i')
replace A`i's = A`i's + " (" + A`i'p + ")" 
}
gen A0s = string(A0)
order A0s A11s A1s A2s A4s A5s A3s A12s A6s A7s A9s A10s A8s
keep A0s A11s A1s A2s A4s A5s A3s A12s A6s A7s A9s A10s A8s

gen demo = ""
replace demo = "CHADSVA = 0" if _n == 1
replace demo = "CHADSVA = 1" if _n == 2
replace demo = "CHADSA > 1" if _n == 3
order demo
set obs 4
replace demo = "CHADSVA score" if demo == ""
replace A0s = "Total" if A0s == ""
replace A11s = "Anticoagluated" if A11s == ""
replace A12s = "Anticoagluated" if A12s == ""
replace A1s = "Apixaban" if A1s == ""
replace A6s = "Apixaban" if A6s == ""
replace A2s = "Rivaroxaban" if A2s == ""
replace A7s = "Rivaroxaban" if A7s == ""
replace A3s = "None" if A3s == ""
replace A8s = "None" if A8s == ""
replace A4s = "Dabigatran" if A4s == ""
replace A9s = "Dabigatran" if A9s == ""
replace A5s = "Warfarin" if A5s == ""
replace A10s = "Warfarin" if A10s == ""
gen id = _n
replace id = 0 if id == 4
sort id 
drop id


save table_drugtotaloac2C, replace
export excel "C:\Users\acliv1\Dropbox\~ADAM\PhD\4. Project 4 RAAF implementation and ROI\Data\table_drugtotaloac2C.xlsx", replace


*Indiviudal OAC use graph

foreach ii in prior post{
forval i = 1/2 {
use ads, clear

ta  oac_`ii'_drug if oac_indicated == `i' , matcell(A1) 

matrix A = (A1)
matrix list A
clear
svmat A

gen drug = _n
label define drug 1 "Apixaban" 2 "Dabigatran" 3 "None" 4 "Rivaroxaban" 5 "Warfarin"
label values drug drug
gen ind = "`ii'"
order drug
save oacgraph_`i'_`ii', replace
}
}

foreach ii in prior post{
use ads, clear
ta oac_`ii'_drug oac_indicated if oac_indicated == 0 , matcell(A1) 

matrix A = (A1)
matrix list A
clear
svmat A

set obs 5
gen drug = _n
label define drug 1 "Apixaban" 2 "None" 3 "Dabigatran"  4 "Rivaroxaban" 5 "Warfarin"
label values drug drug
gen ind = "`ii'"
replace A1 = 0 if A1 ==.
order drug
save oacgraph_0_`ii', replace
}

forval i = 0/2 {
use oacgraph_`i'_prior, clear
append using oacgraph_`i'_post
append using oacgraph_`i'_prior
sort drug ind
gen drugind = _n
drop if drugind == 3 | drugind == 6 | drugind == 9 |drugind == 12 | drugind == 15

if `i' == 0 | `i' == 1 {

twoway ///
(bar A1 drugind if ind == "prior" , barw(0.8) col(dknavy%90)) ///
(bar A1 drugind if ind == "post", barw(0.8) col(red%90)), ///
graphregion(color(white)) ///
yscale(range(0,150)) ylabel(0 "0"  20 "20"  40 "40"  60 "60"  80 "80"  100 "100" 120 "120" 140 "140" 160 "160") ytitle("Number of people using anticoagulants") ///
xtitle("")  xlabel(1.5 "Apixaban" 4.5 "None" 7.5 "Rivaroxaban" 10.5 "Dabigatran" 13.5 "Warfarin") ///
legend(order(2 "Pre-RAAF" 1 "Post-RAAF") ring(0) position(12) region(lcolor(white) color(none))) title("CHADSVA score of `i'")

graph save "C:\Users\acliv1\Dropbox\~ADAM\PhD\4. Project 4 RAAF implementation and ROI\Data\fig_oac_`i'.gph", replace 
}

else {

twoway ///
(bar A1 drugind if ind == "prior" , barw(0.8) col(dknavy%90)) ///
(bar A1 drugind if ind == "post", barw(0.8) col(red%90)), ///
graphregion(color(white)) ///
yscale(range(0,150)) ylabel(0 "0"  20 "20"  40 "40"  60 "60"  80 "80"  100 "100" 120 "120" 140 "140" 160 "160") ytitle("Number of people using anticoagulants") ///
xtitle("")  xlabel(1.5 "Apixaban" 4.5 "None" 7.5 "Rivaroxaban" 10.5 "Dabigatran" 13.5 "Warfarin") ///
legend(order(2 "Pre-RAAF" 1 "Post-RAAF") ring(0) position(12) region(lcolor(white) color(none))) title("CHADSVA score of 2 or greater")

graph save "C:\Users\acliv1\Dropbox\~ADAM\PhD\4. Project 4 RAAF implementation and ROI\Data\fig_oac_`i'.gph", replace 
}
}

*Total OAC use graph

use ads, clear

 
ta oac_prior_binary if oac_indicated == 0 & oac_prior_binary == "Yes", matcell(A1) 
ta oac_prior_binary if oac_indicated == 1 & oac_prior_binary == "Yes", matcell(A2)
ta oac_prior_binary if oac_indicated == 2 & oac_prior_binary == "Yes", matcell(A3)
ta oac_post_binary if oac_indicated == 0 & oac_post_binary == "Yes", matcell(A4) 
ta oac_post_binary if oac_indicated == 1 & oac_post_binary == "Yes", matcell(A5) 
ta oac_post_binary if oac_indicated == 2 & oac_post_binary == "Yes", matcell(A6) 
ta oac_indicated, matcell(A7)


matrix A = (A1\A2\A3\A4\A5\A6)
matrix B = (A7\A7)
matrix A = (A,B)

matrix list A
clear
svmat A

gen As = A1/A2*100
gen A = round(As, 1)
keep A
gen time  = 0
replace time = 1 if _n > 3
gen cv = 3
replace cv = 2 if _n == 2 | _n == 5
replace cv = 1 if _n == 1 | _n == 4
label define cv 1 "0" 2 "1" 3 "2 or greater"
label values cv cv
sort cv time

set obs 8
gen id = _n
replace id = 2.5 if id == 7
replace id = 4.5 if id == 8
sort id
gen timecv = _n
drop if timecv == 3 | timecv == 6
drop id

gen As = string(A)
replace As = As + "%"

twoway ///
(bar A timecv if time == 0 & cv == 1, barw(0.8) col(dknavy%90)) ///
(bar A timecv if time == 1 & cv == 1, barw(0.8) col(red%90))  ///
(bar A timecv if time == 0 & cv == 2, barw(0.8) col(dknavy%90)) ///
(bar A timecv if time == 1 & cv == 2, barw(0.8) col(red%90))  ///
(bar A timecv if time == 0 & cv == 3, barw(0.8) col(dknavy%90)) ///
(bar A timecv if time == 1 & cv == 3, barw(0.8) col(red%90))  ///
(scatter A timecv, m (i) mlabel(As) mlabposition(12) mlabcolor(black)) , ///
graphregion(color(white)) ///
yscale(range(0,100)) ylabel(0 "0"  20 "20"  40 "40"  60 "60"  80 "80"  100 "100" ) ytitle("Percentage of people using anticoagulants") ///
xtitle("")  xlabel(1.5 "CHADSVA of 0" 4.5 "CHADSVA of 1" 7.5 "CHADSVA of 2 or greater") ///
legend(order(1 "Pre-RAAF" 2 "Post-RAAF") ring(0) position(12) region(lcolor(white) color(none))) 
graph save "C:\Users\acliv1\Dropbox\~ADAM\PhD\4. Project 4 RAAF implementation and ROI\Data\fig_oac_total.gph", replace 

texdoc stlog close

/***
\color{black}
\subsubsection{Anticoagulant appropriateness and risk factors}
\color{violet}
***/

texdoc stlog, cmdlog nodo

use ads, clear
de

ta oac_indicated
ta oac_app
ta sex
ta age


gen sexbin = 0
replace sexbin = 1 if sex == "Male"
ta sexbin

ta refsource
gen refcat = 0
replace refcat = 1 if refsource == "Emergency Dept"
replace refcat = 2 if refsource == "External Health Service"
replace refcat = 3 if refsource == "GP"
replace refcat = 4 if refsource == "Ward"
ta refcat

logistic oac_app i.sexbin i.age i.refcat


texdoc stlog close

/***
\color{black}
\subsubsection{Anti-arrythmic use before and after RAAF clinic}
\color{violet}
***/

texdoc stlog, cmdlog nodo


use ads, clear

gen tahelp = 1

ta tahelp, matcell(A1)
ta aa_prior if aa_prior == 1, matcell(A2)
ta bb_prior_class if bb_prior_class == 1, matcell(A3)
ta bb_prior if bb_prior != "none" & bb_prior != "carvedilol", sort matcell(A4)
ta cc_prior_class if cc_prior_class == 1, matcell(A5)
ta cc_prior if cc_prior != "none", sort matcell(A6)
ta flec_prior if flec_prior != "none", matcell(A7)
ta amio_prior if amio_prior != "none", matcell(A8)
ta dig_prior if dig_prior != "none", matcell(A9)


matrix A = (A1\A2\A3\A4\A5\A6\A7\A8\A9)
matrix list A
clear
svmat A

egen total = max(A)
gen A2 = string((100 * A1 / total), "%3.1f")+"%"
gen A1s = string(A1)
gen A = A1s + " (" + A2 + ")" 
replace A = A1s if _n == 1

gen demo = ""
replace demo = "Total" if _n == 1
replace demo = "Any anti-arrythmic medication" if _n ==2
replace demo = "Beta blocker" if _n == 3
replace demo = "Metoprolol" if _n == 4
replace demo = "Sotalol" if _n == 5
replace demo = "Atenolol" if _n == 6
replace demo = "Bisoprolol" if _n == 7
replace demo = "Nebivolol" if _n == 8
replace demo = "Calcium channel blocker" if _n == 9
replace demo = "Diltiazem" if _n == 10
replace demo = "Verapamil" if _n == 11
replace demo = "Flecainide" if _n == 12
replace demo = "Amiodarone" if _n == 13
replace demo = "Digoxin" if _n == 14

order demo A
keep demo A A1

save aadrugprior, replace

use ads, clear

gen tahelp = 1

ta tahelp, matcell(A1)
ta aa_post if aa_post == 1, matcell(A2)
ta bb_post_class if bb_post_class == 1, matcell(A3)
ta bb_post if bb_post != "none" & bb_post != "carvedilol", sort matcell(A4)
ta cc_post_class if cc_post_class == 1, matcell(A5)
ta cc_post if cc_post != "none", sort matcell(A6)
ta flec_post if flec_post != "none", matcell(A7)
ta amio_post if amio_post != "none", matcell(A8)
ta dig_post if dig_post != "none", matcell(A9)

matrix A = (A1\A2\A3\A4\A5\A6\A7\A8\A9)
matrix list A
clear
svmat A

egen total = max(A)
gen A2 = string((100 * A1 / total), "%3.1f")+"%"
gen A1s = string(A1)
gen A = A1s + " (" + A2 + ")" 
replace A = A1s if _n == 1

gen demo = ""
replace demo = "Total" if _n == 1
replace demo = "Any anti-arrythmic medication" if _n ==2
replace demo = "Beta blocker" if _n == 3
replace demo = "Metoprolol" if _n == 4
replace demo = "Sotalol" if _n == 5
replace demo = "Atenolol" if _n == 6
replace demo = "Bisoprolol" if _n == 7
replace demo = "Nebivolol" if _n == 8
replace demo = "Calcium channel blocker" if _n == 9
replace demo = "Diltiazem" if _n == 10
replace demo = "Verapamil" if _n == 11
replace demo = "Flecainide" if _n == 12
replace demo = "Amiodarone" if _n == 13
replace demo = "Digoxin" if _n == 14

*Need to rearrange beta blockers
gen id = _n
replace id = 7.5 if id == 6
sort id
drop id

order demo A
keep demo A A1
rename (A A1) (Apost A1post)
gen id = _n

merge 1:1 demo using aadrugprior

drop _merge
order demo A Apost A1 A1post
replace Apost = "0" if Apost == ""
replace A1post = 0 if A1post ==.

preserve
drop A Apost id
save aatable, replace
restore

drop A1 A1post
sort id
drop id

save table_drugtotalaa, replace
export excel "C:\Users\acliv1\Dropbox\~ADAM\PhD\4. Project 4 RAAF implementation and ROI\Data\table_drugtotalaa.xlsx", firstrow(var) replace

*Changes in AA use

use ads, clear
gen tahelp = 1

ta tahelp, matcell(A1)
ta aa_change if aa_change != "No", matcell(A2)
ta bb_change if bb_change != "No", matcell(A3)
ta cc_change if cc_change != "No", matcell(A4)
ta flec_change if flec_change != "No", matcell(A5)
ta amio_change if amio_change != "No", matcell(A6)
ta dig_change if dig_change != "No", matcell(A7)
ta dcr_ref if dcr_ref == "yes", matcell(A8)

matrix A = (A1\A2\A3\A4\A5\A6\A7\A8)
matrix list A
clear
svmat A

egen total = max(A)
gen A2 = string((100 * A1 / total), "%3.1f")+"%"
gen A1s = string(A1)
gen A = A1s + " (" + A2 + ")" 
replace A = A1s if _n == 1

keep A

gen demo = ""
replace demo = "Total" if _n == 1
replace demo = "Any change" if _n == 2
replace demo = "Added" if _n == 3 | _n == 7 | _n == 9 | _n == 10 | _n == 12
replace demo = "Ceased" if _n == 4 | _n == 8 | _n == 11 | _n == 13
replace demo = "Drug change" if _n == 5 
replace demo = "Switched to sotalol" if _n == 6
replace demo = "DCR referral" if _n == 14

gen cat = ""
replace cat = "Beta blockers" if _n == 3
replace cat = "Calcium channel blockers" if _n == 7
replace cat = "Flecainide" if _n == 9
replace cat = "Amiodarone" if _n == 10
replace cat = "Digoxin" if _n == 12
replace cat = "Proecdure" if _n == 14
order cat demo A

save table_drugchangeaa, replace
export excel "C:\Users\acliv1\Dropbox\~ADAM\PhD\4. Project 4 RAAF implementation and ROI\Data\table_drugchangeaa.xlsx", firstrow(var) replace


texdoc stlog close

/***
\color{black}
\subsubsection{Quality of life outcomes - EQ5D}
\color{violet}
***/

texdoc stlog, cmdlog nodo

use utility_scores, clear

gen tahelp = 1

ta tahelp, matcell(A1)
ta utility_group, sort matcell(A2)

matrix A = (A1\A2)
matrix li A
clear
svmat A

egen total = max(A1)
gen A2 = string((100 * A1 / total), "%3.1f")+"%"
gen A1s = string(A1)
gen A = A1s + " (" + A2 + ")" 
replace A = A1s if _n == 1

gen demo = ""
replace demo = "Total with follow up" if _n == 1
replace demo = "Improvement" if _n == 2
replace demo = "Reduction" if _n == 3
replace demo = "No change" if _n == 4

keep demo A
order demo

save table_utilitychange, replace
export excel "C:\Users\acliv1\Dropbox\~ADAM\PhD\4. Project 4 RAAF implementation and ROI\Data\table_utilitychange.xlsx", firstrow(var) replace

*T-test table for EQ5D change

use utility_scores, clear


ttest utility_post == utility_prior
return li

matrix A = (r(mu_2), r(sd_2), r(mu_1), r(sd_1), r(p), r(t), r(N_1))
clear
svmat A

gen lb1 = (A1 - (A6 * (A2/(sqrt(A7)))))
gen ub1 = A1 + (A6 * (A2/(sqrt(A7))))
gen lb2 = A3 - (A6 * (A4/(sqrt(A7))))
gen ub2 = A3 + (A6 * (A4/(sqrt(A7))))


foreach i in A1 lb1 ub1 A3 lb2 ub2 A5 {
gen `i's = string(`i', "%03.2f")
}

gen prior = A1s + " (" + lb1s + "-" + ub1s + ")"
gen post = A3s + " (" + lb2s + "-" + ub2s + ")"

keep prior post A5s
order prior post A5s

save table_utility_ttest, replace
export excel "C:\Users\acliv1\Dropbox\~ADAM\PhD\4. Project 4 RAAF implementation and ROI\Data\table_utility_ttest.xlsx", firstrow(var) replace

*Mean difference and 95% CI table

use utility_scores, clear

su utility_diff
return li

matrix A = (r(mean), r(sd), r(N))
clear
svmat A

gen lb = (A1 - (1.96 * (A2/(sqrt(A3)))))
gen ub = (A1 + (1.96 * (A2/(sqrt(A3)))))


foreach i in A1 lb ub  {
gen `i's = string(`i', "%03.2f")
}

gen diff = A1s + " (" + lbs + "-" + ubs + ")"

keep diff


save table_utility_meandiff, replace
export excel "C:\Users\acliv1\Dropbox\~ADAM\PhD\4. Project 4 RAAF implementation and ROI\Data\table_utility_meandiff.xlsx", firstrow(var) replace



texdoc stlog close

/***
\color{black}
\subsubsection{Quality of life outcomes - NPS}
\color{violet}
***/

texdoc stlog, cmdlog nodo

*NPS table

use ads, clear

bysort urn : keep if _n == 1

gen tahelp = 1

ta tahelp, matcell(A1)
ta tahelp if nps != . , matcell(A2)
ta nps, matcell(A3)

matrix A = (A1\A2\A3)
matrix list A 
clear 
svmat A
set obs 12
replace A1 = 0 if A1 ==.
gen id = _n
replace id = 3.5 if id == 11
replace id = 4.5 if id == 12
sort id
drop id

egen total = max(A1[2])
gen A2 = A1/total*100
drop total
replace A2 = 100*A1/A1[_n-1] if A2 == 100
gen As = string(A1)
gen Bs = string(A2, "%3.2f")
gen A = As + " (" + Bs + "%)" 
replace A = As if _n == 1 | _n == 2
keep A


gen demo = ""
replace demo = "Total" if _n == 1
replace demo = "Completed NPS follow up" if _n == 2
replace demo = "1" if _n == 3
replace demo = "2" if _n == 4
replace demo = "3" if _n == 5
replace demo = "4" if _n == 6
replace demo = "5" if _n == 7
replace demo = "6" if _n == 8
replace demo = "7" if _n == 9
replace demo = "8" if _n == 10
replace demo = "9" if _n == 11
replace demo = "10" if _n == 12

gen cat = ""
replace cat = "Detractors (scored 1-6)" if _n == 3
replace cat  = "Neutral (scored 7-8)" if _n == 9
replace cat = "Promoter (scored 9-10)" if _n == 11

order cat demo A
save table_nps1, replace

use ads, clear
keep if nps != .

bysort urn : keep if _n == 1
su nps, detail
return li

mat A = (r(mean),r(sd))
matrix list A 
clear 
svmat A
gen As = string(A1, "%3.2f")
gen Bs = string(A2, "%3.2f")
gen A = As + " (" + Bs + ")"
keep A

append using table_nps1
gen id = _n
replace id = 13.5 if _n == 1
sort id
replace demo = "Mean NPS score (standard deviation)" if id == 13.5
order cat demo A
drop id


save table_nps, replace
export excel "C:\Users\acliv1\Dropbox\~ADAM\PhD\4. Project 4 RAAF implementation and ROI\Data\table_nps.xlsx", firstrow(var) replace


texdoc stlog close

/***
\clearpage
\color{black}
\bibliography{C:/Users/acliv1/Documents/library.bib}
\end{document}
***/

texdoc close