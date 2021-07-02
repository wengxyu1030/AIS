
******************************
*** Child mortality***********
******************************   

*c_ITN	Child slept under insecticide-treated-bednet (ITN) last night.
    gen c_ITN = .
	
	capture confirm variable ml0
	if _rc == 0 {
	replace c_ITN=(ml0==1) 								
	replace c_ITN=. if ml0==.                  //Children under 5 in country where malaria is endemic (only in countries with endemic)
	}

	if inlist(name, "CotedIvoire2005", "Mozambique2009", "Uganda2011", "Vietnam2005") { 
	replace c_ITN = (ml101 == 1) 
	replace c_ITN = . if ml101 == . 
	}
	
*w_mateduc	Mother's highest educational level ever attended (1 = none, 2 = primary, 3 = lower sec or higher)
    recode v106 (0 = 1) (1 =2) (2/3 = 3) (8 = .),gen(w_mateduc)
	  label define w_label 1 "none" 2 "primary" 3 "lower sec or higher"
      label values w_mateduc w_label



*******compare with statacompiler
preserve
keep if b8 <5
restore

