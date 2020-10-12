
set more off

capture drop u
capture drop fitted
capture drop `1'within

lowess `1' `2', bwidth(0.5) adjust msymbol(circle) msize(tiny) scheme(s1manual) plotregion(ilwidth(medthin))


graph export "lowess_`1'_`2'.ps", as(ps) replace



xtreg `1' `2', i(country) fe
predict u, u
gen `1'within = `1'-u

lowess `1'within `2', bwidth(0.5) adjust msymbol(circle) msize(tiny) scheme(s1manual) plotregion(ilwidth(medthin))

graph export "within_`1'_`2'.ps", as(ps) replace

set more on
