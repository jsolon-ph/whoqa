/* Column Totals : calculate a total using looping over year and store a local macro
- total sums a varlist, possible for indicator variables 
- this loops and creates a local macro for use later
*/

local year_list "2024 2025 2026"
foreach y of local year_list {
    // Calculate total for the specific year
    quietly total 1.quarter_sub if year == `y'
    
    // e(N) stores the number of observations used in the command
    local n_`y' = e(N)
    
    // Display to verify
    display "Observations for `y': `n_`y''"
}

/* Column Totals : use table collect with statistic(count) 
- 

*/
table (quarter_sub) (year) if quarter == 1, statistic(frequency)
collect dims
collect levelsof year_sub

// Example of accessing them later
display "The count for 2025 was `n_2025'"

display 

total i.quarter_sub, over(year)
total date_sub 
i.quarter_sub if year_sub==2024 & quarter==1
local 
total i.quarter_sub if year_sub==2025 & quarter==1
total i.quarter_sub if year_sub==2026 & quarter==1


 local N : display %21.0fc r(N)
 
 total sequence if year_sub==2026
