{smcl}

{p 4 4 2}
{it:version 0.1.0} 


{title:Title}

{phang}{cmd:persuasio4yz} {hline 2} Conducts causal inference on persuasive effects for binary outcomes {it:y} and binary instruments {it:z}


{title:Syntax}

{p 8 8 2} {cmd:persuasio4yz} {it:depvar} {it:instrvar} [{it:covariates}] [{it:if}] [{it:in}] [, {cmd:level}(#) {cmd:model}({it:string}) {cmd:method}({it:string}) {cmd:nboot}(#) {cmd:title}({it:string})]

{p 4 4 2}{bf:Options}

{col 5}{it:option}{col 24}{it:Description}
{space 4}{hline 44}
{col 5}{cmd:level}(#){col 24}Set confidence level; default is {cmd:level}(95)
{col 5}{cmd:model}({it:string}){col 24}Regression model when {it:covariates} are present; default is "no_interaction"
{col 5}{cmd:method}({it:string}){col 24}Inference method; default is {cmd:method}("normal")
{col 5}{cmd:nboot}(#){col 24}Perform # bootstrap replications; default is {cmd:nboot}(50)
{col 5}{cmd:title}({it:string}){col 24}Title of estimation
{space 4}{hline 44}

{title:Description}

{cmd:persuasio4yz} conducts causal inference on persuasive effects for binary outcomes {it:y} and binary instruments {it:z}. 

{p 4 4 2}
This command is for the case when persuasive treatment ({it:t}) is unobserved, using estimates of the lower bound on the average persuation rate (APR) via this package{c 39}s command {cmd:aprlb}.

{p 4 4 2}
{it:varlist} should include {it:depvar} {it:instrvar} {it:covariates} in order. Here, {it:depvar} is binary outcomes ({it:y}), {it:instrvar} is binary instruments ({it:z}), and {it:covariates} ({it:x}) are optional. 

{p 4 4 2}
When treatment {it:t} is unobserved, the upper bound on the APR is just 1. 

{p 4 4 2}
There are two cases: (i) {it:covariates} are absent and (ii) {it:covariates} are present.

{break}    - If {it:covariates} are absent, the lower bound (theta_L) on the APR is defined by 

{p 4 4 2}
	theta_L = {Pr( {it:y} = 1 | {it:z} = 1 ) - Pr( {it:y} = 1 | {it:z} = 0 )}/{1 - Pr( {it:y} = 1 | {it:z} = 0 )}.

{p 4 4 2}
	The estimate and confidence interval are obtained by the following procedure:
	
{break}    	1. Pr( {it:y} = 1 | {it:z} = 1 ) and Pr( {it:y} = 1 | {it:z} = 0 ) are estimated by regressing {it:y} on {it:z}.
{break}    	2. The lower bound on the APR is computed using the estimates obtained above.
{break}    	3. The standard error of the estimate is computed via STATA command {cmd:nlcom}.
{break}    	4. Then, a confidence interval for the APR is set by [ {it:est} - {it:cv} * {it:se} , 1 ], 
	   where {it:est} is the estimate, {it:se} is the standard error, and
	   {it:cv} is the one-sided standard normal critical value (e.g., {it:cv} = 1.645 for {cmd:level}(95)).
	
{break}    - If {it:covariates} are present, the lower bound (theta_L) on the APR is defined by 

{p 4 4 2}
	theta_L = E [ theta_L(x) ],
	
{p 4 4 2}
	where

{p 4 4 2}
	theta_L(x) = {Pr( {it:y} = 1 | {it:z} = 1, {it:x} ) - Pr( {it:y} = 1 | {it:z} = 0, {it:x} )}/{1 - Pr( {it:y} = 1 | {it:z} = 0, {it:x} )}.
		
{p 4 4 2}
	The estimate and confidence interval are obtained by the following procedure.
	
{p 4 4 2}
	If {cmd:model}("no_interaction") is selected (default choice),
	
{break}    	1. Pr( {it:y} = 1 | {it:z} , {it:x} ) is estimated by regressing {it:y} on {it:z} and {it:x}.
	
{p 4 4 2}
	Alternatively, if {cmd:model}("interaction") is selected,
	
{break}    	1a. Pr( {it:y} = 1 | {it:z} = 1, {it:x} ) is estimated by regressing {it:y} on {it:x} given {it:z} = 1.
{break}    	1b. Pr( {it:y} = 1 | {it:z} = 0, {it:x} ) is estimated by regressing {it:y} on {it:x} given {it:z} = 0.
	
{p 4 4 2}
	Ater step 1, both options are followed by:
	
{break}    	2. For each x in the estimation sample, theta_L(x) is computed using the estimates obtained above.
{break}    	3. The estimates of theta_L(x) are averaged to obtain the estimate of theta_L.
{break}    	4. A bootstrap confidence interval for the APR is set by [ bs_est({it:alpha}) , 1 ],
	   where bs_est({it:alpha}) is the {it:alpha} quantile of the bootstrap estimates of theta_L
	   and 1 - {it:alpha} is the confidence level.    {break}
	
{p 4 4 2}
	The bootstrap procedure is implemented via STATA command {cmd:bootstrap}. 
		

{title:Options}

{cmd:model}({it:string}) specifies a regression model of {it:y} on {it:z} and {it:x} when {it:covariates} are present. 

{p 4 4 2}
The default option is "no_interaction" between {it:z} and {it:x}. When "interaction" is selected, full interactions between {it:z} and {it:x} are allowed; this is accomplished by estimating Pr( {it:y} = 1 | {it:z} = 1, {it:x} ) and Pr( {it:y} = 1 | {it:z} = 0, {it:x} ), separately.

{cmd:level}(#) sets confidence level; default is {cmd:level}(95). 

{cmd:method}({it:string}) refers the method for inference; default is {cmd:method}("normal").
By the naure of identification, one-sided confidence intervals are produced. 

{break}    	1. When {it:covariates} are present, it needs to be set as {cmd:method}("bootstrap"); otherwise, the confidence interval will be missing.
	
{break}    	2. When {it:covariates} are absent, both options "normal" and "bootstrap" yield non-missing confidence intervals.
	
{cmd:nboot}(#) chooses the number of bootstrap replications; default is {cmd:nboot}(50).
It is only relevant when {cmd:method}("bootstrap") is selected.

{cmd:title}({it:string}) specifies the title of estimation.


{title:Remarks}

{p 4 4 2}
It is recommended to use {cmd:nboot}(#) with # at least 1000. 
A default choice of 50 is meant to check the code initially 
because it may take a long time to run the bootstrap part when there are a large number of covariates.
The bootstrap confidence interval is based on percentile bootstrap.
A use of normality-based bootstrap confidence interval is not recommended 
because bootstrap standard errors can be unreasonably large in applications. 


{title:Examples }

{p 4 4 2}
We first call the dataset included in the package.

{p 4 4 2}
		. use GKB, clear

{p 4 4 2}
The first example conducts inference on the APR without covariates, using normal approximation.
		
{p 4 4 2}
		. persuasio4yz voteddem_all post, level(80) method("normal")
		
{p 4 4 2}
The second example conducts bootstrap inference on the APR.
		
{p 4 4 2}
		. persuasio4yz voteddem_all post, level(80) method("bootstrap") nboot(1000)	
		
{p 4 4 2}
The third example conducts bootstrap inference on the APR with a covariate, MZwave2, interacting with the instrument, post. 
		
{p 4 4 2}
		. persuasio4yz voteddem_all post MZwave2, level(80) model("interaction") method("bootstrap") nboot(1000)			
		

{p 4 4 2}
The fourh example consider a large number of covariates. This example runs slower than the previous example. 

{p 4 4 2}
		. persuasio4yz voteddem_all post doperator*, level(80) method("bootstrap") nboot(1000)


{title:Stored results}

{p 4 4 2}{bf:Matrices}

{p 8 8 2} {bf:e(lb_est)}: (1*2 matrix) bounds on the average persuasion rate in the form of [lb, 1]

{p 8 8 2} {bf:e(lb_ci)}: (1*2 matrix) confidence interval for the average persuasion rate in the form of [lb_ci, 1] 


{p 4 4 2}{bf:Macros}

{p 8 8 2} {bf:e(cilevel)}: confidence level

{p 8 8 2} {bf:e(inference_method)}: inference method: "normal" or "bootstrap" 


{title:Authors}

{p 4 4 2}
Sung Jae Jun, Penn State University, <sjun@psu.edu> 

{p 4 4 2}
Sokbae Lee, Columbia University, <sl3841@columbia.edu>


{title:License}

{p 4 4 2}
GPL-3


{title:References}

{p 4 4 2}
Sung Jae Jun and Sokbae Lee (2019), 
Identifying the Effect of Persuasion, 
{browse "https://arxiv.org/abs/1812.02276":arXiv:1812.02276 [econ.EM]} 



