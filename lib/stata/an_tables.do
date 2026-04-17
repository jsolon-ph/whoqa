/* Tables */


***** CREATE PROGRAM STYLEs : valid for this stata session
capture program drop style_a
capture program drop style_b
capture program drop style_c
program define style_a
    syntax, name(string)
    
    * Label
    collect label dim year_sub "Year", name(`name') modify
	* Style
    collect style header year_sub, title(hide) name(`name')
    collect style cell result[fvfrequency], nformat(%5.0f) name(`name')
    collect style cell result[percent], nformat(%5.1f) sformat("%s%%") name(`name')
    collect style header result, title(hide) name(`name')
    *collect style cell, halign(left) name(`name')
end


***** CREATE EXPORT PROGRAM
program define exp_docx
	syntax, name(string)

	collect export docs/`name'.docx, name(`name') replace
end
	
***** TABLES

collect clear

* Table 1: All data
dtable i.phase i.decision, ///
	by(year_sub) name(tab1) replace ///
	title("Table 1 All Submissions")
	
style_a, name(tab1)
collect preview

exp_docx, name(tab1)

* Table 2: Filtered data (wf_seq == 1)

dtable i.phase i.decision if wf_seq == 1 & unit<6, ///
	by(year_sub) name(tab2) ///
	title("Table 2 First Submissions")
	
style_a, name(tab2)
collect preview

exp_docx, name(tab2)

* Table 3 : Decisions by year, Planning ; with test for trend and chi square 

nptrend decision ///
	if phase==1 & wf_seq==1 & inlist(decision, 1, 2, 3), ///
	group(year) cuzick
	
local trendp1 :  display %9.4f r(p)
	
dtable i.decision  ///
	if wf_seq==1 & ///
	inlist(decision, 1, 2, 3) & ///
	phase==1 ///
	& unit<6, ///
	by(year_sub, tests) name(c3) ///
	title("Table 3 Planning Phase : Initial Decision by Year per unique product") ///
	notes(Test for trend p=`trendp1')
	
* 2. Modify the header labels for the collection named 'c3'
collect label dim year_sub "Year", name(c3)
collect preview

* 3. Hide the title (the word "Year") so it doesn't repeat or look cluttered
collect style header year_sub, title(hide) name(c3)
collect preview

* 4. Export the table
collect export docs/table3.docx, name(c3) replace
		


collect style row stack, nobinder nospacer name(c3)
collect preview 

* Table 4 : Decisions by year, Executive

* 1. Create stats and dtable
nptrend decision ///
	if phase==2 & wf_seq==1 & inlist(decision, 1, 2, 3), ///
	group(year) cuzick
local trendp2 :  display %9.4f r(p)

nptrend decision ///
	if phase==2 & wf_seq==1 & inlist(decision, 1, 2, 3) & year_sub!=2026, ///
	group(year) cuzick
local trendp3 :  display %9.4f r(p)


dtable i.decision  ///
	if wf_seq==1 & ///
	inlist(decision, 1, 2, 3) & ///
	phase==2 ///
	& unit<6, ///
	by(year_sub, tests) name(c4) ///
	title("Table 4 Executive Phase : Initial Decision by Year per unique product") ///
	notes(Test for trend p=`trendp2' and p = `trendp3' without 2026)
		
* 2. Modify the header labels for the collection named 'c4'
collect label dim year_sub "Year", name(c4)
collect preview

* 3. Hide the title (the word "Year") so it doesn't repeat or look cluttered
collect style header year_sub, title(hide) name(c4)
collect preview

collect style row stack, nobinder nospacer name(c4)
collect preview 

* 4. Export the table
collect export docs/table4.docx, name(c4) replace
		

* Table 5
collect clear
dtable i.decision  ///
	if wf_seq==1 & ///
	inlist(decision, 1, 2, 3) & ///
	phase==1 ///
	& unit<6, ///
	by(unit, tests) name(c5) ///
	title("Table 5 Planning Phase : Initial Decision by Unit per unique product") 

* 2. Modify the header labels for the collection named 'c4'
collect label dim year_sub "Year", name(c5)
collect preview

* 3. Hide the title (the word "Year") so it doesn't repeat or look cluttered
collect style header year_sub, title(hide) name(c5)
collect preview

collect style row stack, nobinder nospacer name(c5)
collect preview 

* 4. Export the table
collect export docs/table5.docx, name(c5) replace
	
* Table 6
collect clear
dtable i.decision  ///
	if wf_seq==1 & ///
	inlist(decision, 1, 2, 3) & ///
	phase==2 ///
	& unit<6, ///
	by(unit, tests) name(c6) ///
	title("Table 6 Executive Phase : Initial Decision by Unit per unique product") 
	

* 2. Modify the header labels for the collection named 'c4'
collect label dim year_sub "Year", name(c6)
collect preview

* 3. Hide the title (the word "Year") so it doesn't repeat or look cluttered
collect style header year_sub, title(hide) name(c6)
collect preview

collect style row stack, nobinder nospacer name(c6)
collect preview 

* 4. Export the table
collect export docs/table6.docx, name(c6) replace

* Table 7
collect clear
dtable i.product  ///
	if wf_seq==1 & ///
	inlist(decision, 1, 2, 3) & ///
	phase==1 ///
	& unit<6, ///
	by(decision, tests) name(c7) ///
	title("Table 7 Planning Phase : Initial Decision by Product Type per unique product") 
	

* 2. Modify the header labels for the collection named 'c7'
collect label dim decision "Decision", name(c7)
collect preview

* 3. Hide the title (the word "Year") so it doesn't repeat or look cluttered
collect style header decision, title(hide) name(c7)
collect preview

collect style row stack, nobinder nospacer name(c7)
collect preview 

* 4. Export the table
collect export docs/table7.docx, name(c7) replace
	
* Table 8
collect clear
dtable i.product  ///
	if wf_seq==1 & ///
	inlist(decision, 1, 2, 3) & ///
	phase==2 ///
	& unit<6, ///
	by(decision, tests) name(c8) ///
	title("Table 8 Executive Phase : Initial Decision by Product Type per unique product") 

	* 2. Modify the header labels for the collection named 'c7'
collect label dim decision "Decision", name(c8)
collect preview

* 3. Hide the title (the word "Year") so it doesn't repeat or look cluttered
collect style header decision, title(hide) name(c8)
collect preview

collect style row stack, nobinder nospacer name(c8)
collect preview 

* 4. Export the table
collect export docs/table8.docx, name(c8) replace

* Table 9

gen N = 1

collect clear

tab quarter_sub year_sub if quarter!=1 & year_sub<2026, chi

	table (var)(year) , ///
		stat(count N) ///
		stat(fvfrequency quarter) ///
		stat(percent i.quarter, across(year)) ///
			nformat(%5.0f percent) ///
			nformat(%5.1f mean p25 p50 p75) ///
			nformat(%5.2f sd) ///
			name(c9)
			

	* recodes fvfrequency and percent in the collection to columns 1 and 2
		collect recode result fvfrequency = column1
		collect recode result percent = column2

		collect layout (var) (year_sub#result[column1 column2])
collect dims
collect label list dim

		collect label dim year_sub "Year", name(c9)
		collect label dim quarter_sub "Quarter", name(c9)
		

		collect label levels quarter_sub 1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4", name(c9) modify
		collect style header quarter_sub, level(label) name(c9)
		* Hides "quarter_sub=" and just shows "Q1", "Q2", etc.
collect style header quarter_sub, title(hide) name(c9)
* Rename the result statistics
collect label levels result column1 "N" column2 "%", modify name(c9)

* Hide the header title "result" if it appears
collect style header result, title(hide) name(c9)




* 1. Format the frequency (N) - remove decimals
collect style cell result[column1], nformat(%5.0f) name(c9)

* 2. Format the percent (%) - keep one decimal and add the symbol
collect style cell result[column2], nformat(%5.1f) sformat("%s%%") name(c9)

* 3. Refresh preview
collect preview, name(c9)


collect title "Table 9 Initial Submissions by Quarter"
collect notes, clear
	collect notes "Shows first submission of each product regardless of Phase."
	collect notes "Quarter 1 can be compared for 2024-2026"
	collect notes "Quarters 2-4 can be compared for 2025-2026"

	
	collect preview
* Export

	collect export docs/table9.docx, name(c9) as(docx) replace

* Table 10

capture drop N
gen N = 1

collect clear

tab month_sub year_sub if quarter==1 , chi col
local pchi :  display %9.4f r(p)

nptrend month_sub ///
	 if quarter==1 , ///
	group(year_sub) cuzick

	table (var)(year)  if quarter==1 , ///
		stat(count N) ///
		stat(freq) ///
		stat(fvfrequency month_sub) ///
		stat(fvpercent i.month_sub) ///
			nformat(%5.0f percent) ///
			nformat(%5.1f mean p25 p50 p75) ///
			nformat(%5.2f sd) ///
			name(tab10) replace

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
		// Rename the rows for the final table
collect label levels var Total_N "Total N", modify
collect label levels var 1.month_sub "Jan", modify
collect label levels var 2.month_sub "Feb", modify
collect label levels var 3.month_sub "Mar", modify
collect label levels result column1 "N" column2 "%", modify name(tab10)

***** HIDE 
* Hides "quarter_sub=" and just shows "Q1", "Q2", etc.
* collect style header quarter_sub, title(hide) name(tab10)
* Rename the result statistics

* Hide the header title "result" if it appears
* collect style header result, title(hide) name(tab10)

***** FORMAT 
* 1. Format the frequency (N) - remove decimals
collect style cell result[column1], nformat(%5.0f) name(tab10)

* 2. Format the percent (%) - keep one decimal and add the symbol
collect style cell result[column2], nformat(%5.1f) sformat("%s%%") name(tab10)

* 3. Refresh preview
collect preview, name(tab10)


collect title "Table 10 All Submissions Quarter 1 ; 3 Years"
collect notes, clear
collect notes "χ² p-value = `pchi'"
collect preview, name(tab10)

exp_docx, name(tab10)


* Table 11 - as table 10 but filtered for first submission wf_seq==1

capture drop N
gen N = 1

collect clear
local if "if quarter==1 & wf_seq==1"
* "Filtered for first submission"

tab month_sub year_sub `if' , chi col
local pchi :  display %9.4f r(p)

nptrend month_sub ///
	 `if' , ///
	group(year_sub) cuzick

	table (var)(year) `if' , ///
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

***** RECODES N AND COUNTS  
collect recode var N = Total_N
collect recode result count = column1

***** CREATE  LAYOUT
collect layout (var) (year_sub#result[column1 column2])
		
***** LABELS 
		collect label dim year_sub "Year", name(tab11)
		collect label dim quarter_sub "Quarter", name(tab11)
		collect label levels quarter_sub 1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4", name(tab11) modify
		collect style header quarter_sub, level(label) name(tab11)
		// Rename the rows for the final table
collect label levels var Total_N "Total N", modify
collect label levels var 1.month_sub "Jan", modify
collect label levels var 2.month_sub "Feb", modify
collect label levels var 3.month_sub "Mar", modify
collect label levels result column1 "N" column2 "%", modify name(tab11)

***** HIDE 
* Hides "quarter_sub=" and just shows "Q1", "Q2", etc.
* collect style header quarter_sub, title(hide) name(tab11)
* Rename the result statistics

* Hide the header title "result" if it appears
* collect style header result, title(hide) name(tab11)

***** FORMAT 
* 1. Format the frequency (N) - remove decimals
collect style cell result[column1], nformat(%5.0f) name(tab11)

* 2. Format the percent (%) - keep one decimal and add the symbol
collect style cell result[column2], nformat(%5.1f) sformat("%s%%") name(tab11)

* 3. Refresh preview
collect preview, name(tab11)


collect title "Table 11 First Submissions Quarter 1 ; 3 Years"
collect notes, clear
collect notes "χ² p-value = `pchi'"
collect preview, name(tab11)

exp_docx, name(tab11) 



