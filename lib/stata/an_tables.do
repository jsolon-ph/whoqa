/* Tables */


collect clear
* Table 1: All data
dtable i.phase i.decision, ///
	by(year_sub) name(c1)
	
* 2. Modify the header labels for the collection named 'c1'
collect label dim year_sub "Year", name(c1)
collect preview

* 3. Hide the title (the word "Year") so it doesn't repeat or look cluttered
collect style header year_sub, title(hide) name(c1)
collect preview

* 4. Export the table
collect export docs/table1.docx, name(c1) replace

* Table 2: Filtered data (wf_seq2 == 1)

dtable i.phase i.decision if wf_seq2 == 1 & unit<6, ///
	by(year_sub) name(c2)

* 2. Modify the header labels for the collection named 'c2'
collect label dim year_sub "Year", name(c2)
collect preview

* 3. Hide the title (the word "Year") so it doesn't repeat or look cluttered
collect style header year_sub, title(hide) name(c2)
collect preview

* 4. Export the table
collect export docs/table2.docx, name(c2) replace

* Table 3 : Decisions by year, Planning


nptrend decision ///
	if phase==1 & wf_seq2==1 & inlist(decision, 1, 2, 3), ///
	group(year) cuzick
	
local trendp1 :  display %9.4f r(p)
	
dtable i.decision  ///
	if wf_seq2==1 & ///
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
	if phase==2 & wf_seq2==1 & inlist(decision, 1, 2, 3), ///
	group(year) cuzick
local trendp2 :  display %9.4f r(p)

nptrend decision ///
	if phase==2 & wf_seq2==1 & inlist(decision, 1, 2, 3) & year_sub!=2026, ///
	group(year) cuzick
local trendp3 :  display %9.4f r(p)


dtable i.decision  ///
	if wf_seq2==1 & ///
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

table (unit decision) (year_sub) if decision<4 & phase == 1 & unit<6, nototal 
table (unit decision) (year_sub) if decision <4 & phase==1 & unit<6, ///

* Table 6

table (unit decision) (year_sub) if decision <4 & phase==2

display "End of an_tables.do"
