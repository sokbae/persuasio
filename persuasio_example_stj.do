******************************************************************************* 
* Stata file to replicate an example
* reported in Jun, Sung Jae, and Sokbae Lee. 2021.
* "persuasio: Estimating the Effect of Persuasion in Stata". 
*
* Original Data Source:
* Gerber, Alan S., Dean Karlan, and Daniel Bergan. 2009. 
* "Does the Media Matter? A Field Experiment Measuring the Effect of Newspapers 
* on Voting Behavior and Political Opinions." 
* American Economic Journal: Applied Economics, 1 (2): 35-52.
*
* The dataset is available at: https://doi.org/10.3886/E113559V1
* A subset of the original dataset is prepared for this example.

* We would like to thank the authors of the original study 
* to make their data available online. 
*
* Modified on 20 January 2021
******************************************************************************* 

clear
cap log close
set more off

cd /Users/sokbaelee/Dropbox/Persuasion/STATAcode/persuasio
	
*************************************
**** Examples for persuasio.ado *****
*************************************

* Data summary

sjlog using "examples/pers_data", replace
use GKB_stj, clear
by post, sort: tab voteddem_all readsome
sjlog close, replace

*************************************
**** Examples without Covariates ****
*************************************

* The first example conducts inference on APR when y,t,z are observed.

sjlog using "examples/pers_apr_normal", replace
persuasio apr voteddem_all readsome post, level(80) method("normal")
sjlog close, replace


sjlog using "examples/pers_apr_boot", replace
set seed 339487731
persuasio apr voteddem_all readsome post, ///
	level(80) method("bootstrap") nboot(1000)
sjlog close, replace
	
* The second example conducts inference on LPR when y,t,z are observed.
		
sjlog using "examples/using pers_lpr", replace	
persuasio lpr voteddem_all readsome post, level(80) method("normal") 
sjlog close, replace


* The third example conducts inference on APR and LPR when y,z are observed only. 		

sjlog using "examples/using pers_apr_yz", replace
persuasio yz voteddem_all post, level(80) method("normal")
sjlog close, replace

* The fourth example considers the case when we have summary statistics on Pr(y=1|z) and/or Pr(t=1|z).

sjlog using "examples/using pers_calc", replace
foreach var in voteddem_all readsome { 
	foreach treat in 0 1 {
		qui sum `var' if post == `treat'
		scalar `var'_`treat' = r(mean)
	}
}
persuasio calc voteddem_all_1 voteddem_all_0 readsome_1 readsome_0
sjlog close, replace

sjlog using "examples/pers_calc_yz", replace
persuasio calc voteddem_all_1 voteddem_all_0
sjlog close, replace

*************************************
**** Examples with Covariates    ****
*************************************

* The first example conducts inference on APR when y,t,z are observed along with x.

sjlog using "examples/pers_apr_normal_with_x", replace
persuasio apr voteddem_all readsome post MZwave2
sjlog close, replace

sjlog using "examples/pers_apr_boot_with_x", replace
set seed 339487731
qui persuasio apr voteddem_all readsome post MZwave2, ///
	level(80) method("bootstrap") nboot(1000)
* display estimation results
mat list e(apr_est)	
mat list e(apr_ci)	
qui persuasio apr voteddem_all readsome post MZwave2, ///
	level(80) model("interaction") method("bootstrap") nboot(1000)
* display estimation results
mat list e(apr_est)	
mat list e(apr_ci)		
sjlog close, replace

* The second example conducts inference on APR and LPR when y,z are observed with a covariate, MZwave2. 		

sjlog using "examples/pers_lpr_with_x", replace
persuasio lpr voteddem_all readsome post MZwave2, level(80) 
set seed 339487731	
qui persuasio lpr voteddem_all readsome post MZwave2, ///
	level(80) model("interaction") method("bootstrap") nboot(1000)
* display estimation results
mat list e(lpr_est)	
mat list e(lpr_ci)			
sjlog close, replace
	
exit
		  
