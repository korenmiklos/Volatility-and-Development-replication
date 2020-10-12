*****Define two program to draw lowess and within graphs

******First (Lowess)

capture program drop draw_first

program define draw_first `1' `2' `3'

* `1': name of the var to plot against 
* `2': x
*`3': Figure Number 

set more off

lowess `1' `2', msize(tiny) ysize(3.5) xsize(3.5) title ("Figure `3': `1'", size(medium)) adjust scheme(s1mono)
graph save lowess_`1'_`2',  replace

end


************Second (Within)

capture program drop draw_second

program define draw_second `1' `2' `3'

capture gen `2'2 = `2'^2
capture gen `2'3 = `2'^3
capture gen `2'4 = `2'^4
capture drop u
capture drop fitted
capture drop `1'within

xtreg `1' `2' `2'2 `2'3 `2'4, i(country) fe 
predict u, u
gen `1'_within = `1'-u
predict fitted, xb
label var fitted "Fitted"

lowess `1'_within `2', msize(tiny) ysize(3.5) xsize(3.5) title(Figure `3': `1' (within), size(medium)) adjust scheme(s1mono)
graph save within_`1'_`2', replace

end

****************************************


******Here Starts Our Work********************


capture log close
set logtype text
set more off

clear
set mem 500m

use minimumvariance, clear

sort cnum
merge cnum using cnum2iso
tab _
drop _

tsset, clear

drop if rgdpch==0
gen loggdp = log(rgdpch)
rename COV2 Sector_Country_Covariance
rename SECT Sectoral_Risk
rename HERF Herfindahl
rename dnHERF Weighted_Herfindahl
rename TAU2 Country_Risk
rename RISK Overall_risk
rename BETA Sector_Country_Beta
rename Fs2 Textiles
rename Fs16 Electric_Machinery
rename DIST1 Dist_to_Own_Frontier
rename DIST2 Dist_to_World_Frontier

label var loggdp "Log Real GDP per capita (PPP)"
label var Herfindahl "Herfindahl Index"
label var Weighted_Herfindahl "Weighted Herfindahl"
label var Sectoral_Risk "Sectoral Risk"
label var Country_Risk "Country Risk"
label var Overall_risk "Overall Risk"
label var Sector_Country_Beta "Sector-Country Beta"
label var Sector_Country_Covariance "Sector-Country Covariance"
label var Textiles "Textiles"
label var Electric_Machinery "Electric Machinery"
label var Dist_to_Own_Frontier "Distance to Own Frontier"
label var Dist_to_World_Frontier "Distance of Own to World Frontier"
label var openk "Openness"

*Figure 1-14
local myvar "Sectoral_Risk Weighted_Herfindahl Textiles Electric_Machinery Country_Risk Sector_Country_Beta Dist_to_Own_Frontier Dist_to_World_Frontier"

local i=1

**This i is the figure number, so it automatically add the figure number to each graphs

foreach x of local myvar {
 draw_first `x' loggdp `i'
 local i=`i'+1
 draw_second `x' loggdp `i' 
  if ("`x'"!="Country_Risk") local i=`i'+1
 }


*****for some graphs we have to exclude certain observations. so we draw them one by one, and replace the old ones. 

**Figure 9: draw only for year 1980, Country_Risk<0.04

lowess Country_Risk loggdp if year==1980 & Country_Risk<.04, msize(small)  ysize(3.5) xsize(3.5)  title ("Figure 9: Country_Risk (1980)", size(medium)) scheme(s1mono)
graph save lowess_Country_Risk_loggdp,  replace
graph export lowess_Country_Risk_loggdp.ps, as(ps) replace


**Figure 14: draw only for year 1980, Dist_to_World_Frontier<0.4

lowess Dist_to_World_Frontier loggdp if Dist_to_World_Frontier<.4 & year==1980, msize(small) title ("Figure 14: Distance of Own to World Frontier (1980) ", size(medium)) scheme(s1mono)
graph save lowess_Dist_to_World_Frontier_loggdp,  replace
graph export lowess_Dist_to_World_Frontier_loggdp.ps, as(ps) replace


**Figure 12-13: draw if Dist_to_Own_Frontier<0.06

lowess Dist_to_Own_Frontier loggdp if Dist_to_Own_Frontier>0 & Dist_to_Own_Frontier<0.06, msize(tiny) title ("Figure 12: Dist_to_Own_Frontier", size(medium)) scheme(s1mono)
graph save lowess_Dist_to_Own_Frontier_loggdp,  replace
graph export lowess_Dist_to_Own_Frontier_loggdp.ps, as(ps) replace


lowess Dist_to_Own_Frontier_within loggdp if Dist_to_Own_Frontier>0 & Dist_to_Own_Frontier<0.06, msize(tiny) title ("Figure 13: Dist_to_Own_Frontier (within)", size(medium)) scheme(s1mono)
graph save within_Dist_to_Own_Frontier_loggdp,  replace
graph export within_Dist_to_Own_Frontier_loggdp.ps, as(ps) replace


