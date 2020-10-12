graphs/lowess_Country_Risk_loggdp.eps: createallgraphs.do data/derived/specmeasures.dta drawgraphs.do
	stata -b do $<
data/derived/specmeasures.dta: specmeasures.do data/derived/allfactors.dta data/derived/meanlaborprod_wide.dta data/derived/preparedshares.dta data/wdi/wdinew.dta
	stata -b do $<
data/derived/allfactors.dta: preparefactors.do data/derived/preparedshares.dta
	stata -b do $<
data/derived/preparedshares.dta: meanreturns.do data/unido/unido-dollar.dta data/wdi/wdinew.dta data/pwt/pwt_prices.dta
	stata -b do $<