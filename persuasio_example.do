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

global covariates "MBfemale Mreportedage MBvoted2004 MBvoted2002 MBvoted2001 MBconsumer MBgetsmag MBpreferrepub MBprefernoone Mwave2 MZBfemale MZreportedage MZBvoted2004 MZBvoted2002 MZBvoted2001 MZBconsumer MZBgetsmag MZBpreferrepub MZBprefernoone MZwave2"

global covariates "MBfemale Mreportedage MZBfemale MZreportedage MZBvoted2004 MZBvoted2002 MZBvoted2001 MZBconsumer MZBgetsmag MZBpreferrepub MZBprefernoone MZwave2"


*********************************************************
**** Calculation Example *****
*********************************************************

foreach var in voteddem_all readsome { 

	foreach treat in 0 1 {
		
		sum `var' if post == `treat'
		scalar `var'_`treat' = r(mean)

		}
}

calc4persuasio voteddem_all_1 voteddem_all_0 readsome_1 readsome_0


*********************************************************
**** Part I: Lower Bound on Average Persuation Rate *****
*********************************************************

cipe4yz voteddem_all post, level(80) method("normal") title("w/o covariates: normal")

cipe4yz voteddem_all post, level(80) method("bootstrap") nboot(1000) title("w/o covariates: bootstrap")

tab cells, generate(cell_indicators)

cipe4yz voteddem_all post $covariates, level(80) nboot(1000) method("bootstrap") title("w covariates: bootstrap")

