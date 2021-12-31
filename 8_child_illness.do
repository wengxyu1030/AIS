
**************************
*** Child illness ********
**************************   

if !inlist(name, "Mozambique2015"){
*c_diarrhea Child with diarrhea in last 2 weeks
	g c_diarrhea=.
	g ccough=.
			  
*c_treatdiarrhea Child with diarrhea receive oral rehydration salts (ORS)
	g c_treatdiarrhea=.
		
*c_diarrhea_hmf	Child with diarrhea received recommended home-made fluids
	g c_diarrhea_hmf=.

*c_diarrhea_pro	The treatment was provided by a formal provider (all public provider except other public, pharmacy, and private sector)
	g c_diarrhea_pro =.

*c_diarrhea_mof	Child with diarrhea received more fluids
	g c_diarrhea_mof = .
	
*c_diarrhea_medfor Get formal medicine except (ors hmf home other_med, country specific). 
	g c_diarrhea_medfor = .

*c_diarrhea_med	Child with diarrhea received any medicine other than ORS or hmf (country specific)
	g c_diarrhea_med = .
			
*c_diarrheaact	Child with diarrhea seen by provider OR given any form of formal treatment
	g c_diarrheaact = .
				
*c_diarrheaact_q	Child under 5 with diarrhea in last 2 weeks seen by formal healthcare provider or given any form of treatment who received ORS
	g c_diarrheaact_q = .
		
*c_fever	Child with a fever in last two weeks
	gen c_fever = .
	
	if inlist(name, "Guyana2005", "Tanzania2007","Tanzania2012"){
		replace c_fever = (h22 == 1) if !inlist(h22,.,8,9)
	}

*c_sevdiarrhea	Child with severe diarrhea
	g c_sevdiarrhea = .
					
*c_sevdiarrheatreat	Child with severe diarrhea seen by formal healthcare provider
	g c_sevdiarrheatreat = .
		
*c_sevdiarrheatreat_q	IV (intravenous) treatment of severe diarrhea among children with any formal provider visits
	g c_sevdiarrheatreat_q = .

*c_ari	Children under 5 with cough and rapid breathing in the two weeks preceding the survey which originated from the chest.	
	g c_ari = .
		
	/* Children under 5 with cough and rapid breathing in the 
	two weeks preceding the survey which originated from the chest. */
	g c_ari2 = . 

		
*c_treatARI/c_treatARI2	   Child with acute respiratory infection (ARI) /ARI2 symptoms seen by formal provider
	gen c_treatARI =.
	gen c_treatARI2 =.

*c_fevertreat	Child with fever symptoms seen by formal provider	
	gen c_fevertreat = .

	if inlist(name,"Guyana2005", "Tanzania2007","Tanzania2012") {
	    order h32a-h32x,sequential	
		foreach var of varlist h32a-h32x {
                 local lab: variable label `var' 
        replace `var' = . if ///   				 
		regexm("`lab'","(other|shop|pharmacy|market|kiosk|relative|friend|church|drug|addo|hilot|traditional|cs private medical|cs public sector|no treatment)") ///
                 & !regexm("`lab'","(ngo|hospital|medical center|traditional practioner$|sub health center|health center|aid post|trained vhv and other government|maternity home|diagnostic center|wome('s|n's) consultation|(pol|po)yclinic|fap|emergency services|ambulatory/family doctor office)")  
		replace `var' = . if !inlist(`var',0,1)
                 /* do not consider formal if contain words in the first group but don't contain any words in the second group */
       }
       egen pro_ari = rowtotal(h32a-h32x),mi

		foreach var of varlist c_treatARI c_treatARI2 {
        replace `var' = 1 if `var' == 0 & pro_ari >= 1 
        replace `var'  = . if pro_ari == . 	
		}
		
		replace c_fevertreat = 0 if c_fever == 1
		replace c_fevertreat = 1 if c_fevertreat == 0 & pro_ari >= 1
		replace c_fevertreat = . if pro_ari == .
	}

*c_illness/c_illness2	Child with any illness symptoms in last two weeks
	gen c_illness =.
	gen c_illness2 = .

		
*c_illtreat/c_illtreat2 	Child with any illness symptoms taken to formal provider
	gen c_illtreat = .
	gen c_illtreat2 = .
}	
	
	
if inlist(name, "Mozambique2015"){

*c_diarrhea Child with diarrhea in last 2 weeks
	gen c_diarrhea=(h11   ==1|h11   ==2) 						/*symptoms in last two weeks*/
	replace c_diarrhea=. if h11   ==8|h11  ==9|h11  ==. 
					 
	gen ccough=(h31  ==1|h31  ==2) 
	replace ccough=. if h31  ==8|h31  ==9|h31  ==. 
					  
*c_treatdiarrhea Child with diarrhea receive oral rehydration salts (ORS)
	cap gen h13b  =. 
	gen c_treatdiarrhea=(h13  ==1|h13  ==2|h13b  ==1) 	if c_diarrhea == 1							/*ORS for diarrhea*/
	replace c_treatdiarrhea=. if (h13  ==8|h13  ==9 | h13  ==.)&(h13b  ==8|h13b  ==9 | h13b  ==.) 
				
*c_diarrhea_hmf	Child with diarrhea received recommended home-made fluids
	gen c_diarrhea_hmf=(h14  ==1|h14  ==2) if c_diarrhea == 1			/* home made fluid for diarrhea*/
	replace c_diarrhea_hmf=. if h14  ==8|h14  ==9 | h14  ==. 
		
*c_diarrhea_pro	The treatment was provided by a formal provider (all public provider except other public, pharmacy, and private sector)

	foreach var of varlist h12a-h12x {
		local lab: variable label `var' 
        replace `var' = . if ///
                 regexm("`lab'","(other|shop|pharmacy|market|kiosk|relative|friend|church|drug|addo|hilot|traditional|cs private medical|cs public sector|no treatment)") ///
                 & !regexm("`lab'","(ngo|hospital|medical center|traditional practioner$|sub health center|health center|aid post|trained vhv and other government|maternity home|diagnostic center|wome('s|n's) consultation|(pol|po)yclinic|fap|emergency services|ambulatory/family doctor office)")  
		replace `var' = . if !inlist(`var',0,1) 
				 			 
/* do not consider formal if contain words in 
                 the first group but don't contain any words in the second group */
       }
	order h12*,sequential
	egen pro_dia = rowtotal(h12a-h12x),mi

	gen c_diarrhea_pro = 0 if c_diarrhea == 1
	replace c_diarrhea_pro = 1 if pro_dia >= 1 
	replace c_diarrhea_pro = . if pro_dia == . 

	*c_diarrhea_mof	Child with diarrhea received more fluids
	gen c_diarrhea_mof = (h38 == 5) if !inlist(h38,.,8) & c_diarrhea == 1

*c_diarrhea_medfor Get formal medicine except (ors hmf home other_med, country specific). 
	egen medfor = rowtotal(h12z h15 h15a h15b h15c h15e h15g h15h h15i h15j),mi
	gen c_diarrhea_medfor = ( medfor > = 1 ) if c_diarrhea == 1 & medfor !=.
	// formal medicine don't include "home remedy, herbal medicine and other"
	replace c_diarrhea_medfor = . if h12z == 8 | h15 == 8 | h15a == 8 | h15b == 8 | h15c == 8 | h15e == 8  | h15g == 8 | h15h == 8 | h15i == 8			 
	
*c_diarrhea_med	Child with diarrhea received any medicine other than ORS or hmf (country specific)
	egen med = rowtotal(h12z h15 h15a h15b h15c h15d h15e h15f h15g h15h h15i h15j),mi
	gen c_diarrhea_med = ( med > = 1 ) if c_diarrhea == 1 & med !=.
	replace c_diarrhea_med = . if h12z == 8 | h15 == 8 | h15a == 8 | h15b == 8 | h15c == 8 | h15d == 8 | h15e == 8 | h15f == 8 | h15g == 8 | h15h == 8 | h15i == 8 | h15j == 8
				
*c_diarrheaact	Child with diarrhea seen by provider OR given any form of formal treatment
	gen c_diarrheaact = (c_diarrhea_pro==1 | c_diarrhea_medfor==1 | c_diarrhea_hmf==1 | c_treatdiarrhea==1) if c_diarrhea == 1
	replace c_diarrheaact = . if (c_diarrhea_pro == . | c_diarrhea_medfor == . | c_diarrhea_hmf == . | c_treatdiarrhea == .) & c_diarrhea == 1		
				
*c_diarrheaact_q	Child under 5 with diarrhea in last 2 weeks seen by formal healthcare provider or given any form of treatment who received ORS
	gen c_diarrheaact_q = c_treatdiarrhea  if c_diarrheaact == 1
	replace c_diarrheaact_q = . if c_treatdiarrhea == .
		
*c_fever	Child with a fever in last two weeks
	gen c_fever = (h22 == 1) if !inlist(h22,.,8,9)
		
*c_sevdiarrhea	Child with severe diarrhea
	gen eat = (inlist(h39,0,1,2)) if !inlist(h39,.,8) & c_diarrhea == 1
	gen c_sevdiarrhea = (c_diarrhea==1 & (c_fever == 1 | c_diarrhea_mof == 1 | eat == 1)) 
	replace c_sevdiarrhea = . if c_diarrhea == . | c_fever == . | (c_diarrhea == 1 & (c_diarrhea_mof ==.| eat==.))
	/* diarrhea in last 2 weeks AND any of the following three conditions: fever OR offered 
	more than usual to drink OR given much less or nothing to eat or stopped eating */
					
*c_sevdiarrheatreat	Child with severe diarrhea seen by formal healthcare provider
	gen c_sevdiarrheatreat = (c_sevdiarrhea == 1 & c_diarrhea_pro == 1) if c_diarrhea == 1
	replace c_sevdiarrheatreat = . if c_sevdiarrhea == . | c_diarrhea_pro == .
		
*c_sevdiarrheatreat_q	IV (intravenous) treatment of severe diarrhea among children with any formal provider visits
	gen iv = (h15c == 1) if !inlist(h15c,.,8) & c_diarrhea == 1
	gen c_sevdiarrheatreat_q = (iv ==1 ) if c_sevdiarrheatreat == 1
		
*c_ari	Children under 5 with cough and rapid breathing in the two weeks preceding the survey which originated from the chest.	
	gen c_ari = 0 if ccough != .
	replace c_ari = 1 if h31b == 1 & ccough == 1 & inlist(h31c,1,3)
	replace c_ari = . if inlist(h31b,8,9) | inlist(h31c,8,9)	
	replace c_ari = . if ccough==1 & h31b == .
		
	/* Children under 5 with cough and rapid breathing in the 
	two weeks preceding the survey which originated from the chest. */
		
	gen c_ari2 = 0 if ccough != .
	replace c_ari2 = 1 if h31b == 1 & ccough == 1
	replace c_ari2 = . if inlist(h31b,8,9)
	replace c_ari2 = . if ccough==1 & h31b == .
	
	
*c_treatARI/c_treatARI2	   Child with acute respiratory infection (ARI) /ARI2 symptoms seen by formal provider
	gen c_treatARI = 0 if c_ari == 1
	gen c_treatARI2 = 0 if c_ari2 == 1	
	    
	order h32a-h32x,sequential	
		
		foreach var of varlist h32a-h32x {
                 local lab: variable label `var' 
        replace `var' = . if ///   				 
		regexm("`lab'","(other|shop|pharmacy|market|kiosk|relative|friend|church|drug|addo|hilot|traditional|cs private medical|cs public sector|no treatment)") ///
                 & !regexm("`lab'","(ngo|hospital|medical center|traditional practioner$|sub health center|health center|aid post|trained vhv and other government|maternity home|diagnostic center|wome('s|n's) consultation|(pol|po)yclinic|fap|emergency services|ambulatory/family doctor office)")  
		replace `var' = . if !inlist(`var',0,1)
                 /* do not consider formal if contain words in the first group but don't contain any words in the second group */
       }
       egen pro_ari = rowtotal(h32a-h32x),mi

		foreach var of varlist c_treatARI c_treatARI2 {
        replace `var' = 1 if `var' == 0 & pro_ari >= 1 
        replace `var'  = . if pro_ari == . 	
		}

*c_fevertreat	Child with fever symptoms seen by formal provider	

		gen c_fevertreat = 0 if c_fever == 1
		replace c_fevertreat = 1 if c_fevertreat == 0 & pro_ari >= 1
		replace c_fevertreat = . if pro_ari == .
			
*c_illness/c_illness2	Child with any illness symptoms in last two weeks
	gen c_illness = (c_diarrhea == 1 | c_ari == 1 | c_fever == 1) 
	replace c_illness =. if c_diarrhea == . | c_ari == . | c_fever == .
		
	gen c_illness2 = (c_diarrhea == 1 | c_ari2 == 1 | c_fever == 1) 
	replace c_illness2 =. if c_diarrhea == . | c_ari2 == . | c_fever == .
		
*c_illtreat/c_illtreat2 	Child with any illness symptoms taken to formal provider
	gen c_illtreat = (c_fevertreat == 1 | c_diarrhea_pro == 1 | c_treatARI == 1) if c_illness == 1 
	replace c_illtreat = . if (c_fever == 1 & c_fevertreat == .) | (c_diarrhea == 1 & c_diarrhea_pro == .) | (c_ari == 1 & c_treatARI == .) 
				
	gen c_illtreat2 = (c_fevertreat == 1 | c_diarrhea_pro == 1 | c_treatARI2 == 1) if c_illness2 == 1
	replace c_illtreat2 = . if (c_fever == 1 & c_fevertreat == .) | (c_diarrhea == 1 & c_diarrhea_pro == .) | (c_ari2 == 1 & c_treatARI2 == .) 


}

/*
Attach Recode VII 8_child_illness.do as reference
**************************
*** Child illness ********
**************************   
	
*c_diarrhea Child with diarrhea in last 2 weeks
	gen c_diarrhea=(h11   ==1|h11   ==2) 						/*symptoms in last two weeks*/
	replace c_diarrhea=. if h11   ==8|h11  ==9|h11  ==. 
					 
	gen ccough=(h31  ==1|h31  ==2) 
	replace ccough=. if h31  ==8|h31  ==9|h31  ==. 
					  
*c_treatdiarrhea Child with diarrhea receive oral rehydration salts (ORS)
	cap gen h13b  =. 
	gen c_treatdiarrhea=(h13  ==1|h13  ==2|h13b  ==1) 	if c_diarrhea == 1							/*ORS for diarrhea*/
	replace c_treatdiarrhea=. if (h13  ==8|h13  ==9 | h13  ==.)&(h13b  ==8|h13b  ==9 | h13b  ==.) 
				
*c_diarrhea_hmf	Child with diarrhea received recommended home-made fluids
	gen c_diarrhea_hmf=(h14  ==1|h14  ==2) if c_diarrhea == 1			/* home made fluid for diarrhea*/
	replace c_diarrhea_hmf=. if h14  ==8|h14  ==9 | h14  ==. 
		
*c_diarrhea_pro	The treatment was provided by a formal provider (all public provider except other public, pharmacy, and private sector)

if ~inlist(name,"Philippines2017") {
	foreach var of varlist h12a-h12x {
		local lab: variable label `var' 
        replace `var' = . if ///
                 regexm("`lab'","(other|shop|pharmacy|market|kiosk|relative|friend|church|drug|addo|hilot|traditional|cs private medical|cs public sector|no treatment)") ///
                 & !regexm("`lab'","(ngo|hospital|medical center|traditional practioner$|sub health center|health center|aid post|trained vhv and other government|maternity home|diagnostic center|wome('s|n's) consultation|(pol|po)yclinic|fap|emergency services|ambulatory/family doctor office)")  
		replace `var' = . if !inlist(`var',0,1) 
				 			 
/* do not consider formal if contain words in 
                 the first group but don't contain any words in the second group */
       }
	order h12*,sequential
	egen pro_dia = rowtotal(h12a-h12x),mi

	gen c_diarrhea_pro = 0 if c_diarrhea == 1
	replace c_diarrhea_pro = 1 if pro_dia >= 1 
	replace c_diarrhea_pro = . if pro_dia == . 
}    	

if inlist(name,"Philippines2017") {		
	if inlist(name,"Philippines2017") {
		global h12 "h12a h12b h12c h12d h12j h12l"	
	}
	gen c_diarrhea_pro = 0 if c_diarrhea == 1
	foreach var in $h12 {
		replace c_diarrhea_pro = 1 if c_diarrhea_pro == 0 & `var' == 1 
		replace c_diarrhea_pro = . if `var' == 8 
	}
}

*c_diarrhea_mof	Child with diarrhea received more fluids
	gen c_diarrhea_mof = (h38 == 5) if !inlist(h38,.,8) & c_diarrhea == 1

*c_diarrhea_medfor Get formal medicine except (ors hmf home other_med, country specific). 
	egen medfor = rowtotal(h12z h15 h15a h15b h15c h15e h15g h15h h15i h15j),mi
	gen c_diarrhea_medfor = ( medfor > = 1 ) if c_diarrhea == 1 & medfor !=.
	// formal medicine don't include "home remedy, herbal medicine and other"
	replace c_diarrhea_medfor = . if h12z == 8 | h15 == 8 | h15a == 8 | h15b == 8 | h15c == 8 | h15e == 8  | h15g == 8 | h15h == 8 | h15i == 8			 
	
*c_diarrhea_med	Child with diarrhea received any medicine other than ORS or hmf (country specific)
	egen med = rowtotal(h12z h15 h15a h15b h15c h15d h15e h15f h15g h15h h15i h15j),mi
	gen c_diarrhea_med = ( med > = 1 ) if c_diarrhea == 1 & med !=.
	replace c_diarrhea_med = . if h12z == 8 | h15 == 8 | h15a == 8 | h15b == 8 | h15c == 8 | h15d == 8 | h15e == 8 | h15f == 8 | h15g == 8 | h15h == 8 | h15i == 8 | h15j == 8
				
*c_diarrheaact	Child with diarrhea seen by provider OR given any form of formal treatment
	gen c_diarrheaact = (c_diarrhea_pro==1 | c_diarrhea_medfor==1 | c_diarrhea_hmf==1 | c_treatdiarrhea==1) if c_diarrhea == 1
	replace c_diarrheaact = . if (c_diarrhea_pro == . | c_diarrhea_medfor == . | c_diarrhea_hmf == . | c_treatdiarrhea == .) & c_diarrhea == 1		
				
*c_diarrheaact_q	Child under 5 with diarrhea in last 2 weeks seen by formal healthcare provider or given any form of treatment who received ORS
	gen c_diarrheaact_q = c_treatdiarrhea  if c_diarrheaact == 1
	replace c_diarrheaact_q = . if c_treatdiarrhea == .
		
*c_fever	Child with a fever in last two weeks
	gen c_fever = (h22 == 1) if !inlist(h22,.,8,9)
		
*c_sevdiarrhea	Child with severe diarrhea
	gen eat = (inlist(h39,0,1,2)) if !inlist(h39,.,8) & c_diarrhea == 1
	gen c_sevdiarrhea = (c_diarrhea==1 & (c_fever == 1 | c_diarrhea_mof == 1 | eat == 1)) 
	replace c_sevdiarrhea = . if c_diarrhea == . | c_fever == . | (c_diarrhea == 1 & (c_diarrhea_mof ==.| eat==.))
	/* diarrhea in last 2 weeks AND any of the following three conditions: fever OR offered 
	more than usual to drink OR given much less or nothing to eat or stopped eating */
					
*c_sevdiarrheatreat	Child with severe diarrhea seen by formal healthcare provider
	gen c_sevdiarrheatreat = (c_sevdiarrhea == 1 & c_diarrhea_pro == 1) if c_diarrhea == 1
	replace c_sevdiarrheatreat = . if c_sevdiarrhea == . | c_diarrhea_pro == .
		
*c_sevdiarrheatreat_q	IV (intravenous) treatment of severe diarrhea among children with any formal provider visits
	gen iv = (h15c == 1) if !inlist(h15c,.,8) & c_diarrhea == 1
	gen c_sevdiarrheatreat_q = (iv ==1 ) if c_sevdiarrheatreat == 1
		
*c_ari	Children under 5 with cough and rapid breathing in the two weeks preceding the survey which originated from the chest.	
	gen c_ari = 0 if ccough != .
	replace c_ari = 1 if h31b == 1 & ccough == 1 & inlist(h31c,1,3)
	replace c_ari = . if inlist(h31b,8,9) | inlist(h31c,8,9)	
	replace c_ari = . if ccough==1 & h31b == .
		
	/* Children under 5 with cough and rapid breathing in the 
	two weeks preceding the survey which originated from the chest. */
		
	gen c_ari2 = 0 if ccough != .
	replace c_ari2 = 1 if h31b == 1 & ccough == 1
	replace c_ari2 = . if inlist(h31b,8,9)
	replace c_ari2 = . if ccough==1 & h31b == .
		
*c_treatARI/c_treatARI2	   Child with acute respiratory infection (ARI) /ARI2 symptoms seen by formal provider
	gen c_treatARI = 0 if c_ari == 1
	gen c_treatARI2 = 0 if c_ari2 == 1	
	    
	order h32a-h32x,sequential	
		
if ~inlist(name,"Armenia2015") {
		foreach var of varlist h32a-h32x {
                 local lab: variable label `var' 
        replace `var' = . if ///   				 
		regexm("`lab'","(other|shop|pharmacy|market|kiosk|relative|friend|church|drug|addo|hilot|traditional|cs private medical|cs public sector|no treatment)") ///
                 & !regexm("`lab'","(ngo|hospital|medical center|traditional practioner$|sub health center|health center|aid post|trained vhv and other government|maternity home|diagnostic center|wome('s|n's) consultation|(pol|po)yclinic|fap|emergency services|ambulatory/family doctor office)")  
		replace `var' = . if !inlist(`var',0,1)
                 /* do not consider formal if contain words in the first group but don't contain any words in the second group */
       }
       egen pro_ari = rowtotal(h32a-h32x),mi

		foreach var of varlist c_treatARI c_treatARI2 {
        replace `var' = 1 if `var' == 0 & pro_ari >= 1 
        replace `var'  = . if pro_ari == . 	
		}
}

if inlist(name,"Armenia2015") {		
	if inlist(name,"Armenia2015") {
		global h32 "h32a h32b h32c h32d h32e h32f h32g h32h h32j h32l h32m h32n h32o h32p h32q h32r"
	}
	foreach var in $h32 {
		replace c_treatARI = 1 if c_treatARI == 0 & `var' == 1 
		replace c_treatARI = . if `var' == 9
				
		replace c_treatARI2 = 1 if c_treatARI2 == 0 & `var' == 1 
		replace c_treatARI2 = . if `var' == 9
	}
}
		
*c_fevertreat	Child with fever symptoms seen by formal provider	
	if inlist(name,"Armenia2015") {
		gen c_fevertreat = 0 if c_fever == 1
		foreach var in $h32 {
			replace c_fevertreat = 1 if c_fevertreat == 0 & `var' == 1
			replace c_fevertreat = . if `var' == 9 
		}
	}	
	if ~inlist(name,"Armenia2015") {
		gen c_fevertreat = 0 if c_fever == 1
		replace c_fevertreat = 1 if c_fevertreat == 0 & pro_ari >= 1
		replace c_fevertreat = . if pro_ari == .
	}	
			
*c_illness/c_illness2	Child with any illness symptoms in last two weeks
	gen c_illness = (c_diarrhea == 1 | c_ari == 1 | c_fever == 1) 
	replace c_illness =. if c_diarrhea == . | c_ari == . | c_fever == .
		
	gen c_illness2 = (c_diarrhea == 1 | c_ari2 == 1 | c_fever == 1) 
	replace c_illness2 =. if c_diarrhea == . | c_ari2 == . | c_fever == .
		
*c_illtreat/c_illtreat2 	Child with any illness symptoms taken to formal provider
	gen c_illtreat = (c_fevertreat == 1 | c_diarrhea_pro == 1 | c_treatARI == 1) if c_illness == 1 
	replace c_illtreat = . if (c_fever == 1 & c_fevertreat == .) | (c_diarrhea == 1 & c_diarrhea_pro == .) | (c_ari == 1 & c_treatARI == .) 
				
	gen c_illtreat2 = (c_fevertreat == 1 | c_diarrhea_pro == 1 | c_treatARI2 == 1) if c_illness2 == 1
	replace c_illtreat2 = . if (c_fever == 1 & c_fevertreat == .) | (c_diarrhea == 1 & c_diarrhea_pro == .) | (c_ari2 == 1 & c_treatARI2 == .) 
*/
