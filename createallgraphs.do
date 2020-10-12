use "data/derived/specmeasures.dta", clear
tsset, clear

drop if rgdpch==0

gen loggdp = log(rgdpch)

rename COV Sector_Country_Covariance
rename SECT Sectoral_Risk
rename HERF Herfindahl
rename dnHERF Weighted_Herf
rename TAU2 Country_Risk
rename dnRISK Overall_risk
rename BETA Sector_Country_Beta

label var loggdp "Log Real GDP per capita (PPP)"

label var Herfindahl "Herfindahl Index"
label var Weighted_Herf "Weighted Herfindahl"
label var Sectoral_Risk "Sectoral Risk"
label var Country_Risk "Country Risk"
label var Overall_risk "Overall Risk"
label var Sector_Country_Beta "Sector-Country Beta"
label var Sector_Country_Covariance "Sector-Country Covariance"


foreach X of varlist  Herfindahl Weighted_Herf Sectoral_Risk Sector_Country_Beta {
	do drawgraphs `X' loggdp
}

lowess Country_Risk loggdp if year==1990, msize(tiny) scheme(s1mono)
graph export "graphs/lowess_Country_Risk_loggdp.eps",  replace

