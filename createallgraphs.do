use "data/derived/specmeasures.dta", clear
tsset, clear

drop if rgdpch==0

gen loggdp = log(rgdpch)

rename COV Sector_Country_Covariance
rename GSECT Sectoral_Risk
rename HERF Herfindahl
rename AVAR Average_Variance 
rename IDIO Idiosyncratic_Risk
rename CNT Country_Risk
rename RISK Overall_risk

label var loggdp "Log Real GDP per capita (PPP)"

label var Herfindahl "Concentration"
label var Average_Variance "Average Idiosyncratic Variance"
label var Idiosyncratic_Risk "Idiosyncratic Risk"
label var Sectoral_Risk "Sectoral Risk"
label var Country_Risk "Country Risk"
label var Overall_risk "Overall Risk"
label var Sector_Country_Covariance "Sector-Country Covariance"


foreach X of varlist  Herfindahl Idiosyncratic_Risk Sectoral_Risk Sector_Country_Covariance Average_Variance {
	do drawgraphs `X' loggdp
}

replace Country_Risk = ln(Country_Risk)
* since log does not have a scale, set mean to 0
summarize Country_Risk, meanonly
replace Country_Risk = Country_Risk - r(mean)
label var Country_Risk "Country Risk (log)"

lowess Country_Risk loggdp if year==1980, msize(tiny) scheme(s1mono)
graph export "graphs/lowess_Country_Risk_loggdp.eps",  replace
