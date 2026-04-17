/* template_1e.do
Juan Solon
2024 Oct 13

Notes
	1. This creates a table 1 with a supercolumn, column, and rows of variables with N, mean, median, geometric mean, counts and percentages.
	2. The latest copy of this template will be found in github.
	3. Input : This template use nhanes2l
	4. Output : Table 1 in .docx  /* needs further resizing of columns manually in word*/ - if coded column width will need putdocx
	5. Output : Table 1 in html /* this is for ease of viewing*/
	6.  Coding notes
	- Percentages must compare columns and requires using "i." before the categorical variable in the code and "across()"
	- every summary statistic is placed as a separate line for ease of revision.
	- Use indents in code for clarity 
	- the IQR, and confidence intervals have to be combined into one column see statalist suggestion (see sources)
	

Pending 
	1. Geometric means CIs 	- geometric means and CIs are part of the stats of table command, but geometric mean CIs must be collected using ameans
	2. statistical tests and p values

	
How to use
	1. Save as whatever.do in wherever/you/want, then revise accordingly.
	2. This template uses local macros which the user has to revise.  Since this is a local macro, you need to run the macros and the table generation in one run.
	3. You need to revise the macros
	- your dataset
	- your supercolumn, column
	- all your variables as continuous reporting means, continuous reporting medians,  continuous reporting GM
	- categorical variables
	- indicator variables
	4.  Check the gen N = 1 .   used in frequencies/group. Assumes that all that  in the dataset are included in the analysis.  If not, revise accordingly.
	5. Check desired number formats and string formats /*note that revising strings can cause problems if not done properly*/
	6. THERE IS NO NEED TO MODIFY ANYTHIGN BEYOND LINE 116 which creates local notes3 text
	
Sources

	*Stata Blog by Chuck Huber

	the Classit Table 1 for Stata 17
	https://blog.stata.com/2021/06/24/customizable-tables-in-stata-17-part-3-the-classic-table-1/

	* Statalist 
	code for formatting iqr using collect.
	https://www.statalist.org/forums/forum/general-stata-discussion/general/1690975-formatted-iqr-using-collect

	* German Rodriguez
	https://grodri.github.io/stata/tables

*/

** Use dataset /*path to your analysis dataset*/
*local dataset "nhanes2l"

*. Use dataset /* revise as use*/

* webuse `dataset', clear

* CREATE A COUNT VARIABLE - modify accordingly - this should count the analysis dataset for the table ; used in frequency stats

capture drop N
gen N=1

* RELABEL CONTINUOUS VARIABLES FOR TABLE /* Revise as you would want to appear in table*/

*label variable age "Age in years;  Mean(SD)"
*label variable bmi "BMI ; Mean(SD)"
*label variable hgb "Haemoglobin (g/dL)  ; Median(p25 - p75)"
* label variable zinc "Serum Zinc (mcg/dL)  ; Geometric Mean (CI)"

* CREATE LOCAL MACROS FOR VARIABLES IN TABLE - USE COMPLETE VARIABLE NAME)
	*local scol "year_sub"
	local col "year_sub"
	*local contn "age bmi" /*continous variables; mean (sd) will be reported*/
	*local contmed "hgb"  /*continous variables; median (p25-p75)  will be reported*/
	*local contgm "zinc"  /*continous variables geometric mean (sd) will be reported*/
	local cat "quarter_sub" /* categorical with multiple levels n(%) */
	*local ind "sex" 

* CREATE LOCAL MACROS FOR STANDARD TABLE HEADER 
	local colhead1 "Year"

	local colhead2 `"0 "grpa" 1 "grpb""'
		
* IDENTIFY ROW VARIABLE HEADERS TO HIDE (SHOWING ONLY LEVELS - EG MALE FEMALE AND NO "SEX")		

* local hiderows "sex"

* NUMBER FORMATS

* format freq /* requires knowledge of levels*/ use collect levelsof [dim/level] to inspect

local frmt_catvar1 "1.quarter 2.quarter 3.quarter 4.quarter"
local nfrmt_freq "%5.0f"

* format percent  of catvar1
local nfrmt_perc "%5.0f" 
local sfrmt_perc "%s%%"

* format means of `contn'
local nfrmt_mean "%5.0f"
local nfrmt_sd "%5.0f"
local sfrmt_sd "(%s)"

* format median of `contmed'
local nfrmt_p50 "%5.0f"
local nfrmt_iqr "%5.0f"
local sfrmt_p25 "(%s -"
local sfrmt_p75 "%s)"

* Table Text /* Revise */ - comment out local notes4 for publication;

local title "Table 9. Submissions by Quarter"

local notes1 "Shows all products first submission for both phases"
local notes2 "Compare Q1 for all 3 years"
local notes3 "Compare Q2 for 2024 and 2025 only"
* local notes4 "Created by "`c(username)'" on "`c(current_date)'" at "`c(current_time)'"  based on  "`c(filename)'""

* STOP !  STOP !  STOP !  STOP !  STOP !  STOP !  STOP !  STOP !  STOP !  STOP !  STOP !  STOP !  STOP !  STOP !  
* THERE IS NOTHING TO MODIFY BEYOND THIS LINE UNLESS CHANGING CODE. 

* GENERATE TABLE STATS 

	table (var)(`col') , ///
		stat(count N) ///
		stat(fvfrequency `cat') ///
		stat(percent i.`cat', across(`col')) ///
			nototals ///
			nformat(%5.0f percent) ///
			nformat(%5.1f mean p25 p50 p75) ///
			nformat(%5.2f sd) 

*REFORMAT RESULTS TO DESIRED COLUMNS

	* recodes mean and sd in the collection to columns 1 and 2
		collect recode result count = column1
		collect recode result mean = column1
		collect recode result sd = column2

	* recodes fvfrequency and percent in the collection to columns 1 and 2
		collect recode result fvfrequency = column1
		collect recode result percent = column2
		
	* recodes median and iqr
		collect recode result p50 = column1
		collect recode result p25 = column2
		collect recode result p75 = column3
		
	* Create composite result : this is needed because 75 is in column3 and we want it in the same column as column 2 .  Use for medians and probably CIs
		collect composite define column4 = column2 column3, replace

	* collect label list result, all - used to see results

* CREATE THE TABLE 1 Layout Super column - column 

	* collect layout (var) (region#diabetes#result[column1 column2])

	collect layout (var) (`scol'#`col'#result[column1 column4])


* CHANGE HEADER TEXT
	* supercolumn
		collect label dim `scol' "`colhead1'", modify
	* column
		collect label levels `col' `colhead2', modify

collect preview /* preview changes */

* HIDE COLUMN HEADERS

	* Hide supercolumn variable name because it is self-descriptive
		
		collect style header `scol', title(hide) /* this removes the column variable name or label by hiding it */

	* Hide the column variable name 
		
		collect style header `col', title(hide) /* this removes the column variable name or label by hiding it */

	* Hide the words column 1 and column 2 for the results 

		collect style header result, level(hide) /* this removes column 1 and column2 header names*/

collect preview /* preview changes */

* MODIFY ROW TEXT


* REVISE ROW STYLES

* Stack levels of each variable , place a space between variables (spacer) ; 

	collect style row stack, nobinder spacer

* Remove vertical line after variables

	collect style cell border_block, border(right, pattern(nil))

* HIDE ROW Text

* Hide the variable names 
collect style header `hiderows', title(hide)


* FORMAT NUMBERS

* Format median

	collect style cell result[column1]#var[`contmed'], nformat(`nfrmt_p50')

* Add IQR formatting to p25 and p75 separately:
	collect style cell result[column2]#var[`contmed'], nformat(`nfrmt_iqr') sformat("`sfrmt_p25'") /* formats iqr as (p25 - p75)*/
	collect style cell result[column3]#var[`contmed'], nformat(`nfrmt_iqr') sformat("`sfrmt_p75'") 


* format factor variables (categorical) column 1 and column 2

	collect style cell var[`frmt_catvar1']#result[column1], nformat(`nfrmt_freq')

	collect style cell var[`frmt_catvar1']#result[column2], nformat(`nfrmt_perc') sformat("(`sfrmt_perc')") /* Adds (%) to percent */

* format means variable column 1 and column 2

	collect style cell var[`contn']#result[column1], nformat(`nfrmt_mean') /* Formats continuous variable to one decimal*/

	collect style cell var[`contn']#result[column2], nformat(`nfrmt_sd') sformat(`sfrmt_sd') /* Formats continuous variable to one decimal*/

* Change font of results
	*collect style cell var[`contn']#result[column1], nformat(`nfrmt_mean') /* Formats continuous variable to one decimal*/
	
* Add text
	collect title `title'
	collect notes `notes1'
	collect notes `notes2'
	collect notes `notes3'
	collect notes `notes4'
	
* Export
	collect export preview.html, as(html) replace
	collect export preview.docx, as(docx) replace
	collect export preview.xlsx, as(xlsx) replace

	
/* END END END END END END END END END END END END END END END END END END END END */
	

/* archived notes


* Export to Word
* Check your present working directory as this file saves there.  Alternatively ,specify relative path

cd "$dropboxradio" /* change to your pwd or any desired folder */

putdocx begin /* Start of Word Input*/
	putdocx paragraph, style(Heading1)
		putdocx text ("Table 1. Participant Charateristics")
	putdocx paragraph, style(Heading1)
		putdocx text ("x") 
	putdocx paragraph
		putdocx text ("stuff ") 
		putdocx text ("stuff stuff ")
		putdocx text ("stuff stuff stuff .")
	collect style putdocx, layout(autofitcontents) ///  use layout(autofitcontents) to retain original width of table */
/*	title("Table 1: Charateristics by Cohort and Nutritional STatus")
	putdocx collect /*exports our table to the document*/
	putdocx save template_tab1.docx, replace
*/

*cd "$dropboxradio" /* change to your pwd or any desired folder */

/* Other summaries 

table (var) (sex), statistic(p50 age_adm_m) statistic(p25 age_adm_m) statistic(p75 age_adm_m) nototals
collect style cell result[p25 p50 p75], nformat("%4.1f")
collect composite define iqr = p25 p75 , delimiter(" - ") trim
collect style cell result[iqr], sformat("(%s)")
collect composite define mediqr = p50 iqr, trim

collect style header result, level(hide)
collect style row stack, nobinder spacer
collect style cell border_block, border(right, pattern(nil))
collect layout (var) (sex#result[mediqr])

  