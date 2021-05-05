
***Look for variables in dta. file under specific folder
ssc install lookfor_all

lookfor_all mammogram papsmear, subdir de vlabs filter(ind)  dir("C:\Users\Guan\OneDrive\DHS\MEASURE UHC DATA\RAW DATA\Recode VII")
lookfor_all hospital inpatient admission overnight stay, subdir de vlabs filter(hm)  dir("C:\Users\Guan\OneDrive\DHS\MEASURE UHC DATA\RAW DATA\Recode VII")

Use this method to search for variables:
***ind.dta: 
w_papsmear
w_mammogram 
***hm.dta: 
a_inpatient_1y (key word: inpatient, hospital, admission, overnight stay, etc.)
a_bp_treat (blood pressure)
etc.



***Different definition from DHS report, which can explain some differences in quality control file.
c_ari: don’t include cough in DHS report
w_obese_1549: excludes pregnant women and women with a birth in the preceding 2 months in DHS report
c_sba: we include auxiliary midwife (matrone) for BJ7 ML7