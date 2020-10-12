do "set_globals.do"

use "data/derived/allfactors.dta", clear

* estimate pairwise covariances 
matrix S = J($S+$J,$S+$J,0)
matname S Fc1-Fc$J Fs1 Fs2-Fs$S, rows(.)
matname S Fc1-Fc$J Fs1 Fs2-Fs$S, col(.)

foreach X of varlist Fc1-Fc$J Fs1 Fs2-Fs$S {
    foreach Y of varlist Fc1-Fc$J Fs1 Fs2-Fs$S {
        capture matrix accum Spair = `X' `Y', nocons
        capture matrix S[rownumb(S,"`X'"),colnumb(S,"`Y'")] = Spair[2,1]/r(N)
    }
}


matrix Varcnt = S["Fc1".."Fc$J","Fc1".."Fc$J"]
matrix Varind = S["Fs1".."Fs$S","Fs1".."Fs$S"]
matrix Covindcnt = S["Fc1".."Fc$J","Fs1".."Fs$S"]


* read in mean returns
use "data/derived/meanlaborprod_wide.dta", clear

sort country

* rename vars to be compatible with shares
foreach X of num 1/$S {
    ren laborprod`X' Fs`X'
}

mkmat Fs1-Fs$S, mat(Mu)
mat list Mu

* read in labor shares
use "data/derived/preparedshares.dta", clear

foreach X of num 1/$S {
    ren share`X' Fs`X'
}

forval Y=1/$S {
	matrix nicelittlevector = Varind["Fs`Y'",1..$S]
	matrix score SigmaFs`Y' = nicelittlevector
	replace SigmaFs`Y' = SigmaFs`Y'*Fs`Y'
}
forval Y=1/$S {
	gen sqFs`Y' = Fs`Y'^2
}
egen GSECT=rsum(SigmaFs1 - SigmaFs$S)
su GSECT

egen HERF=rsum(sqFs1 - sqFs$S)
su HERF

gen IDIO = 0
forval s = 1/$S {
	forval j = 1/$J {
		replace IDIO = IDIO + sqFs`s'*dnsigma2[`s',`j'] if country==`j'
	}
}

gen CNT = .
gen COV = .
forval X = 1/$J {
    di in gre "Country # " in ye `X'
	replace CNT = Varcnt[rownumb(Varcnt,"Fc`X'"),colnumb(Varcnt,"Fc`X'")] if country==`X'
	tempvar BETAtmp
	matrix nicelittlevector = Covindcnt["Fc`X'","Fs1".."Fs$S"]
	matrix score `BETAtmp' = nicelittlevector
	replace COV = 2 * `BETAtmp' if country==`X'
}

* this is the overall risk
gen RISK = GSECT + IDIO + CNT + COV
* decompose IDIO into AVAR and HERF
generate AVAR = IDIO / HERF

* how many years in sample?
egen N = count(Fs1), by(country)

sort cnum year

tempfile sm
save `sm', replace 


* now merge with stuff
use "data/wdi/wdinew.dta", clear
keep cnum cname year rgdppcp pop 
sort cnum year
merge cnum year using `sm'
drop _*
sort cnum year

merge 1:1 cnum year using "data/pwt/pwt1.dta", keep(master match) nogen

save "data/derived/specmeasures.dta", replace

