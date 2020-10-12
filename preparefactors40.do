capture log close
log using "factors by subsamples 1204", replace text


* prelims
clear
set mem 128m
* we don't need this yet
* set matsize 3000
set more off

use shares_long30_split, clear

*************** define subsamples
su `1'
if r(max)-r(min)==1 {
	gen subsample=`1'
}
else {
	su `1' if year==1980, d
	gen tmp2=(`1'>r(p50)) if (`1'<.)&(year==1980)
	egen subsample=min(tmp2), by(cnum)	
}

drop if subsample>=.

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
gen nocountry = shock - cntf
egen subindf = mean(nocountry), by(sector year subsample)
gen subepsilon = shock - subindf - cntf

bysort subsample: su subepsilon

collapse (mean) subindf share, by(sector year subsample)
reshape wide subindf share, i(sector year) j(subsample)

gen avgshare=(share0+share1)/2

bysort sector: corr subindf0 subindf1
egen stdev0 = sd(subindf0), by(sector)
egen stdev1 = sd(subindf1), by(sector)

corr stdev0 stdev1 [aw=avgshare]

log close
set more on

