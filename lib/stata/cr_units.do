/*
Total Data
EU
HQ
*/



list orgpath if unit ==.

*** REPLACE orgpath
* RGO
foreach org in "EU/RGO/CHP/BON/WAC" "EU/RGO/PNP/NAO" "SE/ACO/MMR" ///
"SE/RGO/HPN/HRF" "WP/ACO/KIR/KI1" "EU/RGO/SNI/NAO" {
    replace unit = 6 if unit == . & orgpath == "`org'"
}

replace unit = 6 if unit == . & regexm(orgpath, "RGO")
* GPA

foreach org in "HQ/CSF/OHS" "HQ/DDG/PTP" "HQ/POL" "HQ/POL/CNT" "HQ/POL/DAI" ///
"HQ/POL/DAI/PSL" "HQ/POL/DAI/SLD" "HQ/POL/PRD" "HQ/POL/PTP" ///
"HQ/POL/RMC" "HQ/POL/RMC/COM" ///
{
    replace unit = 1 if unit == . & orgpath == "`org'"
}

replace unit = 1 if unit == . & regexm(orgpath, "GPA")
replace unit = 1 if unit == . & regexm(orgpath, "POL")

* WHE
foreach org in "HQ/HEO/LCD"  {
    replace unit = 2 if unit == . & orgpath == "`org'"
}

replace unit = 2 if unit == . & regexm(orgpath, "WHE")

* HSD
foreach org in "HQ/HSD/DDA/ISD" "HQ/HSD/HPS/PAM/MDA" "HQ/HSD/HPS/PSN" "HQ/HSD/PFD/GPF" ///
"HQ/HSD/PFD/PPE" "HQ/HSD/PFD/SDP/QPS" "HQ/UHL/HGF/EEA" "HQ/UHL/HGF/HEF" ///
"RC/CSU" "RC/NME/LSB" {
    replace unit = 3 if unit == . & orgpath == "`org'"
}

replace unit = 3 if unit == . & regexm(orgpath, "HSD")

* PPC
foreach org in "HQ/DDG/GNP" "HQ/DDG/PHM" "HQ/HRP" "HQ/NMC" "HQ/UHL" "HQ/PCC/ECO/CEA"  {
    replace unit = 4 if unit == . & orgpath == "`org'"
}


* Replace unit = 4 if orgpath contains "PPC"
replace unit = 4 if unit == . & regexm(orgpath, "PPC")

* SCI

foreach org in "HQ/HSR" {
    replace unit = 5 if unit == . & orgpath == "`org'"
}

replace unit = 5 if unit == . & regexm(orgpath, "SCI")

list orgpath if unit ==.


** CHANGE unit based on ID 
* ppc 

foreach id in "HQ-2024-03132" "HQ-2024-03554" "HQ-2024-03245" "HQ-2024-04377" {
    replace unit = 4 if unit == . & tulipid == "`id'"
}

* whe 

foreach id in "HQ-2023-01007" {
    replace unit = 2 if unit == . & tulipid == "`id'"
}


* ppc 

foreach id in "HQ-2024-01335" "HQ-2024-03579" {
    replace unit = 3 if unit == . & tulipid == "`id'"
}

list orgpath if unit ==.

