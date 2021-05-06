tempfile t1 t2 
clear
macro drop _all


foreach name in Congo2019 Coted'Ivoire2005 Vietnam2005 {
use "/Volumes/alan/DHS/RAW DATA/AIS/DHS-`name'/DHS-`name'ind.DTA",clear
foreach i in 1 2 3 4 5 6 7 8 9  {
foreach var of varlist *_0`i' {
local a =  subinstr("`var'","_0`i'","_`i'",1)
ren `var' `a'
	}
}
macro drop namenew
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

save "/Volumes/alan/DHS/RAW DATA/AIS/DHS-`name'/birth.dta",replace

}


cls
foreach name in  Vietnam2005{
use "/Volumes/alan/DHS/RAW DATA/AIS/DHS-`name'/DHS-`name'ind.dta",clear
lookfor m13 m14 m2 m2n m42 m45 m1a m1d
lookfor m3 m15 m34 m4 m77 m61 m17 
lookfor m50 m51 m52 m62 m63 m64 m66 m67 m68 m70 m71 m72 m74 m75 m77
lookfor v766b v761 v313 v502 
lookfor v008 b3_01 v213  v437 v438  weight height 
lookfor h1 h2 h4 h5 h6 h7 h8 h9 
lookfor h11 h31 h13b h13 h14 h12a h32a h38 h39 h15 h15a h22 h31b h31c 
lookfor hc70 hc71 hv005 v106
}



//BurkinaFaso2014 BurkinaFaso2017 Uganda2014 Uganda2018


xx
use"/Volumes/alan/DHS/RAW DATA/MIS/DHS-BurkinaFaso2017/birth.dta",clear
sort caseid bid
save,replace

use "/Volumes/alan/DHS/RAW DATA/MIS/DHS-BurkinaFaso2017/DHS-BurkinaFaso2017child.DTA",clear
sort v001 v002 v003 bidx
ren bidx bid
merge 1:1 v001 v002 v003 bid using "/Volumes/alan/DHS/RAW DATA/MIS/DHS-BurkinaFaso2017/birth.dta"


use "/Volumes/alan/DHS/RAW DATA/Recode VI/DHS-Angola2011/DHS-Angola2011child.DTA",clear
keep caseid
duplicates drop 
//merge 1:1 caseid using `t1'
save `t2',replace

use "/Volumes/alan/DHS/RAW DATA/Recode VI/DHS-Angola2011/DHS-Angola2011birth.DTA",clear
keep caseid
duplicates drop 
merge 1:1 caseid using `t2'


