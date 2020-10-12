preserve
	use "data/derived/shares.dta", clear

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
restore
