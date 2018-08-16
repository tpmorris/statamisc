*! Tim Morris 16 Aug 2018
* Simulation demo that a method with constant bias gets lower coverage with higher sample size.
* Note: simsum package required in your adopath
set seed 341769

* Input your value of bias here:
local bias 0.1
* set run to 1 if you want to actually run sim
local run 1

if `run' {
tempname estimates
postfile `estimates' int(rep) int(n) float(beta se df) using estimates , replace
set coeftabresults off
quietly {
noi _dots 0, title("Simulation running...")
timer on 1
forval r = 1/1000 {
	noi _dots `r' 0
	clear
	set obs 10000
	gen float y = rnormal(0,1) // truth is mean 0
	foreach n of numlist 10 100 1000 10000 {
		reg y in 1/`n' // this is doing in in the first `n' observations
		post `estimates' (`r') (`n') (_b[_cons]) (_se[_cons]) (`e(df_r)')
	}
}
timer off 1
timer list
}
set coeftabresults on
postclose `estimates'
}

use estimates, clear
expand 2, generate(method)
	lab def method 0 "Bias=0" 1 "Bias=`bias'"
	lab val method method
* Next line: the true beta is unbiased. I'm going to create one with bias independent of n
replace beta = beta + `bias' if method

simsum beta, id(rep) se(se) df(df) by(n) true(0) methodvar(method) cover mcse clear

twoway (scatter beta0 n, c(l)) (scatter beta1 n, c(l)), xscale(log) xlab(10 100 1000 10000)
