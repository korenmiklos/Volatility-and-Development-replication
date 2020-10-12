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

* min var portfolio
count
gen b0 = .
gen b1 = .
gen b2 = .
gen m = .
gen TAU2=.
gen BETA=.

forval Y=1/$S {
	matrix nicelittlevector=Varind["Fs`Y'",1..$S]
	matrix score SigmaFs`Y'=nicelittlevector
	replace SigmaFs`Y'=SigmaFs`Y'*Fs`Y'
}
forval Y=1/$S {
	gen sqFs`Y'=Fs`Y'^2
}
egen SECT=rsum(SigmaFs1 - SigmaFs$S)
su SECT
egen HERF=rsum(sqFs1 - sqFs$S)
replace HERF=HERF*sigma2
su HERF

* del Negro's HERF is dnHERF
* this is a weighted sum of squares
gen dnHERF=0
forval s = 1/$S {
	forval j = 1/$J {
		replace dnHERF = dnHERF+sqFs`s'*dnsigma2[`s',`j'] if country==`j'
	}
}

**this calculates the residual
matrix residual=J($S,1,0)
matrix residual = dnsigma2 * J($J,1,1/$J)
forval X = 1/$J {
    di in gre "Country # " in ye `X'
********* have to change omega here if we want to use dnHERF
* this is the old one, just in case
*    matrix Omega = Varind+Covindcnt["Fc`X'","Fs1".."Fs$S"]'*J(1,$S,1)+J($S,1,1)*Covindcnt["Fc`X'","Fs1".."Fs$S"]+ Varcnt[rownumb(Varcnt,"Fc`X'"),colnumb(Varcnt,"Fc`X'")]*J($S,$S,1)+sigma2*I($S)
* and here comes the new one
    matrix Omega = Varind+Covindcnt["Fc`X'","Fs1".."Fs$S"]'*J(1,$S,1)+J($S,1,1)*Covindcnt["Fc`X'","Fs1".."Fs$S"]+ Varcnt[rownumb(Varcnt,"Fc`X'"),colnumb(Varcnt,"Fc`X'")]*J($S,$S,1)+diag(dnsigma2[1..$S,`X'])
    matrix mu = Mu[`X',1..$S]



* this calcs current mean return using labor shares
    capture drop mtemp
    matrix score mtemp = mu
    replace m=mtemp if country==`X'

    matrix A = (mu*inv(Omega)*mu', J(1,$S,1)*inv(Omega)*mu' \ J(1,$S,1)*inv(Omega)*mu' , J(1,$S,1)*inv(Omega)*J($S,1,1))
    matrix core = inv(A) 
* the previous formula was the same but longer
    replace b0 = core[2,2] if country==`X'
    replace b1 = core[2,1]+core[1,2] if country==`X'
    replace b2 = core[1,1] if country==`X'

	replace TAU2 = Varcnt[rownumb(Varcnt,"Fc`X'"),colnumb(Varcnt,"Fc`X'")] if country==`X'
	capture drop BETAtmp
	matrix nicelittlevector=Covindcnt["Fc`X'","Fs1".."Fs$S"]
	matrix score BETAtmp = nicelittlevector
	replace BETA = BETAtmp/TAU2 if country==`X'

}

gen V = b0+b1*m+b2*m^2
* this is the lowest risk for the given mean

gen RISK = SECT+HERF+2*BETA*TAU2+TAU2
gen dnRISK = SECT+dnHERF+2*BETA*TAU2+TAU2
* this is the overall 

gen COV2 = 2*BETA*TAU2

gen MIN = b0-b1^2/(4*b2)
* this is the absolute lowest risk

gen minM = -b1/(2*b2)
* this is the corresponding mean


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
drop _
sort cnum year

merge 1:1 cnum year using "data/pwt/pwt1.dta", keep(master match) nogen

save "data/derived/specmeasures.dta", replace

