/* clean.do
April 15 2026
Reads xls
Makes rectangular
Adds year
Adds unique row id
Adds item id to each relevant row with blank ids
NOTE: this generates wf_seq which is used in tables
*/

***** SETUP

clear
set more off
capture log close
log using logs/log.txt, replace
cd ~/Downloads

***** GLOBALS
global whoqa ~/github/personal/whoqa

***** WORKING DIRECTORY
cd ~
cd $whoqa

***** IMPORT
	import excel using "data/raw/Submissions tally 14Apr2026 QA compliance.xlsx", ///
					sheet("Overall.2024-25 (30Apr2025)") ///
					firstr ///
					clear
***** CONVERT VARS TO LOWERCASE
	rename *, lower

***** SHORT VAR FOR CONVENIENCE
rename healthpromotiondiseasepreven hpdpc

* Generate a new variable with the first 20 characters
gen ti_short = substr(title, 1, 20)

***** IDS
*** Wrong tulip id "Q-2024-00310"
	replace tulipid ="HQ-2024-00310 " if tulipid =="Q-2024-00310"

*** Trim spaces

* List string vars
	ds, has(type string)
* trim in a loop
	foreach v of varlist `r(varlist)' {

		* Display the name of the variable being processed
		display "Cleaning variable: `v'"

		* Clean the variable
		replace `v' = trim(ustrtrim(`v'))
		replace `v' = subinstr(`v', char(160), "", .)
		replace `v' = trim(`v')
	}

***** EMPTY ROWS
drop if count==.
drop if tulipid=="next"
gen sequence = _n


* create id for each obs
* rename tulipid tulipid_original
* carryforward tulipid_original, gen(tulipid)
* N = 5198
* drop rows with next as id

***** DROPPING COMMENTS

drop if tulipid==""

**** COUNT CHECK
* distincts
missings report tulipid
distinct tulipid

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

*** gen byte unit for tables
	encode unit_str, gen(unit)
	la var unit "Division"
	drop unit_str
	label drop unit
	label define unit 1 "GPA" 2 "WHE" 3 "HSD" 4 "PPC" 5 "SCI"

*** encode byte decision for tables
	encode tulipd, gen(tulipd2)
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

*** normative products
	capture drop norma2
	encode norma, gen(product)
	label define product 14 "Other", modify
	label variable product "Normative Products"

***** DATES

*** CORRECT DATA: replace 2023 to 2024 for two obs
	replace submissionnotificationreceived = "7/14/2024" if submissionnotificationreceived =="7/14/2023"
	replace submissionnotificationreceived = "3/11/2024" if submissionnotificationreceived =="3/11/2023"

*** CORRECT DATA: changes wrong day
	capture drop date_sub
	replace submissionnotificationreceived = "7/31/2025" if submissionnotificationreceived=="7/32/2025"

*** CONVERT DATE STRING TO STATA DATE
* Generate date from string from Month-Day-Year (MDY)
	gen date_sub = date(submissionnotificationreceived, "MDY")
	la var date_sub "Date Submitted"

* Generate date from string from Month-Day-Year (MDY) - BECAUSE BOTH APPEAR
	gen date_sub2 = date(submissionnotificationreceived, "DMY")
	replace date_sub = date_sub2 if date_sub ==.
	drop date_sub2 

*** FORMAT DATES
* Date format as ddmonyy
	format date_sub %tdddmonyy
*** CREATE YEAR MONTH QUARTER
* Extract Year
	gen year_sub = year(date_sub)
* Extract Quarter
	gen quarter_sub = quarter(date_sub)
* Extract Month
	gen month_sub = month(date_sub)

***** ORDER
	order sequence count tulipid* date_sub unit tulipdecision

**** COUNT CHECK
* distincts
	missings report tulipid
	distinct tulipid

***** DUPLICATES

	duplicates tag title, gen(duptitle)
	la var duptitle "Duplicates: Title"

	duplicates tag tulipid date_sub, gen(dup_id_date_sub)
	la var dup_id_date_sub "Duplicates: ID and Date"

**** missings tags
* no decision
	missings tag decision, gen(mis_decision)
	la var mis_decision "Missing: Decision"

***** COUNT CHECK
* distincts
	missings report tulipid
	distinct tulipid

***** CREATE A WORKFLOW SEQUENCE

*** method  sequence restarts per phase
	sort phase tulipid date_sub
	bysort phase tulipid : gen wf_seq = _n

* verify : sequence should restart at 1 with a phase and should increment with date
	sort tulipid phase date_sub
	* browse tulipid phase wf_seq date_sub
	list  tulipid phase wf_seq date_sub in 1/30

* REPORT
display as text "----------REPORT Ns----------"
	quietly distinct tulipid
display as text "Total Observations with IDS = `r(N)'"
display as text "Total Observations with Distinct IDs = `r(ndistinct)'"
display as text "----------REPORT Missing Variables----------"
	missings report tulipid decision phase date_sub 

display "End of clean.do"
