capture log close
*log using "mean returns oct 17", replace text

global DIR .

* prelims
clear
set mem 128m
set matsize 800
set more off
use c:/P1-Div/wdiilo.dta, clear
drop share
destring, replace
sort ccode year 
save c:/P1-Div/temp.dta, replace
use c:/P1-Div/wdinew.dta
sort ccode year
merge ccode year using temp.dta
tab _
drop if ccode==""
drop if cnum==.
drop if empshare==.
destring, replace
drop ccode
ren sector isic
gen ccode=.
drop if cnum==.
drop if isic==.

* create categ variables
egen countrysector = group(cnum isic)
gen share = empshare
gen logshock = log(yshare*gdp2000)-log(empshare*laborforce) if (ysha~=.)&(empsh~=.)

*-log(PPPfa)
gen laborprod0 = (yshare*gdp2000/(PPPfa*100))/(empshare*laborforce) 
su laborprod0, d

tsset countrysector year

gen Dshock = logshock-L5.logshock
* to take fifth difference
* alternatively, we may take a fancier filter, e.g. Baxter-King, Hodrick-Prescott
* these programs are avaiable for Stata
* drop outliers

/*
************FOR UNIDO DATA
drop if (cname=="Peru") & (year>=1979) & (year<=1981)
drop if (cname=="Angola")
drop if (cname=="Azerbaijan")
drop if (cname=="Brazil") & (year==1985)

count if (Dshock>5*log(2))&(Dshock!=.)
l cname year isic Dshock if (Dshock>5*log(2))&(Dshock!=.)
************change this!!!
drop if (Dshock>5*log(2))&(Dshock!=.)

***********change this!!!
count if Dshock<-5*log(2)
l cname year isic Dshock if Dshock<-5*log(2)
drop if Dshock<-5*log(2)
*/
* now try to balance it somehow
egen numind = count(laborprod0), by(cnum year)
su numind
keep if numind==3
egen numyea = count(laborprod0), by(cnum isic)
tab numyea
su numyea


************** THRESHOLD ******************
* keep only if more than 10 years
keep if (numyea>=10)&(numyea!=.)


tab cname if laborprod0<.

* create categ
egen country=group(cnum)
su country
global J = r(max)

egen sector=group(isic)
su sector
global S = r(max)

* now demean it country by country and sector by sector
egen mind = mean(Dshock), by(sector)
egen mcnt = mean(Dshock), by(country)
egen moverall = mean(Dshock)
*egen mean = mean(Dshock), by(sector country)

gen shock = Dshock-mind-mcnt+moverall

* then the shares
egen sumshare = sum(share), by(country year)
replace share = share/sumshare

save shares_long30, replace 

* go for the means
collapse (mean) laborprod = laborprod0, by(cnum country isic sector)
su laborprod, d


sort cnum isic
save meanlaborprod_long30, replace

keep sector country laborprod
reshape wide laborprod, i(country) j(sector)

sort country
save meanlaborprod_wide30, replace


* now do the WIDE stuff
use shares_long30, clear

keep share country year sector cnum
reshape wide share, i(country cnum year) j(sector)

sort cnum year
save preparedshares30, replace

********************************************
* will need to create the sample second moment matrix here

use shares_long30, clear
* this is a unique identifier w/ last 2 digits = sector
gen cntsec = country*100+sector
keep cntsec year shock
reshape wide shock, i(year) j(cntsec)
* this is very wide, may need more memory 


set more on

************
/*gen temp=cpi if country==840
egen cpiUSA=mean(temp), by(year)
*/
