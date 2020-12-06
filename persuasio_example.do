******************************************************************************* 
* Stata file to replicate an an empirical example
* reported in Jun, Sung Jae, and Sokbae Lee. 2020.
* "Identifying the Effect of Persuasion." https://arxiv.org/abs/1812.02276
*
* Original Data Source:
* Gerber, Alan S., Dean Karlan, and Daniel Bergan. 2009. 
* "Does the Media Matter? A Field Experiment Measuring the Effect of Newspapers 
* on Voting Behavior and Political Opinions." 
* American Economic Journal: Applied Economics, 1 (2): 35-52.
*
* The dataset is available at: https://doi.org/10.3886/E113559V1
* A subset of the original dataset is prepared in a separate STATA do file.

* We would like to thank the authors of the original study 
* to make their data available online. 
*
* Modified on 23 November 2020
******************************************************************************* 

clear
cap log close
set more off

cd /Users/sokbaelee/Dropbox/Persuasion/STATAcodes/persuasio
log using persuasion_GKB_example, replace

use GKB, clear

*********************************
**** Examples for aprlb.ado *****
*********************************

* The first example estimates the lower bound on the APR without covariates.
		
	aprlb voteddem_all post

* The second example adds a covariate.

	aprlb voteddem_all post MZwave2
		
* The third example estimates the lower bound by the covariate.		
		
	by MZwave2, sort: aprlb voteddem_all post		

	
*********************************
**** Examples for aprub.ado *****
*********************************

* The first example estimates the upper bound on the APR without covariates.
		
	aprub voteddem_all readsome post

* The second example adds a covariate.

	aprub voteddem_all readsome post MZwave2

* The third example estimates the upper bound by the covariate.		
		
	by MZwave2,sort: aprub voteddem_all readsome post
	
	
******************************************
**** Examples for calc4persuasio.ado *****
******************************************

* We first compute summary statistics.

	foreach var in voteddem_all readsome { 

		foreach treat in 0 1 {
			
			sum `var' if post == `treat'
			scalar `var'_`treat' = r(mean)

			}
	}

* Then, we calculate the bound estimates on the APR and LPR.

	calc4persuasio voteddem_all_1 voteddem_all_0 readsome_1 readsome_0
		
* We compare the above with the following.		

	calc4persuasio voteddem_all_1 voteddem_all_0

	
****************************************
**** Examples for persuasio4yz.ado *****
****************************************	

* The first example conducts inference on the APR without covariates, using normal approximation.
		
	persuasio4yz voteddem_all post, level(80) method("normal")
			
* The second example conducts bootstrap inference on the APR.
		
	persuasio4yz voteddem_all post, level(80) method("bootstrap") nboot(100)	
		
* The third example conducts bootstrap inference on the APR with a covariate, MZwave2, interacting with the instrument, post. 
		
	persuasio4yz voteddem_all post MZwave2, level(80) model("interaction") method("bootstrap") nboot(100)	
	
* The fourth example revisit the first example by the covariate.
		
	by MZwave2,sort: persuasio4yz voteddem_all post, level(80) method("normal")	
	

*****************************************
**** Examples for persuasio4ytz.ado *****
*****************************************		
				
* The first example conducts inference on the APR without covariates, using normal approximation.
		
	persuasio4ytz voteddem_all readsome post, level(80) method("normal")
		
* The second example conducts bootstrap inference on the APR.
		
	persuasio4ytz voteddem_all readsome post, level(80) method("bootstrap") nboot(100)	
		
* The third example conducts bootstrap inference on the APR with a covariate, MZwave2, interacting with the instrument, post. 
		
	persuasio4ytz voteddem_all readsome post MZwave2, level(80) model("interaction") method("bootstrap") nboot(100)
	
* The fourth example revisit the first example by the covariate.

	by MZwave2,sort: persuasio4ytz voteddem_all readsome post, level(80) method("normal")	
	
	
***********************************
**** Examples for lpr4ytz.ado *****
***********************************

* The first example estimates the LPR without covariates.
		
	lpr4ytz voteddem_all readsome post

* The second example adds a covariate.

	lpr4ytz voteddem_all readsome post MZwave2
		
* The third example allows for interactions between _x_ and _z_.

	lpr4ytz voteddem_all readsome post MZwave2, model("interaction")	
	
	
*********************************************
**** Examples for persuasio4ytz2lpr.ado *****
*********************************************			

* The first example conducts inference on the LPR without covariates, using normal approximation.
		
	persuasio4ytz2lpr voteddem_all readsome post, level(80) method("normal")
		
* The second example conducts bootstrap inference on the LPR.
		
	persuasio4ytz2lpr voteddem_all readsome post, level(80) method("bootstrap") nboot(100)	
		
* The third example conducts bootstrap inference on the LPR with a covariate, MZwave2, interacting with the instrument, post. 
		
	persuasio4ytz2lpr voteddem_all readsome post MZwave2, level(80) model("interaction") method("bootstrap") nboot(100)			
	
	
*************************************
**** Examples for persuasio.ado *****
*************************************

persuasio ytz voteddem_all readsome post, level(80) method("normal")

persuasio ytz2lpr voteddem_all readsome post, level(80) method("normal")

persuasio yz voteddem_all post, level(80) method("normal")



	
	
