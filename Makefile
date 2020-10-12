data/derived/preparedshares.dta: meanreturns.do data/wdi/wdiilo.dta data/wdi/wdinew.dta
	stata -b do $<