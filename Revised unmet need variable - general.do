/* 	Stata program to create Revised unmet need variable as described in
	Analytical Study 25: Revising Unmet Need for Family Planing
	by Bradley, Croft, Fishel, and Westoff, 2012, published by ICF International
	measuredhs.com/pubs/pdf/AS25/AS25.pdf
** 	Program written by Sarah Bradley and edited by Trevor Croft, last updated 23 January 2011
	SBradley@icfi.com
** 	This program will work for most surveys. If your results do not match 
	Revising Unmet Need for Family Planning, the survey you are analyzing may require 
	survey-specific programming. See survey-specific link at measuredhs.com/topics/Unmet-Need.cfm */
**  Correction 10 May 2017 to work with DHS7 datasets.  
**  Two changes: checks for v000 now look for "7", and tsinceb now calculated using v222 which is based on century day codes in DHS7
**  Correction 17 March 2021 Trevor Croft: to work with DHS8 datasets, and to conform to standard coding of v626a.

g unmet=.
**Set unmet need to NA for unmarried women if survey only included ever-married women 
replace unmet=98 if v502!=1 & (v020==1)

** CONTRACEPTIVE USERS - GROUP 1
* using to limit if wants no more, sterilized, or declared infecund
recode unmet .=4 if v312!=0 & (v605>=5 & v605<=7)
* using to space - all other contraceptive users
recode unmet .=3 if v312!=0

**PREGNANT or POSTPARTUM AMENORRHEIC (PPA) WOMEN - GROUP 2
* Determine who should be in Group 2
* generate time since last birth
g tsinceb=v222
* generate time since last period in months from v215
g tsincep	    =	int((v215-100)/30) 	if v215>=100 & v215<=190
replace tsincep =   int((v215-200)/4.3) if v215>=200 & v215<=290
replace tsincep =   (v215-300) 			if v215>=300 & v215<=390
replace tsincep =	(v215-400)*12 		if v215>=400 & v215<=490
* initialize pregnant or postpartum amenorrheic (PPA) women
g pregPPA=1 if v213==1 | m6_1==96
* For women with missing data or "period not returned" on date of last menstrual period, use information from time since last period
* 	if last period is before last birth in last 5 years
replace pregPPA=1 if (m6_1==. | m6_1==99 | m6_1==97) & tsincep>tsinceb & tsinceb<60 & tsincep!=. & tsinceb!=.
* 	or if said "before last birth" to time since last period in the last 5 years
replace pregPPA=1 if (m6_1==. | m6_1==99 | m6_1==97) & v215==995 & tsinceb<60 & tsinceb!=.
* select only women who are pregnant or PPA for <24 months
g pregPPA24=1 if v213==1 | (pregPPA==1 & tsinceb<24)

* Classify based on wantedness of current pregnancy/last birth
* current pregnancy
g wantedlast=v225
* last birth
replace wantedlast = m10_1 if (wantedlast==. | wantedlast==9) & v213!=1
* no unmet need if wanted current pregnancy/last birth then/at that time
recode unmet .=7  if pregPPA24==1 & wantedlast==1
* unmet need for spacing if wanted current pregnancy/last birth later
recode unmet .=1  if pregPPA24==1 & wantedlast==2
* unmet need for limiting if wanted current pregnancy/last birth not at all
recode unmet .=2  if pregPPA24==1 & wantedlast==3
* missing=missing
recode unmet .=99 if pregPPA24==1 & (wantedlast==. | wantedlast==9)

**DETERMINE FECUNDITY - GROUP 3 (Boxes refer to Figure 2 flowchart in report)
g infec=0
**Box 1 - applicable only to currently married
* married 5+ years ago, no children in past 5 years, never used contraception, excluding pregnant and PPA <24 months
cap replace infec=1 if v502==1 & v512>=5 & v512!=. & (tsinceb>59 | tsinceb==.) & v302==0  & pregPPA24!=1
* in DHS VI, v302 replaced by v302a
cap replace infec=1 if v502==1 & v512>=5 & v512!=. & (tsinceb>59 | tsinceb==.) & v302a==0 & pregPPA24!=1 & (substr(v000,3,1)=="6" | substr(v000,3,1)=="7" | substr(v000,3,1)=="8")

**Box 2
* declared infecund on future desires for children
replace infec=2 if v605==7

**Box 3
* menopausal/hysterectomy on reason not using contraception - slightly different recoding in DHS III and IV+
* DHS IV+ surveys
cap replace infec=3 if 	v3a08d==1 & (substr(v000,3,1)=="4" | substr(v000,3,1)=="5" | substr(v000,3,1)=="6" | substr(v000,3,1)=="7" | substr(v000,3,1)=="8")
* DHSIII surveys
cap replace infec=3 if  v375a==23 & (substr(v000,3,1)=="3" | substr(v000,3,1)=="T")
* reason not using did not exist in DHSII, use reason not intending to use in future
cap replace infec=3 if  v376==14 & substr(v000,3,1)=="2"

**Box 4
* Time since last period is >=6 months and not PPA
replace infec=4 if tsincep>=6 & tsincep!=. & pregPPA!=1

**Box 5
* menopausal/hysterectomy on time since last period
replace infec=5 if v215==994
* never menstruated on time since last period, unless had a birth in the last 5 years
replace infec=5 if v215==996 & (tsinceb>59 | tsinceb==.)

**Box 6
* time since last birth>= 60 months and last period was before last birth
replace infec=6 if v215==995 & tsinceb>=60 & tsinceb!=.
* never had a birth, but last period reported as before last birth - assume code should have been 994 or 996
replace infec=6 if v215==995 & tsinceb==.

* exclude pregnant and PP amenorrheic < 24 months
replace infec=0 if pregPPA24==1
recode unmet .=9 if infec>0

**NO NEED FOR UNMARRIED WOMEN WHO ARE NOT SEXUALLY ACTIVE
* determine if sexually active in last 30 days
g sexact=1 if v528>=0 & v528<=30
* if unmarried and never had sex, assume no need
recode unmet .=0 if v502!=1 & v525==0
* if unmarried and not sexually active in last 30 days, assume no need
recode unmet .=8 if v502!=1 & sexact!=1

**FECUND WOMEN - GROUP 4
* wants within 2 years
recode unmet .=7 if v605==1
* wants in 2+ years, wants undecided timing, or unsure if wants
recode unmet .=1 if v605>=2 & v605<=4
* wants no more
recode unmet .=2 if v605==5
recode unmet .=99
  la def unmet ///
    0 "never had sex"
    1 "unmet need for spacing" ///
	2 "unmet need for limiting" ///
	3 "using for spacing" ///
	4 "using for limiting" ///
	7 "no unmet need" ///
	8 "not sexually active" ///
	9 "infecund or menopausal" ///
	98 "unmarried - EM sample or no data" ///
	99 "missing"
  la val unmet unmet
recode unmet (1/2=1 "unmet need") (else=0 "no unmet need"), g(unmettot)

**TABULATE RESULTS
* generate sampling weight
g wgt=v005/1000000
* tabulate for currently married women
ta unmet if v502==1 [iw=wgt], m
ta unmettot if v502==1 [iw=wgt]
* all women
ta unmet [iw=wgt]
ta unmettot [iw=wgt]
* sexually active unmarried
ta unmet if v502!=1 & sexact==1 [iw=wgt]
ta unmettot if v502!=1 & sexact==1 [iw=wgt]
