capture log close
log using "mean returns oct 17", replace 
global DIR .

* prelims
clear
set mem 128m
set matsize 800
set more off
*use 3sectors_valemp.dta, clear
*use 3sectors_oecd.dta, clear
*use 3sectors_wdi_4.dta, clear
*use 3sectors_wdi_4_oecdonly.dta, clear
*use oecd-dollar,clear
*use wdi_ido-dollar, clear
use $DIR/unido-dollar, clear
****use $DIR/unido-random-9.dta
****ren isic ind
gen ccode=.

* rename
ren ind isic

* drop weird stuff
* drop if cnum==""
drop if isic==300

* create categ variables
egen countrysector = group(cnum isic)

gen share = empl
gen logshock = log(val)-log(empl) if (val~=.)&(empl~=.)

* deflate logshock TO INTERNATIONAL DOLLARS not domestic constant price
sort cnum year
merge cnum year using $DIR/pwt_prices.dta
tab _
drop if _==2
drop _

sort cnum year
merge cnum year using $DIR/wdinew.dta
tab _
drop if _==2
drop _ 

gen temp=cpi if cnum==840
egen cpiUSA=mean(temp), by(year)

* use cpi here but PPPfa elsewhere 
replace logshock = logshock-log(p)-log(cpiUSA) 

* now back for the level of labor prod
* <=. WAS WRONG
gen laborprod0 = (val/p*100)/empl if (val+empl+p<.)

su laborprod0, d

tsset countrysector year

gen Dshock = logshock-L5.logshock
* to take fifth difference
* alternatively, we may take a fancier filter, e.g. Baxter-King, Hodrick-Prescott
* these programs are avaiable for Stata

* drop outliers


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


* now try to balance it somehow
egen numind = count(laborprod0), by(cnum year)
su numind
keep if numind==r(max)
egen numyea = count(laborprod0), by(cnum isic)
tab numyea
su numyea

************** THRESHOLD ******************
* keep only if more than 20 years
keep if (numyea>=20)&(numyea!=.)


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

log close
set more on

