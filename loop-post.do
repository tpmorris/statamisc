*! Tim Morris 05apr2018
* File to introduce for-loops in Stata and posting information out to a file
version 14         // in Stata, every file should start with a version number
set seed 98716     // setting the random seed (in a sensible place) is critical fr any file involving random draws
local reps 1000    // stores the number of reps I want in `reps'

* 1.
* A basic loop-and-post
* I'm going to 'name' the place for posting results 'me' and this name can be anything
* It's not the output filename, just a name you refer to with the -post- commands (yeah, that's weird)
capture postclose me      // this line says to close 'me' if it's currently open (if not, it does nothing)
* The following declares that my post name is 'me', my output
* file is 'outsimple.dta', and that there is one variable (number) to be posted
postfile me number using outsimple.dta, replace
forvalues i = 1 / `reps' {
	post me (`i')       // post the value of `i' to the postfile named 'me'
}
postclose me
* Now we can use the file we created
use outsimple, clear
list in 1/10


* Now for something a bit more involved #1
tempname me // by using tempname, I don't have to close my postfile if there is an erro
* The following declares that my post name is `me' (note how the tempname is referenced),
* my output file is 'outfile1.dta', and that there are six variables to be posted
postfile `me' id b_length se_length b_mpg se_mpg df using outfile1.dta, replace

set coeftabresults off // this can speed things up a lot - use it when running this sort of code
quietly { // this suppresses display of every single result as Stata loops round - turn it off if you want to see what's happening.
	* The following line creates a nice display of how things are going
	noisily _dots 0, title("Loop running...")
	* Open the loop. The name i means that, within the loop, `i' refers to the number of the current loop
	forvalues i = 1 / `reps' {
		noi _dots `i' 0           // displays a dot each time a new rep starts
		sysuse auto, clear        // Load the auto dataset
		bsample   								// draw a random sample-with-replacement of size _N
		regress price length mpg  // fit some regression model
		* In the following, note that _b[.] refers to a coefficient, _se[.] refers to se
		* you just place the appropriate parameter name inside [.]
		post `me' (`i') (_b[length]) (_se[length]) (_b[mpg]) (_se[mpg]) (e(df_r))
	}
}
postclose `me'                // close the postfile. You can now load the datafile it produces (outfile.dta).

* We can now use the file we created and do stuff with the results
use outfile1.dta, clear
compress                      // reduces unnecessary storage space used by some variables - can speeds things up
list in 1/10
twoway scatter b_length b_mpg
regress b_length b_mpg


* Now for something a bit more involved #2
* Sometimes we might want 'long' results on separate rows
* Let's be extreme and do a separate row for length, mpg, coefficient and se
tempname me
* The following declares that my post name is `me' (note how the tempname is referenced),
* my output file is 'outfile2.dta', and that there are four variables to be posted
* Note how I specify storage type for the variables
postfile `me' int(id) str6(var bse) float(est) using outfile2.dta, replace

set coeftabresults off
quietly {
	noisily _dots 0, title("Loop running...")
	forvalues i = 1 / `reps' {
		noi _dots `i' 0
		sysuse auto, clear
		drop if runiform() < .3
		regress price length mpg
		* I now post a separate row for each thing I want to post
		post `me' (`i') ("Length") ("coeff") (_b[length])
		post `me' (`i') ("Length") ("std err") (_se[length])
		post `me' (`i') ("MPG") ("coeff") (_b[mpg])
		post `me' (`i') ("MPG") ("std err") (_se[mpg])
	}
}
postclose `me'              // close the postfile. You can now load the datafile it produces (outfile.dta).

* We can now use the file we created and do stuff with the results
use outfile2.dta, clear
compress                      // reduces unnecessary storage space used by some variables - can speeds things up
list in 1/10
twoway hist est, by(bse var, xrescale yrescale) freq

