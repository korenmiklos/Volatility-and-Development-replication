capture log close
log using "CCAPM new 1204", replace

set more off

use pwt1, clear

*gen cpcp = consumption_lcu/pop
gen cpcp = conspwt
tsset cnum year

gen cgrowth = log(cpcp/L5.cpcp)

 ******** deflate with CPI
/* sort cnum year
save tempcpi1.dta,replace
use cpinew.dta, clear
sort cnum year
merge cnum year using tempcpi1.dta
tab _
drop if _!=3
drop _
tsset cnum year
replace cgrowth = cgrowth-log(cpi/L5.cpi) */

******** demean consumption growth by country
egen mgrowth = mean(cgrowth), by(cnum)
replace cgrowth = cgrowth-mgrowth




sort cnum
merge cnum using countries30

keep country year cgrowth
drop if country==.

reshape wide cgrowth, i(year) j(country)

sort year
save cgrowth_wide, replace

merge year using allfactors_wide30
tab _
drop _

gen cnt=.

* estimate pairwise betas on consumption growth
matrix S = J($S+1,$J,0)
matname S Fs1 Fs2-Fs$S cnt, rows(.)
matname S cgrowth1-cgrowth$J, col(.)


foreach X of num 1/$J {
	capture matrix accum Spair = cgrowth`X' Fc`X', nocons 
	capture matrix S[rownumb(S,"cnt"),colnumb(S,"cgrowth`X'")] = Spair[2,1]/r(N)
	foreach Y of varlist Fs1 Fs2-Fs$S {
		capture matrix accum Spair = cgrowth`X' `Y', nocons 
		capture matrix S[rownumb(S,"`Y'"),colnumb(S,"cgrowth`X'")] = Spair[2,1]/r(N)
	}

}


* read in shares
use preparedshares, clear

* now merge on the meaningful country codes
sort country 
merge country using countries
drop if _!=3
drop _

* rename shares so that they can be used in matrix score
foreach X of num 1/$S {
	rename share`X' Fs`X'
}

gen conscovind = .
gen conscovcnt = .
foreach X of num 1/$J {
	matrix conscov = S[1..$S,colnumb(S,"cgrowth`X'")]'
	capture drop temp
	matrix score temp = conscov
	replace conscovind = temp if country==`X'
	replace conscovcnt = S[$S+1,colnumb(S,"cgrowth`X'")] if country==`X'
}

* how many years in sample?
egen N = count(Fs1), by(country)

tab cname

sort cnum year
save ccapm, replace 

outfile using ccapm, dict replace


* now merge with stuff
use wdinew, clear
keep cnum year rgdppcp pop 
sort cnum year
merge cnum year using ccapm

* generate some vars
gen lgdp = log(rgdppcp)
gen lgdp2 = lgdp^2
gen lgdp3 = lgdp^3
gen lgdp4 = lgdp^4

sort cnum year
save ccapm, replace

keep if year<=1998
sort cname cnum


collapse (mean) betaind betacn, by(cnum cname)
outsheet using capm, replace



log close
set more on



