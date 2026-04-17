/* Tables 
an_tables.do
Path ./lib/stata/
Used by : master.do
Requires macros.do, packages.do, clean.do, cr_units.do to be run first
Purpose : Creates tables
Note :Uses project specific defined programs within this .do file
*/

***** CREATE PROGRAM STYLEs : valid for this stata session
capture program drop style_a
capture program drop exp_docx

**** Table Styles
program define style_a
    syntax, name(string)
    
    * Label dimensions
    collect label dim year_sub "Year", name(`name') modify
	collect label dim quarter_sub "Quarter", name(`name')
	* Label levels
	* Style
    collect style header year_sub, title(hide) name(`name')
	collect style header quarter_sub, level(label) name(`name')
    collect style cell result[fvfrequency], nformat(%5.0f) name(`name')
    collect style cell result[percent], nformat(%5.1f) sformat("%s%%") name(`name')
    collect style header result, title(hide) name(`name')

end

program define recode_a
	syntax, name(string)
	
end

***** Export to docx, replace
program define exp_docx
	syntax, name(string)

	collect export docs/`name'.docx, name(`name') replace
end
	
***** TABLES

	collect clear
	
***  CREATE MACROS FOR CONDITIONS FOR TABLES AND TESTS 
	local if1 ""
	local if2 "if quarter==1 & unit < 6"
	local if3 "if wf_seq==1 & inlist(decision, 1, 2, 3) & phase==1 & unit<6"
	local if4a "if wf_seq==1 & inlist(decision, 1, 2, 3) & phase==2 & unit<6"
	local if4b "if wf_seq==1 & inlist(decision, 1, 2, 3) & phase==2 & unit<6 & year_sub!=2026"
	local if5 "if wf_seq==1 & inlist(decision, 1, 2, 3) & phase==1 & unit<6"
	local if6 "if wf_seq==1 & inlist(decision, 1, 2, 3) & phase==2 & unit<6"
	local if7 "if wf_seq==1 & inlist(decision, 1, 2, 3) & phase==1 & unit<6"
	local if8 "if wf_seq==1 & inlist(decision, 1, 2, 3) & phase==2 & unit<6"
	local if9 "if quarter!=1 & year_sub<2026"
	local if10 "if quarter==1"
	local if11 "if quarter==1 & wf_seq==1"
	
	
*** TABLE 1 ALL DATA 
	dtable i.phase i.decision `if1', ///
		by(year_sub) name(tab1) replace ///
		title("Table 1 All Submissions")
		
	style_a, name(tab1)
	collect preview

	exp_docx, name(tab1)

*** TABLE 2 ALL DATA (wf_seq == 1)
	local if2 "if quarter==1 & unit < 6"
	display "`if2'"
	
	dtable i.phase i.decision `if2', ///
	by(year_sub) name(tab2) replace ///
	title("Table 2 First Submissions")
		
	style_a, name(tab2)
	collect preview

exp_docx, name(tab2)

*** TABLE 3 : Decisions by year, Planning ; with test for trend and chi square 

	local if3 "if wf_seq==1 & inlist(decision, 1, 2, 3) & phase==1 & unit<6"
	display "`if3'"
	
	nptrend decision ///
	`if3', ///
	group(year) cuzick

	local trendp1 :  display %9.4f r(p)
	display "`if3'"
	dtable i.decision `if3', ///
		by(year_sub, tests) name(tab3) replace ///
		title("Table 3 Planning Phase : Initial Decision by Year per unique product") ///
		notes(Test for trend p=`trendp1')
		
	style_a, name(tab3)
	collect preview
	exp_docx, name(tab3)

exp_docx, name(tab3)
	
*** TABLE 4 : Decisions by year, as table 3 but Executive (Phase =2)

	local if4a "if wf_seq==1 & inlist(decision, 1, 2, 3) & phase==2 & unit<6"
	local if4b "if wf_seq==1 & inlist(decision, 1, 2, 3) & phase==2 & unit<6 & year_sub!=2026"
	display "`if4a'"
	display "`if4b'"

	nptrend decision ///
		`if4a', ///
		group(year) cuzick
	local trendp2 :  display %9.4f r(p)

	nptrend decision ///
		`if4b', ///
		group(year) cuzick
	local trendp3 :  display %9.4f r(p)
	
	display "`if4a'"
	dtable i.decision  ///
		`if4a', ///
		by(year_sub, tests) name(tab4) replace ///
		title("Table 4 Executive Phase : Initial Decision by Year per unique product") ///
		notes(Test for trend p=`trendp2' and p = `trendp3' without 2026)
		
	style_a, name(tab4)
	collect preview
	
	exp_docx, name(tab4)
		
*** TABLE 5 : Planning Phase : Initial Decision by Unit per unique product 
	local if5 "if wf_seq==1 & inlist(decision, 1, 2, 3) & phase==1 & unit<6"
	display "`if5'"
	
	dtable i.decision  ///
		`if5', ///
		by(unit, tests) name(tab5) replace ///
		title("Table 5 Planning Phase : Initial Decision by Unit per unique product") 

	style_a, name(tab5)
	collect preview
	
	exp_docx, name(tab5)
	
*** TABLE 6 Executive Phase : Initial Decision by Unit per unique product

	local if6 "if wf_seq==1 & inlist(decision, 1, 2, 3) & phase==2 & unit<6"
	display "`if6'"

	dtable i.decision  ///
		`if6', ///
		by(unit, tests) name(tab6) replace ///
		title("Table 6 Executive Phase : Initial Decision by Unit per unique product") 
		
	style_a, name(tab6)
	collect preview
	
	exp_docx, name(tab6)

*** TABLE 7 Planning Phase : Initial Decision by Product Type per unique product
	local if7 "if wf_seq==1 & inlist(decision, 1, 2, 3) & phase==1 & unit<6"
	display "`if7'"

	dtable i.product  ///
		`if7', ///
		by(decision, tests) name(tab7) replace ///
		title("Table 7 Planning Phase : Initial Decision by Product Type per unique product") 
		
	style_a, name(tab7)
	collect preview
	
	exp_docx, name(tab7)
	
*** TABLE 8 Executive Phase : Initial Decision by Product Type per unique product

	local if8 "if wf_seq==1 & inlist(decision, 1, 2, 3) & phase==2 & unit<6"
	display "`if8'"
	
	dtable i.product  ///
		`if8', ///
		by(decision, tests) name(tab8) replace ///
		title("Table 8 Executive Phase : Initial Decision by Product Type per unique product") 

	style_a, name(tab8)
	collect preview
	
	exp_docx, name(tab8)

*** TABLE 9 Initial Submissions by Quarter regardless of Phase

	local if9 "if quarter!=1 & year_sub<2026"
	capture drop N
	gen N = 1
	
	display "`if9'"
	tab quarter_sub year_sub `if9' 

	table (var)(year) , ///
		stat(count N) ///
		stat(fvfrequency quarter) ///
		stat(percent i.quarter, across(year)) ///
			nformat(%5.0f percent) ///
			nformat(%5.1f mean p25 p50 p75) ///
			nformat(%5.2f sd) ///
			name(tab9) replace
	
	* Add Titles and Notes
		collect title "Table 9 Initial Submissions by Quarter"
		
		collect notes, clear
		collect notes "Shows first submission of each product regardless of Phase."
		collect notes "Quarter 1 can be compared for 2024-2026"
		collect notes "Quarters 2-4 can be compared for 2025-2026"
	
	* recodes fvfrequency and percent in the collection to columns 1 and 2
		collect recode result fvfrequency = column1
		collect recode result percent = column2
		
	* Collect Layout : moves frequencies and percent to same row in two columns
		collect layout (var) (year_sub#result[column1 column2])
		
	* Label dimensions
		collect label dim year_sub "Year", name(tab9)
		collect label dim quarter_sub "Quarter", name(tab9)
		
	* Label levels 
		collect label levels result column1 "N" column2 "%", modify name(tab9)
		collect label levels quarter_sub 1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4", name(tab9) modify
		
	* Style Headers
		collect style header quarter_sub, title(hide) name(tab9)
		collect style header result, title(hide) name(tab9)
		
	* Style Cells : Format Numbers and Strings

		collect style cell result[column1], nformat(%5.0f) name(tab9)
		collect style cell result[column2], nformat(%5.1f) sformat("%s%%") name(tab9)
	collect preview
	* Export
		exp_docx, name(tab9)


*** Table 10 All Submissions Quarter 1 ; 3 Years

	local if10 "if quarter==1"
	capture drop N
	gen N = 1

	*** TESTS 
	display "`if10'"
	tab month_sub year_sub `if10' , chi col
	local pchi :  display %9.4f r(p)

	nptrend month_sub ///
		 `if10' , ///
		group(year_sub) cuzick

	table (var)(year) `if10' , ///
		stat(count N) ///
		stat(freq) ///
		stat(fvfrequency month_sub) ///
		stat(fvpercent i.month_sub) ///
			nformat(%5.0f percent) ///
			nformat(%5.1f mean p25 p50 p75) ///
			nformat(%5.2f sd) ///
			name(tab10) replace
			
	* ADD TEXT
	
		collect title "Table 10 All Submissions Quarter 1 ; 3 Years"
		collect notes, clear
		collect notes "χ² p-value = `pchi'"

	***** RECODES results to columns 1 and 2 
		collect recode result fvfrequency = column1
		collect recode result fvpercent = column2

	***** RECODES N AND COUNTS  
		collect recode var N = Total_N
		collect recode result count = column1

	***** CREATE  LAYOUT
		collect layout (var) (year_sub#result[column1 column2])
			
	***** LABELS 
		collect label dim year_sub "Year", name(tab10)
		collect label dim quarter_sub "Quarter", name(tab10)
		collect label levels quarter_sub 1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4", name(tab10) modify
		collect style header quarter_sub, level(label) name(tab10)
		
		collect label levels var Total_N "Total N", modify
		collect label levels var 1.month_sub "Jan", modify
		collect label levels var 2.month_sub "Feb", modify
		collect label levels var 3.month_sub "Mar", modify
		collect label levels result column1 "N" column2 "%", modify name(tab10)

	***** Style Cells : Format strings and numbers  

		collect style cell result[column1], nformat(%5.0f) name(tab10)
		collect style cell result[column2], nformat(%5.1f) sformat("%s%%") name(tab10)

	* 3. Refresh preview
		collect preview, name(tab10)

	exp_docx, name(tab10)


*** TABLE 11 - First Submissions Quarter 1 ; 3 Years

	capture drop N
	gen N = 1

	local if11 "if quarter==1 & wf_seq==1"


	*** TESTS 
	display "`if11'"
	
	tab month_sub year_sub `if11' , chi col
	local pchi :  display %9.4f r(p)

	nptrend month_sub ///
	 `if11' , ///
	group(year_sub) cuzick

	display "`if11'"
	table (var)(year) `if11' , ///
		stat(count N) ///
		stat(freq) ///
		stat(fvfrequency month_sub) ///
		stat(fvpercent i.month_sub) ///
			nformat(%5.0f percent) ///
			nformat(%5.1f mean p25 p50 p75) ///
			nformat(%5.2f sd) ///
			name(tab11) replace

	***** RECODES results to columns 1 and 2 
		collect recode result fvfrequency = column1
		collect recode result fvpercent = column2
		collect recode result count = column1
	***** RECODES VAR 
		collect recode var N = Total_N

	***** COLLECT LAYOUT  LAYOUT
		collect layout (var) (year_sub#result[column1 column2])
		
	***** LABEL DIMENSIONS 
		collect label dim year_sub "Year", name(tab11)
		collect label dim quarter_sub "Quarter", name(tab11)
		collect label levels quarter_sub 1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4", name(tab11) modify
		
	***** LABEL LEVELS

		collect label levels var Total_N "Total N", modify
		collect label levels var 1.month_sub "Jan", modify
		collect label levels var 2.month_sub "Feb", modify
		collect label levels var 3.month_sub "Mar", modify
		collect label levels result column1 "N" column2 "%", modify name(tab11)
	
	***** STYLE HEADER

		collect style header quarter_sub, level(label) name(tab11)
	
	***** Style Cells : Format strings and numbers  
	
		collect style cell result[column1], nformat(%5.0f) name(tab11)
		collect style cell result[column2], nformat(%5.1f) sformat("%s%%") name(tab11)

	* 3. Refresh preview
		collect preview, name(tab11)

	exp_docx, name(tab11) 
	
	display "End of an_tables.do"



