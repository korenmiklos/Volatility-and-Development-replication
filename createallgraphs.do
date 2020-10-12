capture log close
set logtype text

log using "now we're creating all the beautiful graphs", replace

use specmeasures, clear

tsset, clear

drop if rgdppcp==0
gen loggdp = log(rgdppcp)

label var loggdp "Log GDP per capita (constant 1995 US$)"

label var herf "Herfindahl index"
label var specind "Industry risk"
label var tau2 "Country risk"
label var risk "Overall risk"
label var betacnt "Industry beta"

label var share1 "Food+beverage+tobacco"
*
*


for var herf specind speccnt tau2 risk: gen X_rescaled = X/minrisk
for var herf specind tau2 risk speccnt: global varlab: var label X \label var X_rescaled "$varlab X rel. to min. var."

do drawgraphs herf specind

for var herf specind tau2 risk betacnt: do drawgraphs X loggdp
for var herf specind tau2 risk: do drawgraphs X_rescaled loggdp

for var share*: do drawgraphs X loggdp
for var share*: do drawgraphs herf X 
for var share*: do drawgraphs specind X 

log close
