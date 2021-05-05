
******************************
***Postnatal Care************* 
****************************** 


    *c_pnc_skill: m52 m64 m68 m72 m76 by var label text
	*c_pnc_any : mother OR child receive PNC in first six weeks by skilled health worker	
	*c_pnc_eff: mother AND child in first 24h by skilled health worker
	gen c_pnc_any = .
	gen c_pnc_eff = .

	*c_pnc_eff_q: mother AND child in first 24h by skilled health worker among those with any PNC
	gen c_pnc_eff_q =.
	
	*c_pnc_eff2: mother AND child in first 24h by skilled health worker and cord check, temperature check and breastfeeding counselling within first two days
	gen c_pnc_eff2 = . 
	
    *c_pnc_eff2_q: mother AND child in first 24h weeks by skilled health worker and cord check, temperature check and breastfeeding counselling within first two days among those with any PNC
	gen c_pnc_eff2_q = .
		
/*
attach Recode VII 3_postnatal_care as reference
******************************
***Postnatal Care************* 
****************************** 


    *c_pnc_skill: m52 m64 m68 m72 m76 by var label text
	*c_pnc_any : mother OR child receive PNC in first six weeks by skilled health worker	
	*c_pnc_eff: mother AND child in first 24h by skilled health worker

	if ~inlist(name,"Afghanistan2015","Colombia2015","Myanmar2015","Nepal2016") {
		replace m62 = 0 if inlist(m15,11,12,96) //if delivered at home,etc. question m62-m64 will be skipped and mother-pnc data is collected in m66-68. 
		replace m74 = 0 if inlist(m15,11,12,96) //if delivered at home,etc. question m74-m76 will be skipped and child-pnc data is collected in m70-. 
											// to avoid coding this situation as "c_pnc_XXX is missing", recode m62=0 ("no").
	}
	if inlist(name,"Nepal2016") {
		replace m62 = 0 if inlist(m15,11,12,51,96) //if delivered at home,etc. question m62-m64 will be skipped and mother-pnc data is collected in m66-68. 
		replace m74 = 0 if inlist(m15,11,12,51,96) //if delivered at home,etc. question m74-m76 will be skipped and child-pnc data is collected in m70-. 
											// to avoid coding this situation as "c_pnc_XXX is missing", recode m62=0 ("no").
	}
	if ~inlist(name,"Afghanistan2015","Colombia2015","Myanmar2015") {
	foreach var of varlist m64 m68 m72 m76{
		local s=substr("`var'",-2,.)
		local t=`s'-2
		gen `var'_skill =0 if !mi(m`s') |!inlist(m`t',0,1)
		
		decode `var', gen(`var'_lab)
		replace `var'_lab = lower(`var'_lab )
		replace  `var'_skill= 1 if ///
		(regexm(`var'_lab,"doctor|nurse|midwife|mifwife|aide soignante|assistante accoucheuse|skilled|sub-assistant community medical officer|clinical officer|mch aide|trained|auxiliary birth attendant|physician assistant|professional|ferdsher|feldshare|skilled|community health care provider|birth attendant|hospital/health center worker|hew|auxiliary|icds|feldsher|mch|vhw|village health team|health personnel|gynecolog(ist|y)|obstetrician|internist|pediatrician|family welfare visitor|medical assistant|matron|general practitioner|health officer|extension|ob-gy") ///
		& (regexm(`var'_lab,"trained") | !regexm(`var'_lab,"na^|-na|traditional birth attendant|untrained|unquallified|empirical midwife|box|other|community"))) 
		replace `var'_skill = . if mi(`var') | `var' == 99 | mi(`var'_lab) |`var' == 98
		}

	/* consider as skilled if contain words in the first group but don't contain any words in the second group */		
	gen c_pnc_any = .
		replace c_pnc_any = 0 if m62 != . | m66 != . | m70 != . | m74 != .
		replace c_pnc_any = 1 if ((m63 <= 242 | inrange(m63,301,306) | m63 == 299 ) & m64_skill == 1 ) | ((m67 <= 242 | inrange(m67,301,306) | m67 == 299 ) & m68_skill == 1 ) |((m71 <= 242 | inrange(m71,301,306) | m71 == 299 ) & m72_skill == 1 )|((m75 <= 242 | inrange(m75,301,306) | m75 == 299 ) & m76_skill == 1 )
		replace c_pnc_any = . if ((inlist(m63,.,399,995,998,999)|m64_skill ==.) & m62 !=0)|((inlist(m67,.,399,995,998,999)|m68_skill ==.) & m66 !=0) | ((inlist(m71,.,399,995,998,999)|m72_skill ==.) & m70 !=0)| ((inlist(m75,.,399,995,998,999)|m76_skill ==.) & m74 !=0) | inlist(m62,8,9)|inlist(m66,8,9)|inlist(m70,8,9)|inlist(m74,8,9)
	
	
	gen c_pnc_eff = .
		
		replace c_pnc_eff = 0 if m62 != . | m66 != . | m70 != . | m74 != .
		replace c_pnc_eff = 1 if (((inrange(m63,100,124) | m63 == 201| m63 == 199) & m64_skill == 1) | ((inrange(m67,100,124) | m67 == 201| m67 == 199) & m68_skill == 1)) & (((inrange(m71,100,124) | m71 == 201| m71 == 199) & m72_skill == 1) | ((inrange(m75,100,124) | m75 == 201| m75 == 199) & m76_skill == 1))
		replace c_pnc_eff = . if ((inlist(m63,.,299,399,995,998,999)|m64_skill ==.) & m62 !=0) |((inlist(m67,.,299,399,995,998,999)|m68_skill ==.) & m66 !=0 ) |((inlist(m71,.,299,399,995,998,999)|m72_skill ==.) & m70 !=0)|((inlist(m75,.,299,399,995,998,999)|m76_skill ==.) & m74 !=0)|inlist(m62,8,9) | inlist(m66,8,9) | inlist(m70,8,9) | inlist(m74,8,9)

}
	
	if inlist(name,"Afghanistan2015") {
		gen c_pnc_any = 0 if m70 != . | m50 != . 
        replace c_pnc_any = 1 if ((m71 <= 242 | inrange(m71,301,306) | m71 == 299 ) & inrange(m72,11,13) ) | ((m51 <= 242 | inrange(m51,301,306) | m51 == 299 ) & inrange(m52,11,13))
		replace c_pnc_any = . if ((inlist(m71,.,399,998,999)|m72==.) & m70 !=0) | ((inlist(m51,.,399,998,999) | m52== .) & m50 !=0) |inlist(m50,8,9)|inlist(m70,8,9)
		
		gen c_pnc_eff = 0 if m70 != . | m50 != . 
		replace c_pnc_eff = 1 if (((inrange(m71,100,124) | m71 == 201 ) & inrange(m72,11,13)) & ((inrange(m51,100,124) | m51 == 201) & inrange(m52,11,13))) 
		replace c_pnc_eff = . if ((inlist(m71,.,299,998,999)|m72==.) & m70 !=0) | ((inlist(m51,.,299,998,999) | m52== .) & m50 !=0) |inlist(m50,8,9)|inlist(m70,8,9)
	}
	
	if inlist(name,"Colombia2015") { // lack provider for child pnc 
		gen c_pnc_any = .
		gen c_pnc_eff = .
}
	
	if inlist(name,"Myanmar2015") { // special 
		gen c_pnc_any = 0 if m62 != . | m66 != . | m70 != . 
		replace c_pnc_any = 1 if ((m63 <= 242 | inrange(m63,301,306) | m63 == 299 ) & inrange(m64,11,13)) | ((m67 <= 242 | inrange(m67,301,306) | m67 == 299 ) & inrange(m68,11,13)) | ((m71 <= 242 | inrange(m71,301,306) | m71 == 299 ) & inrange(m72,11,13))
		replace c_pnc_any = . if inlist(m63,399,998) | inlist(m67,399,998) | inlist(m71,399,998) | inlist(m75,399,998) | m62 == 8 | m66 == 8 | m70 == 8 
		
		gen c_pnc_eff = 0 if m62 != . | m66 != . | m70 != . 
		replace c_pnc_eff = 1 if (((inrange(m63,100,124) | m63 == 201| m63 == 199 ) & inrange(m64,11,13)) | ((inrange(m67,100,124) | m67 == 201| m67 == 199) & inrange(m68,11,13))) & (((inrange(m71,100,124) | m71 == 201| m71 == 199) & inrange(m72,11,13)))
		replace c_pnc_eff = . if inlist(m63,299,399,998) | inlist(m67,299,399,998) | inlist(m71,299,399,998) | inlist(m75,299,399,998) | m62 == 8 | m66 == 8 | m70 == 8 | m74 == 8
	}  
	
	*c_pnc_eff_q: mother AND child in first 24h by skilled health worker among those with any PNC
	gen c_pnc_eff_q = c_pnc_eff if c_pnc_any == 1	
	
	*c_pnc_eff2: mother AND child in first 24h by skilled health worker and cord check, temperature check and breastfeeding counselling within first two days
	egen check = rowtotal(m78a m78b m78d),mi
	gen c_pnc_eff2 = c_pnc_eff
	replace c_pnc_eff2 = 0 if check != 3
	replace c_pnc_eff2 = . if c_pnc_eff == . | m78a == 8 | m78b == 8 | m78d == 8
	
    *c_pnc_eff2_q: mother AND child in first 24h weeks by skilled health worker and cord check, temperature check and breastfeeding counselling within first two days among those with any PNC
	gen c_pnc_eff2_q = c_pnc_eff2 if c_pnc_any ==1
*/
