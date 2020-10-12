capture log close
log using "these are the spec measures oct 28", replace text

* prelims
set more off
* set matsize 5000
use allfactors_wide30, clear

global DIR .

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
use meanlaborprod_wide30, clear

sort country

* rename vars to be compatible with shares
foreach X of num 1/$S {
    ren laborprod`X' Fs`X'
}

mkmat Fs1-Fs$S, mat(Mu)
mat list Mu

* read in labor shares
use preparedshares30, clear

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
save specmeasures30, replace 


* now merge with stuff
use $DIR/wdinew, clear
keep cnum cname year rgdppcp pop 
sort cnum year
merge cnum year using specmeasures30
drop _
sort cnum year
save specmeasures30, replace

* do the world frontier
keep cnum year m b0 b1 b2 V MIN minM
sort cnum year
save meanlaborprod, replace

collapse (mean) b0 b1 b2, by(cnum)
gen one=1
ren b0 b0_
ren b1 b1_
ren b2 b2_

drop if cnum==.

reshape wide b0_ b1_ b2_, i(one) j(cnum)
sort one
save coefs_wide, replace

use meanlaborprod, clear
drop b0 b1 b2
ren V ownV

keep if ownV<.

gen one=1
sort one
merge one using coefs_wide
tab _
keep if _==3
drop _

su cnum
global mincnum r(min)
global maxcnum r(max)

* simply skip nonexistent countries 
forval i = 4/968 {
    capture gen V`i' = b0_`i'+b1_`i'*m+b2_`i'*m^2
}

egen numV=robs(ownV V*)
egen minV=rmin(ownV V*)

**************************** this is new 12/19  *********************************
**************************** this is new 12/19  *********************************
**************************** this is new 12/19  *********************************
* the lowest variance in the world
egen minminV=min(MIN)
* has the following mean
su minM if MIN<=minminV
scalar minminM = r(min)
gen minminM=minminM

keep cnum  year m ownV minV numV minM MIN minminV minminM
sort cnum year

sort cnum year
merge cnum year using $DIR/pwt1
tab _
drop _

sort cnum year
merge cnum year using specmeasures30
tab _
drop _


gen DIST1 = dnRISK-ownV
gen DIST2 = ownV-minV

**************************** this is new 12/19  *********************************
**************************** this is new 12/19  *********************************
**************************** this is new 12/19  *********************************
* if mean is lower than cnt vertex, calc dist to vertex
replace DIST1 = dnRISK-MIN if m<minM


* if mean is lower than world vertex but higher than cnt vertex, calc dist to world vertex
replace DIST2 = ownV-minminV if (m>=minM)&(m<minminM)
* calc dist of two vertices if both are above mean
replace DIST2 = minV-minminV if (m<minM)&(m<minminM)

********correct minV!!!
gen ownminv=ownV
replace ownminv=MIN if (m<minM)

gen worldminv=minV
replace worldminv=minminV if (m<minminM)

save minimumvariance, replace

table cname, c(m SECT m HERF m dnHERF)
table cname, c(m TAU2 m BETA m RISK)

*******************************************
* finally lets do some ML tests
* log likelihood is -T/2 * (ln det V - trace(inv(V)*S)),
* this assumes we saved the huge matrix S with unrestricted second momens
* this is probably memory intensive
* block represent countries: there are J*J blocks, each block is S*S

* our V matrix
* Vbase does not contain HERF yet


/*
matrix Vbase = 0*I($S*$J)

forval j1 = 1/$J {
	di in gre "j(1): " in ye `j1'
	forval j2 = 1/$J {
		di in gre "j(2): " in ye `j2'

		* add the sectoral cov matrix
		matrix Vbase[(j1-1)*$S+1..(j1-1)*$S+$S,(j2-1)*$S+1..(j2-1)*$S+$S] = Vbase[(j1-1)*$S+1..(j1-1)*$S+$S,(j2-1)*$S+1..(j2-1)*$S+$S] + Varind
		* take country cov, add it to the block
				matrix Vbase[(j1-1)*$S+1..(j1-1)*$S+$S,(j2-1)*$S+1..(j2-1)*$S+$S] = Vbase[(j1-1)*$S+1..(j1-1)*$S+$S,(j2-1)*$S+1..(j2-1)*$S+$S] + J($S,$S,Varcnt[rownumb(Varcnt,"Fc`j1'"),colnumb(Varcnt,"Fc`j2'")])
		* add the sectoral covariance 
		matrix Vbase[(j1-1)*$S+1..(j1-1)*$S+$S,(j2-1)*$S+1..(j2-1)*$S+$S] = Vbase[(j1-1)*$S+1..(j1-1)*$S+$S,(j2-1)*$S+1..(j2-1)*$S+$S] + Covindcnt["Fc`j1'","Fs1".."Fs$S"]'*J(1,$S,1)+J($S,1,1)*Covindcnt["Fc`j1'","Fs1".."Fs$S"]+Covindcnt["Fc`j2'","Fs1".."Fs$S"]'*J(1,$S,1)+J($S,1,1)*Covindcnt["Fc`j2'","Fs1".."Fs$S"]
	}
}

Vrest = Vbase+sigma2*I($S*$J)
Vunr = Vbase+diag(vec(dnsigma2))

scalar Lrest = log(det(Vrest)) - trace(inv(Vrest)*S)
scalar Lunr = log(det(Vunr)) - trace(inv(Vunr)*S)

di in gre "Log likelihood (restricted):   " in ye Lrest
di in gre "Log likelihood (unrestricted): " in ye Lunr
*/
log close
set more on

