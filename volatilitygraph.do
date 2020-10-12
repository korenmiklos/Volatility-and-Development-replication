gen lgdpch=ln(gdpch)
tsset cname year
gen sd=lgdpch-L1.lgdpch
egen nyear=count(sd) if sd~=.
 

twoway (scatter min2 y) (line pre y), scheme(s1color)
graph export h:/p1-div/min.gph,  replace
reg sd1 y
predict psd1

twoway (scatter sd1 y) (line psd1 y) , scheme(s1color)
graph export h:/p1-div/sd1.gph, replace

