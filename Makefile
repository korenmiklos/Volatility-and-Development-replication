graphs/lowess_Country_Risk_loggdp.eps: createallgraphs.do data/derived/specmeasures.dta
	stata -b do $<
data/derived/specmeasures.dta: specmeasures.do data/derived/allfactors.dta data/derived/meanlaborprod_wide.dta data/derived/preparedshares.dta data/wdi/wdinew.dta
	stata -b do $<
data/derived/allfactors.dta: preparefactors.do data/derived/preparedshares.dta
	stata -b do $<
data/derived/preparedshares.dta: meanreturns.do data/wdi/wdiilo.dta data/wdi/wdinew.dta
	stata -b do $<