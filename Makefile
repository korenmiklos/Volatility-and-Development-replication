data/derived/allfactors.dta: preparefactors.do data/derived/preparedshares.dta
	stata -b do $<
data/derived/preparedshares.dta: meanreturns.do data/wdi/wdiilo.dta data/wdi/wdinew.dta
	stata -b do $<