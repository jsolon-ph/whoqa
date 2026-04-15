/* Tables */

*** All Submissions for phase by year

tab phase year, missing

tab phase year if wf_seq2==1, missing
ret list

collect clear
* Table 1: All data
dtable i.phase i.decision, ///
	by(year_sub) name(all_data)

* Table 2: Filtered data (wf_seq2 == 1)
collect clear
dtable i.phase i.decision if wf_seq2 == 1 & unit<6, ///
	by(year_sub) name(filtered_data)


* Table 3 : Decisions by year, Planning
collect clear

nptrend decision ///
	if phase==1 & wf_seq2==1 & inlist(decision, 1, 2, 3), ///
	group(year) cuzick
	
local trendp1 =r(p)
	
dtable i.decision  ///
	if wf_seq2==1 & ///
	inlist(decision, 1, 2, 3) & ///
	phase==1, ///
	by(year_sub, tests) name(filtered_decision) ///
	title("Table 3 Planning Phase : Initial Decision by Year per unique product") ///
	export(docs/table3.docx, replace) ///
	notes(Test for trend p=`trendp1')
	l;..\\
* Table 4 : Decisions by year, Executive

nptrend decision ///
	if phase==2 & wf_seq2==1 & inlist(decision, 1, 2, 3), ///
	group(year) cuzick
local trendp2 =r(p) 

nptrend decision ///
	if phase==2 & wf_seq2==1 & inlist(decision, 1, 2, 3) & year_sub!=2026, ///
	group(year) cuzick
local trendp3 =r(p) 

collect clear
dtable i.decision  ///
	if wf_seq2==1 & ///
	inlist(decision, 1, 2, 3) & ///
	phase==2, ///
	by(year_sub, tests) name(filtered_decision) ///
	title("Table 4 Executive Phase : Initial Decision by Year per unique product") ///
	export(docs/table4.docx, replace) ///
	notes(Test for trend p=`trendp2' and p = `trendp3' without 2026)

* Table 5


table (unit decision) (year_sub) if decision <4 & phase==1

* Table 6

table (unit decision) (year_sub) if decision <4 & phase==2

