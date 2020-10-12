*******ILO data
clear
set mem 500m
***data is ccode variable (many) V_year1 ---V_yearT
insheet using C:/P1-div/shares_ilo1.csv
reshape long v_, i(ccode indcode) string
ren _j year
rename v_ share
drop if indcode==0| indcode==11| indcode>=20
gen sector=.
replace sector=100 if indcode ==1
replace sector=300 if indcode==2|indcode==3|indcode==4|indcode==5
replace sector=500 if indcode>=6&indcode<=10
collapse (sum)share, by (ccode year sector)
egen totempl = sum(share), by(ccode year)
replace share = share/totemp*100
egen sumshare = sum(share), by(ccode year)
drop if sumshare==0 
drop sumshare
sort ccode year sector
save temp.dta, replace


******WDI data
***data is ccode variable (many) V_year1 ---V_yearT
insheet using C:/P1-div/sectoraldata.csv, clear
reshape long v_, i(ccode variable) string
ren _j year
reshape wide v_, i(ccode  year) j( variable) string
renpfix v_ 
replace agshare=ag2000/gdp2000*100  if agshare==. & ag2000~=.
replace indshare=ag2000/gdp2000*100 if indshare==. & ind2000~=.
replace sershare=ag2000/gdp2000*100 if sershare==. & ser2000~=.
keep ccode year agshare indshare sershare emind empag empser unemp gdp2000 gdppc2000 laborforce
ren agshare yshare100
ren indshare yshare300
ren sershare yshare500
ren empag empshare100
ren emind empshare300
ren empser empshare500
reshape long yshare empshare, i(ccode year) j(sector) 
sort ccode year sector
merge ccode year sector using temp.dta
tab _
drop _
destring, replace
replace empshare=share if ccode=="PRT"&(year<1994|year>=1980)
replace empshare=share if ccode=="PRI"&(year>=1999)
replace empshare=share if ccode=="KOR"&(year<=1994)
replace empshare=share if ccode=="MAR"&(year==2000)
replace empshare=share if ccode=="MAC"&(year<=1988)
replace empshare=share if ccode=="GER"|ccode=="TTO"
egen sumempshare = sum(empshare), by(ccode year)

drop if sumemp==0
replace empshare=empshare/sumempshare*100


save C:/P1-div/wdiilo.dta, replace


