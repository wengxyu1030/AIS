////////////////////////////////////////////////////////////////////////////////////////////////////
*** DHS MONITORING
////////////////////////////////////////////////////////////////////////////////////////////////////

version 14.0
clear all
set matsize 3956, permanent
set more off, permanent
set maxvar 32767, permanent
capture log close
sca drop _all
matrix drop _all
macro drop _all

******************************
*** Define main root paths ***
******************************

//NOTE FOR WINDOWS USERS : use "/" instead of "\" in your paths

* Define root depend on the stata user. 
if "`c(username)'" == "sunyining" local pc = 0
if "`c(username)'" == "xweng"     local pc = 1

if `pc' == 0 global root "/Users/sunyining/OneDrive/MEASURE UHC DATA"
if `pc' == 1 global root "C:/Users/XWeng/OneDrive - WBG/MEASURE UHC DATA"

* Define path for data sources
global SOURCE "${root}/RAW DATA/AIS"

* Define path for output data
global OUT "${root}/STATA/DATA/SC/FINAL"

* Define path for INTERMEDIATE
global INTER "${root}/STATA/DATA/SC/INTER"

* Define path for do-files
if `pc' == 0 global DO "/Users/sunyining/Dropbox/GitHub/AIS"
if `pc' == 1 global DO "${root}/STATA/DO/SC/AIS"

* Define the country names (in globals) in by Recode
do "${DO}/0_GLOBAL.do"


global AIScountries "Mozambique2015"

foreach name in $AIScountries{	
clear
tempfile birth ind men hm hiv hh iso

******************************
*****domains using birth data*
******************************
use "${SOURCE}/AIS-`name'/AIS-`name'ind.dta", clear
capture confirm variable b1_01
if _rc == 0 {
	foreach k in 1 2 3 4 5 6 7 8 9  {
		foreach var of varlist *_0`k' {
			local a =  subinstr("`var'","_0`k'","_`k'",1)
			ren `var' `a'
		}
	}
	
	labmask m15_1, values(m15_1)
	
	global namenew
	foreach var of varlist *_1{
		local a = subinstr("`var'","_1","_@",.)
		global namenew $namenew `a'
	}


	sreshape long $namenew ,  i(caseid) j(bid)

	foreach var of varlist *_{
		local a = subinstr("`var'","_","",.)
		ren `var' `a'
	}
	
	drop if b8==. & b5!=0

	gen name = "`name'"
	if !inlist(name, "Guyana2005"){
	label value m15 m15_1
	}

	
save "${INTER}/`name'birth.dta",replace
}

capture confirm file "${INTER}/`name'birth.dta"
if _rc == 0 {
use "${INTER}/`name'birth.dta",clear
    gen hm_age_mon = (v008 - b3)           //hm_age_mon Age in months (children only)
	
    do "${DO}/1_antenatal_care"
    do "${DO}/2_delivery_care"
    do "${DO}/3_postnatal_care"
    do "${DO}/7_child_vaccination"
    do "${DO}/8_child_illness"
    do "${DO}/10_child_mortality"
    do "${DO}/11_child_other"

*housekeeping for birthdata
   //generate the demographics for child who are dead or no longer living in the hh. 
   
    *hm_live Alive (1/0)
    recode b5 (1=0)(0=1) , ge(hm_live)   
	label var hm_live "died" 
	label define yesno 0 "No" 1 "Yes"
	label values hm_live yesno 

    *hm_dob	date of birth (cmc)
    gen hm_dob = b3  

    *hm_age_yrs	Age in years       
    gen hm_age_yrs = b8        

    *hm_male Male (1/0)         
    recode b4 (2 = 0),gen(hm_male)  
	
    *hm_doi	date of interview (cmc)
    gen hm_doi = v008
	
	* For Coted'Ivoire2005, the v001/v002 lost 2-3 digits, fix this issue in main.do
	if inlist(name,"CotedIvoire2005"){
		gen hm_shstruct = substr(caseid,8,3)
		order caseid bidx v000 v001 v002 hm_shstruct  v003
		destring hm_shstruct,replace
	}	
	cap gen hm_shstruct =999
rename (v001 v002 b16) (hv001 hv002 hvidx)
keep hv001 hv002 hvidx bidx c_* mor_* w_* hm_*
save `birth',replace
}
capture confirm file "${INTER}/`name'birth.dta"
if _rc != 0 { // some survey have no child data, generate all child related variables as missing 
use "${SOURCE}/AIS-`name'/AIS-`name'ind.dta", clear
	local varlist c_anc	c_anc_any	c_anc_bp	c_anc_bp_q	c_anc_bs	c_anc_bs_q	c_anc_ear	c_anc_ear_q	c_anc_eff	c_anc_eff_q	///	
	c_anc_eff2	c_anc_eff2_q	c_anc_eff3	c_anc_eff3_q	c_anc_ir	c_anc_ir_q	c_anc_ski	c_anc_ski_q	c_anc_tet	c_anc_tet_q	///
	c_anc_ur c_anc_ur_q	c_caesarean	c_earlybreast	c_facdel	c_hospdel	c_sba	c_sba_eff1	c_sba_eff1_q	c_sba_eff2	///
	c_sba_eff2_q c_sba_q	c_skin2skin	c_pnc_any	c_pnc_eff	c_pnc_eff_q	c_pnc_eff2	c_pnc_eff2_q	c_bcg	c_dpt1	c_dpt2	///
	c_dpt3	c_fullimm c_measles c_polio1	c_polio2	c_polio3	c_ari	c_ari2	c_diarrhea 	c_diarrhea_hmf	c_diarrhea_med ///	
	c_diarrhea_medfor c_diarrhea_mof	c_diarrhea_pro	c_diarrheaact	c_diarrheaact_q	c_fever	c_fevertreat	c_illness	c_illtreat ///
	c_sevdiarrhea c_sevdiarrheatreat	c_sevdiarrheatreat_q	c_treatARI	c_treatARI2	c_treatdiarrhea	c_illness2	c_illtreat2  ///
	mor_ade	mor_afl	mor_ali	mor_dob mor_wln bidx  hm_age_mon c_ITN hm_live hm_dob hm_age_yrs hm_male hm_doi 
	
	foreach i of local varlist{
			gen `i' = . 
	}
	gen w_sampleweight = v005/10e6
	
	recode v106 (0 = 1) (1 =2) (2/3 = 3) (8 = .),gen(w_mateduc)
	label define w_label 1 "none" 2 "primary" 3 "lower sec or higher"
	label values w_mateduc w_label
	cap gen hm_shstruct =999
rename (v001 v002 v003) (hv001 hv002 hvidx)
keep hv001 hv002 hvidx bidx c_* mor_*  hm_shstruct w_*
save `birth',replace
}

******************************
*****domains using ind data***
******************************
use "${SOURCE}/AIS-`name'/AIS-`name'ind.dta", clear	
gen name = "`name'"

    do "${DO}/4_sexual_health"
    do "${DO}/5_woman_anthropometrics"
    do "${DO}/16_woman_cancer"
*housekeeping for ind data

    *hm_dob	date of birth (cmc)
    gen hm_dob = v011  
	
	* For Coted'Ivoire2005, the v001/v002 lost 2-3 digits, fix this issue in main.do
	if inlist(name,"CotedIvoire2005"){
		gen hm_shstruct = substr(caseid,8,3)
		order caseid  v000 v001 v002 hm_shstruct v003
		destring hm_shstruct,replace
		isid v001 hm_shstruct v002 v003  
	}	
	cap gen hm_shstruct =999	
	
keep v001 v002 v003 w_* hm_*
rename (v001 v002 v003) (hv001 hv002 hvidx)
save `ind' 

************************************
*****domains using hm level data****
************************************
use "${SOURCE}/AIS-`name'/AIS-`name'hm.dta", clear
gen name = "`name'"

    do "${DO}/9_child_anthropometrics"  
	do "${DO}/13_adult"
    do "${DO}/14_demographics"
	
	* For Coted'Ivoire2005, the v001/v002 lost 2-3 digits, fix this issue in main.do
	if inlist(name,"CotedIvoire2005"){
		gen hm_shstruct = shstruct
		isid hm_shstruct hv001 hv002 hvidx
		order  hhid hvidx hv000 hm_shstruct hv001 hv002
	}	
	cap gen hm_shstruct =999
keep hv001 hv002 hvidx hc70 hc71 ///
c_* ant_* a_* hm_* ln
save `hm'

capture confirm file "${SOURCE}/AIS-`name'/AIS-`name'hiv.dta"
 if _rc==0 {
    use "${SOURCE}/AIS-`name'/AIS-`name'hiv.dta", clear
	gen name = "`name'"
    do "${DO}/12_hiv"
 }
 if _rc!= 0 {
    gen a_hiv = . 
    gen a_hiv_sampleweight = .
  }
 	cap gen hm_shstruct =999 
    save `hiv',replace

use `hm',clear
merge 1:1 hv001 hm_shstruct hv002 hvidx using `hiv'
drop _merge
save `hm',replace

************************************
*****domains using hh level data****
************************************
use "${SOURCE}/AIS-`name'/AIS-`name'hm.dta", clear
	gen name = "`name'"
	if inlist(name,"CotedIvoire2005"){
		gen hm_shstruct = shstruct
		isid hm_shstruct hv001 hv002 hvidx
		order  hhid hvidx hv000 hm_shstruct hv001 hv002
	}		
    do "${DO}/15_household"
keep hv001 hv002 hv003 hh_* ind_* hm_shstruct
save `hh' ,replace

************************************
*****merge to microdata*************
************************************

***match with external iso data
use "${SOURCE}/external/iso", clear 
keep country iso2c iso3c	
replace country = "Tanzania"  if country == "Tanzania, United Republic of"
replace country = "PapuaNewGuinea" if country == "Papua New Guinea"
replace country = "SierraLeone"  if country == "Sierra Leone"
replace country = "CotedIvoire"  if country == "CÃ´te d'Ivoire"
save `iso'

***merge all subset of microdata
use `hm',clear

    merge 1:m hv001 hm_shstruct hv002 hvidx using `birth',update      //AISsing update is zero, non DHSsing conflict for all matched.(hvidx different) 
	
	bysort hv001 hm_shstruct hv002: egen min = min(w_sampleweight)
	replace w_sampleweight = min if w_sampleweight ==.
    replace hm_headrel = 99 if _merge == 2
	label define hm_headrel_lab 99 "dead/no longer in the household"
	label values hm_headrel hm_headrel_lab
	replace hm_live = 0 if _merge == 2 | inlist(hm_headrel,.,12,98)
	drop _merge
    merge m:m hv001 hm_shstruct hv002 hvidx using `ind',nogen update
	merge m:m hv001 hm_shstruct hv002       using `hh',nogen update

    tab hh_urban,mi  //check whether all hh member + dead child + child lives outside hh assinged hh info

***survey level data
    gen survey = "DHS-`name'"
	gen year = real(substr("`name'",-4,.))
	tostring(year),replace
    gen country = regexs(0) if regexm("`name'","([a-zA-Z]+)")
	replace country = "South Africa" if country == "SouthAfrica"
	replace country = "Timor-Leste" if country == "Timor"
	replace country = "CotedIvoire" if country == "Coted"
	
    merge m:1 country using `iso',force

    drop if _merge == 2
	drop _merge

*** Quality Control: Validate with DHS official data
    gen surveyid = iso2c+year+"AIS"

	preserve 
	do "${DO}/Quality_control"
	save "${INTER}/quality_control-`name'.dta",replace
	cd "${INTER}"
	do "${DO}/Quality_control_result"
	save "${OUT}/quality_control",replace 
    restore

*** Specify sample size to HEFPI
	
    ***for variables generated from 1_antenatal_care 2_delivery_care 3_postnatal_care
	foreach var of var c_anc	c_anc_any	c_anc_bp	c_anc_bp_q	c_anc_bs	c_anc_bs_q ///
	c_anc_ear	c_anc_ear_q	c_anc_eff	c_anc_eff_q	c_anc_eff2	c_anc_eff2_q ///
	c_anc_eff3	c_anc_eff3_q	c_anc_ir	c_anc_ir_q	c_anc_ski	c_anc_ski_q ///
	c_anc_tet	c_anc_tet_q	c_anc_ur	c_anc_ur_q	c_caesarean	c_earlybreast ///
	c_facdel	c_hospdel	c_sba	c_sba_eff1	c_sba_eff1_q	c_sba_eff2 ///
	c_sba_eff2_q	c_sba_q	c_skin2skin	c_pnc_any	c_pnc_eff	c_pnc_eff_q c_pnc_eff2	c_pnc_eff2_q {
    replace `var' = . if !(inrange(hm_age_mon,0,23)& bidx ==1)
    }
	
	***for variables generated from 4_sexual_health 5_woman_anthropometrics
	foreach var of var w_CPR w_unmet_fp	w_need_fp w_metany_fp	w_metmod_fp w_metany_fp_q  w_bmi_1549 w_height_1549 w_obese_1549 w_overweight_1549 {
	replace `var'=. if hm_age_yrs<15 | (hm_age_yrs>49 & hm_age_yrs!=.)
	}

	***for variables generated from 7_child_vaccination
	foreach var of var c_bcg c_dpt1 c_dpt2 c_dpt3 c_fullimm c_measles ///
	c_polio1 c_polio2 c_polio3{
    replace `var' = . if !inrange(hm_age_mon,15,23)
    }

	***for variables generated from 8_child_illness	
	foreach var of var c_ari c_ari2	c_diarrhea 	c_diarrhea_hmf	c_diarrhea_medfor	c_diarrhea_mof	c_diarrhea_pro	c_diarrheaact ///
	c_diarrheaact_q	c_fever	c_fevertreat	c_illness c_illness2 c_illtreat	c_illtreat2 c_sevdiarrhea	c_sevdiarrheatreat ///
	c_sevdiarrheatreat_q	c_treatARI	c_treatARI2 c_treatdiarrhea	c_diarrhea_med {
    replace `var' = . if !inrange(hm_age_mon,0,59)
    }
	
	***for variables generated from 9_child_anthropometrics
	foreach var of var c_underweight c_stunted	hc70 hc71 ant_sampleweight{
    replace `var' = . if !inrange(hm_age_mon,0,59)
    }
	
	***for hive indicators from 12_hiv
    foreach var of var a_hiv*{
    replace `var'=. if hm_age_yrs<15 | (hm_age_yrs>49 & hm_age_yrs!=.)
    }
              
	***for hive indicators from 13_adult
    foreach var of var a_diab_treat  a_inpatient_1y a_bp_treat a_bp_sys a_bp_dial a_hi_bp140_or_on_med a_bp_meas{
	replace `var'=. if hm_age_yrs<18
	}
*** Label variables
    drop bidx surveyid
    do "${DO}/Label_var"
	
capture confirm file "${INTER}/`name'birth.dta"
if _rc == 0 {
erase "${INTER}/`name'birth.dta"
}
save "${OUT}/DHS-`name'.dta", replace  
}
