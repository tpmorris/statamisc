# Stata nuggets
## Tim Morris

`include` allows locals to be used across _multiple_ .do files. I like to create a file called tim.doh (arbitrary extension name) which defines locals, then my .do file says:  
`. include tim.doh`  
to inherit all the local definitions

To expand on the above, I define the locals conditionally in tim.doh. So:  
`if graphname == "a" local ylabs 0(10)50`   
`else if graphname == "b" local ylabs 50(10)100`

To refer to the label rather than value, use code `"label":label_name`  
`. summ price if foreign=="Domestic":origin`

`labmask` (Nick Cox) allows you to label a numeric variable according to values of a string in the same dataset

If you name a global `F#`, then hitting the (e.g.) `F9` key after running the command gives you the contents of the global:  
`. global F9 twoway scatter y x`  
[Hit F9] pastes the string: "twoway scatter y x"

tempfiles can sometimes end up somewhere non-temporary (only seen this in user-written commands). To check where tempfiles are going, you can submit:  
`. tempfile wheresmytempfile`  
```. display "`wheresmytempfile'"```

Using `compress` reduces the storage used by variables (e.g. reduces float to int or byte), or str30 to str14 or whatever.

`. set coeftabresults off`   
stops Stata from putting results of an estimation command in r(.). You can still get _b[.] and _se[.] etc, which are estimation results.

`regexm` is great! Check whether strings contain a substring:  
`. count if regexm(stringvar,"substring")`

To change things in a file, use `filefilter`. For example, I used this with SVG, where I wanted to add an opacity attribute to all symbols on a graph. You use   
`. filefilter orig.ext new.ext, from("search string") to("replace string")`