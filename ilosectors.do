clear
set mem 500m
***data is ccode variable (many) V_year1 ---V_yearT
insheet using C:/P1-div/shares_ilo1.csv
reshape long v_, i(ccode indcode) string
ren _j year
rename v_ share
drop if indcode==0| indcode>=20
egen totempl = sum(share), by(ccode year)
replace share = share/tot*100
gen sector=.
replace sector=100 if indcode ==1|indcode==2
replace sector=300 if indcode==3|indcode==4
replace sector=500 if indcode>=5&indcode<=11
collapse (sum)share (mean)tot, by (ccode year sector)
sort ccode year sector
save temp.dta, replace
