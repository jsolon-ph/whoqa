* sankey 



* 1. Sort the data to ensure chronological order
sort tulipid date_sub

* 2. Identify when the phase actually changes
by tulipid: gen phase_change = (phase != phase[_n-1])

* 3. When does decision change 
by tulipid: gen decision_change = (decision != decision[_n-1])

* 3. Keep only the rows where a change happened (plus the starting point)
* This creates a clean "history" for each tulipid
keep if phase_change == 1 | _n == 1

* Create a 'next_phase' variable
sort tulipid date_sub
by tulipid: gen next_phase = phase[_n+1]

* Now you have a clean list of transitions
* This table tells you the aggregate volume moving between phases
tabulate phase next_phase


ssc install sq, replace
* Define the sequence of phases for each tulipid
sqset phase date_sub tulipid
* Plot the most common paths
sqindexplot


* Count missing id
count if tulipid == ""

* Look at the records with missing dates to see if they are salvageable
list tulipid phase wf_seq if tulipid == ""


* 1. Ensure absolute sorting
sort tulipid date_sub

* 2. Check for "time travel" (a date that is earlier than the previous entry)
by tulipid: gen time_check = (date_sub < date_sub[_n-1])
list tulipid date_sub phase if time_check == 1


* If the dates are inconsistent, we can create an artificial "time" 
* based on the sequence (wf_seq) which we know is always increasing
sort tulipid wf_seq
by tulipid: gen time_index = _n



* If your data is in long format (one row per phase per ID):

* Create a combined variable: phase 1, seq 1 becomes "1_1", phase 1, seq 2 becomes "1_2"
gen new_phase = string(phase) + "_" + string(wf_seq2)

* Now reshape using the new unique identifier for j
reshape wide decision, i(tulipid) j(new_phase) string

duplicates report tulipid new_phase


* 1. Create a frequency variable for the transitions
* Generate a combined string representing the path
gen path = string(phase1) + "-" + string(phase2) + "-" + string(phase3) + "-" + string(phase4)

* 2. Count occurrences of each path
bysort path: gen count = _N
bysort path: keep if _n == 1  // Keep one row per unique path

* 3. Now you have the counts, you can plot it
* Since 'sankey' creates flows between two points (from/to), 
* you can visualize it in layers:
sankey count, from(phase1) to(phase2) by(phase3)
