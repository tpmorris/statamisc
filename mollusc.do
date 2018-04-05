*! Tim Morris 05apr2018
version 15

* Attempt to reproduce the 'mathematical art' mollusc at:
* http://blog.revolutionanalytics.com/2018/04/mathematical-art-in-r-.html
* It produces a grid of values for s and theta, then creates trigonometric
* functions of these in x, y and z.
* I have used the same naming.
clear *

* set up locals - can mess around with these and see the effect on the graph
local alpha 80
local beta 40
local phi 55
local mu 10
local omega 30
local s_min -270
local s_max 62
local A 25
local a 12
local b 16
local P 2
local W_1 1
local W_2 1
local N 1
local L 0
local D 1
local theta_start 0
local theta_end = 10*_pi

* in the R version, there are 1001 values of theta and something like `s_max'-`s_min' of s
set obs 1001
egen int s = seq() , from(`s_min') to(`s_max')
egen theta = seq() , from(`=`theta_start'*1000') to(`=round(`theta_end'*1000,1)')
replace theta = theta/(1000/31.83)

* fillin expands data to contain all possible combinations of theta and s
fillin s theta
drop _fillin

gen float f_theta = 360/`N'*(theta*`N'/360-round(theta*`N'/360, 1))
gen float R_e = (`a'^(-2)*(cos(s))^2+`b'^(-2)*(sin(s))^2)^(-0.5)
gen byte k = `L'*exp(-(2*(`s'-`P')/`W_1')^2)*exp(-(2*f_theta/`W_2')^2)
gen float R = R_e + k
gen float thetaomega = theta + `omega'
gen int sphi = s + `phi'
gen float x = `D'*(`A'*sin(`beta')+R*cos(sphi)*cos(thetaomega)-R*sin(`mu')*sin(sphi)*sin(theta))*exp(theta/tan(`alpha'))
gen float z = (-`A'*cos(`beta')+R*sin(sphi)*cos(`mu'))*exp(theta/tan(`alpha'))
gen float y = (-`A'*sin(`beta')-R*cos(sphi)*sin(thetaomega)-R*sin(`mu')*sin(sphi)*cos(theta))*exp(theta/tan(`alpha'))
drop f_theta R* k thetaomega sphi // get rid of superfluous variables

* Need to run all the following for the graph
summ x, meanonly
	local xmin = r(min)
	local xmax = r(max)
summ z, meanonly
	local zmin = r(min)
	local zmax = r(max)
local marg 120
local plainopts lc(white%1) plotregion(style(none) m(zero)) graphregion(color(gs2) m(zero)) yla(none,nogrid) xla(none,nogrid) xtit("") ytit("")
twoway line x z, sort(theta s) `plainopts' lw(vthin) ysca(reverse r(`=`xmin'-`marg'' `=`xmax'+`marg'')) xsca(reverse r(`=`zmin'-`marg'' `=`zmax'+`marg'')) ysize(7) xsize(7) aspect(1)
graph export mollusc-stata.svg, replace
