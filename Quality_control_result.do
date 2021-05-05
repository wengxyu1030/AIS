
*****************************************
*** Combine the quality control result **
*****************************************
ssc install fs

cd "${INTER}"	
fs  quality_control*.dta
local firstfile: word 1 of `r(files)'
use `firstfile', clear
foreach f in `r(files)' {
 if "`f'" ~= "`firstfile'" append using `f'
}

keep if flag_dhs == 1| flag_hefpi == 1
//br if flag_dhs == 1