use "data/derived/shares.dta", clear

do "set_globals.do"

* calc global factor 
* though we put it in ind factors and not use it separately
egen glbf = mean(shock), by(year)

* calculate the sectoral means as fixed effect estimates of the industry factors
egen indf = mean(shock), by(sector year)

* calculate country means, this has measurement error!
egen cntf = mean(shock-indf), by(country year)

* calculate even more residuals
gen epsilon = shock - indf - cntf

tempfile factors indfactors 
save `factors', replace

* save country correspondence
collapse (count) epsilon, by(cnum country)
drop epsilon
sort cnum
save "data/derived/countries.dta", replace

use `factors', clear

collapse (mean) indf, by(sector year)
ren indf Fs
reshape wide Fs, i(year) j(sector)

sort year
save `indfactors', replace


* do the same for cnt factors
use `factors'

collapse (mean) cntf, by(country year)
ren cntf Fc
reshape wide Fc, i(year) j(country)

sort year
merge year using `indfactors'
tab _
drop _

* how many countries in a year?
egen Jt = robs(Fc*)

sort year
save "data/derived/allfactors.dta", replace 

keep year Jt
sort year
save "data/derived/Jt.dta", replace

