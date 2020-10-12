
*********this is for ilowdi
capture log close
set logtype text

*log using "now we're creating all the beautiful graphs", replace
cd c:/P1-Div/
use wdiilominimumvariance, clear
drop if cname==""
drop if HERF==0

tsset, clear


drop if rgdpch==0
*USA = 840



gen loggdp = log(rgdpch)
lowess HERF loggdp , msize(tiny) scheme(s1mono)

rename COV Sector_Country_Covariance
rename SECT Sectoral_Risk
rename HERF Herfindahl
rename dnHERF Weighted_Herf
rename TAU2 Country_Risk
rename dnRISK Overall_risk
rename BETA Sector_Country_Beta
*rename Fs2 Textiles
*rename Fs16 Electric_Machinery
rename DIST1 Dist_to_Own_Frontier
rename DIST2 Dist_to_World_Frontier

label var loggdp "Log Real GDP per capita (PPP)"



label var Herfindahl "Herfindahl Index"
label var Weighted_Herf "Weighted Herfindahl"
label var Sectoral_Risk "Sectoral Risk"
label var Country_Risk "Country Risk"
label var Overall_risk "Overall Risk"
label var Sector_Country_Beta "Sector-Country Beta"
label var Sector_Country_Covariance "Sector-Country Covariance"
*label var Textiles "Textiles"
*label var Electric_Machinery "Electric Machinery"
label var Dist_to_Own_Frontier "Distance to Own Frontier"
label var Dist_to_World_Frontier "Distance of Own to World Frontier"






foreach X of varlist  Herfindahl Weighted_Herf Sectoral_Risk Sector_Country_Cov Dist_to_Own_Frontier Dist_to_World_Frontier {
	do drawgraphs `X' loggdp
}

*lowess Country_Risk loggdp if year==1990 &Country_Risk<.04, msize(tiny) scheme(s1mono)


lowess Country_Risk loggdp if year==1990, msize(tiny) scheme(s1mono)
graph export "c:/P1-Div/miklosjm/Country_Risk.ps", as(ps) replace
log close
/*lowess Dist_to_World_Frontier loggdp if Dist_to_World_Frontier<.4, msize(tiny) scheme(s1mono)
lowess Dist_to_World_Frontier loggdp , msize(tiny) scheme(s1mono)
*graph save "/export/home/a1remst/lowess_Dist_to_World_Frontier",  replace
*/
log close
