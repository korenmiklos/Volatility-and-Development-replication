tempvar y1 y2 u
local lbl : variable label `1'

* if risk measure is strictly positive, take logs
summarize `1'
scalar min = r(min)
if (min > 0) {
	generate `y1' = ln(`1')
	* demean all logs to have 0 mean
	summarize `y1', meanonly
	replace `y1' = `y1' - r(mean)
	label variable `y1' "`lbl' (log)"
}
else {
	generate `y1' = `1'
	label variable `y1' "`lbl'"
}
clonevar `y2' = `y1'

lowess `y1' `2', bwidth(0.5) msymbol(circle) msize(tiny) scheme(s1manual) plotregion(ilwidth(medthin))
graph export "graphs/lowess_`1'_`2'.eps", replace

xtreg `y1' `2', i(country) fe
predict `u', u
replace `y2' = `y1' - `u'

lowess `y2' `2', bwidth(0.5) msymbol(circle) msize(tiny) scheme(s1manual) plotregion(ilwidth(medthin))
graph export "graphs/within_`1'_`2'.eps", replace

