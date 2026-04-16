/* clean.do
April 15 2026
Reads xls
Makes rectangular
Adds year
Adds unique row id
Adds item id to each relevant row with blank ids
*/

* Packages

clear
set more off
capture log close
log using logs/log.txt, replace
cd ~/Downloads

* Globals
global whoqa ~/github/personal/whoqa
cd ~
cd $whoqa

clear

import excel using "data/raw/Submissions tally 14Apr2026 QA compliance.xlsx", ///
					sheet("Overall.2024-25 (30Apr2025)") ///
					firstr ///
					clear
rename *, lower

*
** Wrong tulip id
*Q-2024-00310

replace tulipid ="HQ-2024-00310 " if tulipid =="Q-2024-00310"

*trim spaces

* 1. Get the list of all string variables
ds, has(type string)

* 2. Loop through them.
* Note: 'of varlist' automatically handles the macro correctly
foreach v of varlist `r(varlist)' {

    * Display the name of the variable being processed
    display "Cleaning variable: `v'"

    * Clean the variable
    replace `v' = trim(ustrtrim(`v'))
    replace `v' = subinstr(`v', char(160), "", .)
    replace `v' = trim(`v')
}


drop if count==.

gen sequence = _n


*rename vars
rename healthpromotiondiseasepreven hpdpc

* create id for each obs
* rename tulipid tulipid_original
* carryforward tulipid_original, gen(tulipid)

* drop rows with next as id
drop if tulipid=="next"
drop if tulipid==""


* create units based on column arrays using column names as unit names



gen unit_str = ""
	foreach var in science emergency healthsystems hpdpc dgobosorcdc {
    replace unit_str = "`var'" if `var' != "0"
}


***** ENCODE/RECODE STRINGS TO BYTES FOR TABULATION

*** Encode phases and gen phase
rename phase phase_old

encode phase_old, gen(phase2)

label define phase 1 "Planning" 2 "Executive" 3 "Other"

recode phase2 2=2 3=2 4=2 1=3 6=1 7=3 5=3 8=3,  gen(phase)

label value phase phase
la var phase "Phase"

	drop phase_old phase2

** gen byte unit for tables

encode unit_str, gen(unit)
	la var unit "Division"
		drop unit_str

label drop unit
label define unit 1 "GPA" 2 "WHE" 3 "HSD" 4 "PPC" 5 "SCI"

**** encode byte decision for tables
encode tulipd, gen(tulipd2)

*recode  to consolidate withdrawn labels

recode tulipd2 (8/10 = 6) (1=6) (2=1) (3=2) (7=3) (4=4) (5=4) , ///
gen(tld2)

recode tld2 (6=5) , ///
gen(decision)
drop tld2

	capture label drop decision
	label define decision 1 "Approve" 2 "Conditional Approval" 3 "Return to RTO" 4 "Reassign" ///
	5 "Respond to Consult"
	label values decision decision

	la var decision "Event Decision"

			drop tulipd2
**** DATES

* replace 2023 to 2024 for two obs
replace submissionnotificationreceived = "7/14/2024" if submissionnotificationreceived =="7/14/2023"
replace submissionnotificationreceived = "3/11/2024" if submissionnotificationreceived =="3/11/2023"


capture drop date_sub
replace submissionnotificationreceived = "7/31/2025" if submissionnotificationreceived=="7/32/2025"
* Generate date from string from Month-Day-Year (MDY)
gen date_sub = date(submissionnotificationreceived, "MDY")
	la var date_sub "Date Submitted"






* Assuming your string variable is called 'date_str'
gen date_sub2 = date(submissionnotificationreceived, "DMY")

replace date_sub = date_sub2 if date_sub ==.

* DATE FORMATS
* Date format as ddmonyy
format date_sub %tdddmonyy

* Generate year, month, quarter from date_sub

* Extract Year
gen year_sub = year(date_sub)

* Extract Quarter
gen quarter_sub = quarter(date_sub)

* Extract Month
gen month_sub = month(date_sub)


* order
order sequence count tulipid* date_sub unit tulipdecision

* distincts
distinct tulipid*


**** duplicate tags

duplicates tag title, gen(duptitle)
la var duptitle "Duplicates: Title"

duplicates tag tulipid date_sub, gen(dup_id_date_sub)
la var dup_id_date_sub "Duplicates: ID and Date"

**** missings tags
* no decision
missings tag decision, gen(mis_decision)
la var mis_decision "Missing: Decision"

** Create a counter by id and date
*** method 1 same dates have different sequence sequence crosses phases
sort phase tulipid date_sub
bysort tulipid: gen wf_seq = _n
la var wf_seq "Workflow sequenceby phase, id and date"

*** method 2 sequence restarts per phase
sort phase tulipid date_sub
bysort phase tulipid : gen wf_seq2 = _n

drop wf_seq2

bysort phase tulipid date_sub : gen wf_seq2 =_n
la var wf_seq2 "Workflow sequence by phase and id with tied dates having same seq"


* Generate a new variable with the first 20 characters
gen ti_short = substr(title, 1, 20)
*** generate year_Sub
***** REPORT

** Recode missing decision
* Replace system missing (.) with extended missing (.a)
replace decision = .a if decision == .

display "End of clean.do"
