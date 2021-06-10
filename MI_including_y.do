clear *

version 17
set seed 2
matrix corr = (1, .5 \ .5, 1)
drawnorm y xfull, corr(corr) n(10000)

twoway (scatter y xfull, mc(black%15)) ///
	(lfit y xfull, lc(black)) ///
	, legend(order(2 "Full data")) name(a, replace)


gen x=xfull if y<=0

twoway (scatter y x, mc(black%15)) ///
	(lfit y xfull, lc(black)) 	///
	(lfit y x, lc(dkgreen%70) lw(vthick)) ///
	, legend(order(2 "Full data" 3 "Complete cases")) name(b, replace)


mi set flong
mi register imputed x
mi impute regress x, add(3)
mi estimate, post: regress y x
local a_omit = _b[_cons]
local b_omit = _b[x]
twoway (scatter y x if _mi_m==0, mc(black%15)) ///
	(scatter y x if y>0, mc(magenta%15) msym(.)) 	///
	(lfit y xfull, lc(black)) ///
	(lfit y x if !_mi_m, lc(dkgreen%70) lw(vthick)) ///
	(function `a_omit'+(`b_omit'*x) ///
	, range(-4 4) lc(magenta%60) lw(vthick)) , legend(order(3 "Full data" 4 "Complete cases" 5 "MI omitting y")) name(c, replace)



mi impute regress x y, replace
mi estimate, post: regress y x
local a_incl = _b[_cons]
local b_incl = _b[x]
twoway (scatter y x if _mi_m==0, mc(black%15)) ///
	(scatter y x if y>0, mc(maroon%15) msym(.)) ///
	(lfit y xfull, lc(black)) (lfit y xfull, lc(dkgreen)) ///
	(lfit y x if !_mi_m, lc(dkgreen%70) lw(vthick)) ///
	(function `a_omit'+(`b_omit'*x), range(-4 4) lc(magenta%60) lw(vthick)) ///
	(function `a_incl'+(`b_incl'*x), range(-4 4) lc(maroon%60) lw(vthick)) ///
	, legend(order(3 "Full data" 4 "Complete cases" 6 "MI omitting y" 7 "MI including y"))  name(d, replace)


