******************************
*** Woman Cancer *********** 
******************************   


*w_papsmear	Women received a pap smear  (1/0)
gen w_papsmear = .

*w_mammogram	Women received a mammogram (1/0)
gen w_mammogram = .

if inlist(name,"Jordan2017") {
	replace w_papsmear=0 if s1110_f!=.
	replace w_papsmear=1 if s1110_g==1
	replace w_papsmear=. if s1110_f==8 | s1110_g==8
	replace w_papsmear=. if v012 < 20
	
	replace w_mammogram = (s1110_c == 1) 
	replace w_mammogram=. if s1110_c == . | s1110_c == 8
	replace w_mammogram=. if v012 < 20	
}

if inlist(name,"SouthAfrica2016") {
	tempfile tpf1
	drop w_papsmear
	preserve
		use "${SOURCE}/DHS-SouthAfrica2016/DHS-SouthAfrica2016wm.dta", clear	
		gen w_papsmear = s1407 if !inlist(s1407,.,8)  
		replace w_papsmear = 0 if w_papsmear==1 & s1408!=1  // period: 3yr
		replace w_papsmear=. if !inrange(v012,20,49)
		keep w_* caseid
		sort caseid
		save `tpf1'
	restore
	drop _m //merge indicator from 4.do
	merge 1:1 caseid using `tpf1'
	tab _m
	drop if _m ==2 // for _m ==2, variables necessary for 4.do and 5.do are all missing
	drop _m
}


*Add reference period.
gen w_papsmear_ref = ""
gen w_mammogram_ref = ""

if inlist(name, "Jordan2017") {
	replace w_papsmear_ref = "ever"
	replace w_mammogram_ref = "ever"
}

if inlist(name, "SouthAfrica2016") {
	replace w_papsmear_ref = "3yr"
}

//if not in adeptfile, please generate value, otherwise keep it missing. 

//if the preferred recall is not available (3 years for pap, 2 years for mam) use shortest other available recall 


* Add Age Group.

gen w_mammogram_age = ""
gen w_papsmear_age = ""

if inlist(name, "Jordan2017") {
	replace w_mammogram_age = "20-49"
	replace w_papsmear_age = "20-49"
}

if inlist(name, "SouthAfrica2016") {
	replace w_papsmear_age = "20-49"
}


//if not in adeptfile, please generate value, otherwise keep it missing. 


