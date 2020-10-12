capture log close
log using "factors as cross-section means oct 28", replace text


* prelims
clear
set mem 128m
* we don't need this yet
* set matsize 3000
set more off

use shares_long30, clear

su sector
global S = r(max)
su country
global J = r(max)
su year
global tmin = r(min)
global tmax = r(max)
global T = $tmax-$tmin+1

* calc global factor 
* though we put it in ind factors and not use it separately
egen glbf = mean(shock), by(year)

* calculate the sectoral means as fixed effect estimates of the industry factors
egen indf = mean(shock), by(sector year)

* calculate country means, this has measurement error!
egen cntf = mean(shock-indf), by(country year)

* calculate even more residuals
gen epsilon = shock - indf - cntf

su epsilon
scalar sigma2 = r(Var)

* let sigma change with j and s
* this is denote dnsigma (del negro's sigma)
* egen dnsigma = sd(epsilon), by(country sector)

matrix dnsigma2 = J($S,$J,0)
forval s = 1/$S {
	forval j = 1/$J {
		su epsilon if (country==`j')&(sector==`s')
		matrix dnsigma2[`s',`j'] = r(Var)
	}
}

save factors_temp30, replace

* save country correspondence
collapse (count) epsilon, by(cnum country)
drop epsilon
sort cnum
save countries30, replace

use factors_temp30, clear

collapse (mean) indf, by(sector year)
ren indf Fs
reshape wide Fs, i(year) j(sector)

sort year
save indfactors_wide30, replace


* do the same for cnt factors
use factors_temp30

collapse (mean) cntf, by(country year)
ren cntf Fc
reshape wide Fc, i(year) j(country)

sort year
merge year using indfactors_wide30
tab _
drop _

* how many countries in a year?
egen Jt = robs(Fc*)

sort year
save allfactors_wide30, replace 

keep year Jt
sort year
save Jt, replace

log close
set more on

