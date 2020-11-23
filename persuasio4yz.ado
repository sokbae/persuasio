/***

_version 0.1.0_ 

Title
-----

{phang}{cmd:persuasio4yz} {hline 2} Conducts causal inference on persuasive effects for binary outcomes _y_ and binary instruments _z_

Syntax
------

> {cmd:persuasio4yz} _depvar_ _instrvar_ [_covariates_] [_if_] [_in_] [, {cmd:level}(#) {cmd:model}(_string_) {cmd:method}(_string_) {cmd:nboot}(#) {cmd:title}(_string_)]

### Options

| _option_          | _Description_           | 
|-------------------|-------------------------|
| {cmd:level}(#) | Set confidence level; default is {cmd:level}(95) |
| {cmd:model}(_string_)   | Regression model when _covariates_ are present; default is "no_interaction" |
| {cmd:method}(_string_) | Inference method; default is {cmd:method}("normal")    |
| {cmd:nboot}(#) | Perform # bootstrap replications; default is {cmd:nboot}(50) |
| {cmd:title}(_string_) | Title of estimation     |

Description
-----------

{cmd:persuasio4yz} conducts causal inference on persuasive effects for binary outcomes _y_ and binary instruments _z_. 

This command is for the case when persuasive treatment (_t_) is unobserved, using estimates of the lower bound on the average persuation rate (APR) via this package's command {cmd:aprlb}.

_varlist_ should include _depvar_ _instrvar_ _covariates_ in order. Here, _depvar_ is binary outcomes (_y_), _instrvar_ is binary instruments (_z_), and _covariates_ (_x_) are optional. 

When treatment _t_ is unobserved, the upper bound on the APR is just 1. 

There are two cases: (i) _covariates_ are absent and (ii) _covariates_ are present.

- If _covariates_ are absent, the lower bound (theta_L) on the APR is defined by 

	theta_L = {Pr( _y_ = 1 | _z_ = 1 ) - Pr( _y_ = 1 | _z_ = 0 )}/{1 - Pr( _y_ = 1 | _z_ = 0 )}.

	The estimate and confidence interval are obtained by the following procedure:
	
	1. Pr( _y_ = 1 | _z_ = 1 ) and Pr( _y_ = 1 | _z_ = 0 ) are estimated by regressing _y_ on _z_.
	2. The lower bound on the APR is computed using the estimates obtained above.
	3. The standard error of the estimate is computed via STATA command {cmd:nlcom}.
	4. Then, a confidence interval for the APR is set by [ _est_ - _cv_ * _se_ , 1 ], 
	   where _est_ is the estimate, _se_ is the standard error, and
	   _cv_ is the one-sided standard normal critical value (e.g., _cv_ = 1.645 for {cmd:level}(95)).
	
- If _covariates_ are present, the lower bound (theta_L) on the APR is defined by 

	theta_L = E [ theta_L(x) ],
	
	where

	theta_L(x) = {Pr( _y_ = 1 | _z_ = 1, _x_ ) - Pr( _y_ = 1 | _z_ = 0, _x_ )}/{1 - Pr( _y_ = 1 | _z_ = 0, _x_ )}.
		
	The estimate and confidence interval are obtained by the following procedure.
	
	If {cmd:model}("no_interaction") is selected (default choice),
	
	1. Pr( _y_ = 1 | _z_ , _x_ ) is estimated by regressing _y_ on _z_ and _x_.
	
	Alternatively, if {cmd:model}("interaction") is selected,
	
	1a. Pr( _y_ = 1 | _z_ = 1, _x_ ) is estimated by regressing _y_ on _x_ given _z_ = 1.
	1b. Pr( _y_ = 1 | _z_ = 0, _x_ ) is estimated by regressing _y_ on _x_ given _z_ = 0.
	
	Ater step 1, both options are followed by:
	
	2. For each x in the estimation sample, theta_L(x) is computed using the estimates obtained above.
	3. The estimates of theta_L(x) are averaged to obtain the estimate of theta_L.
	4. A bootstrap confidence interval for the APR is set by [ bs_est(_alpha_) , 1 ],
	   where bs_est(_alpha_) is the _alpha_ quantile of the bootstrap estimates of theta_L
	   and 1 - _alpha_ is the confidence level.  
	
	The bootstrap procedure is implemented via STATA command {cmd:bootstrap}. 
		
Options
-------

{cmd:model}(_string_) specifies a regression model of _y_ on _z_ and _x_ when _covariates_ are present. 

The default option is "no_interaction" between _z_ and _x_. When "interaction" is selected, full interactions between _z_ and _x_ are allowed; this is accomplished by estimating Pr( _y_ = 1 | _z_ = 1, _x_ ) and Pr( _y_ = 1 | _z_ = 0, _x_ ), separately.

{cmd:level}(#) sets confidence level; default is {cmd:level}(95). 

{cmd:method}(_string_) refers the method for inference; default is {cmd:method}("normal").
By the naure of identification, one-sided confidence intervals are produced. 

	1. When _covariates_ are present, it needs to be set as {cmd:method}("bootstrap"); otherwise, the confidence interval will be missing.
	
	2. When _covariates_ are absent, both options "normal" and "bootstrap" yield non-missing confidence intervals.
	
{cmd:nboot}(#) chooses the number of bootstrap replications; default is {cmd:nboot}(50).
It is only relevant when {cmd:method}("bootstrap") is selected.

{cmd:title}(_string_) specifies the title of estimation.

Remarks
-------

It is recommended to use {cmd:nboot}(#) with # at least 1000. 
A default choice of 50 is meant to check the code initially 
because it may take a long time to run the bootstrap part when there are a large number of covariates.
The bootstrap confidence interval is based on percentile bootstrap.
A use of normality-based bootstrap confidence interval is not recommended 
because bootstrap standard errors can be unreasonably large in applications. 

Examples 
--------

We first call the dataset included in the package.

		. use GKB, clear

The first example conducts inference on the APR without covariates, using normal approximation.
		
		. persuasio4yz voteddem_all post, level(80) method("normal")
		
The second example conducts bootstrap inference on the APR.
		
		. persuasio4yz voteddem_all post, level(80) method("bootstrap") nboot(1000)	
		
The third example conducts bootstrap inference on the APR with a covariate, MZwave2, interacting with the instrument, post. 
		
		. persuasio4yz voteddem_all post MZwave2, level(80) model("interaction") method("bootstrap") nboot(1000)			
		

The fourh example consider a large number of covariates. This example runs slower than the previous example. 

		. persuasio4yz voteddem_all post doperator*, level(80) method("bootstrap") nboot(1000)

Stored results
--------------

### Matrices

> __e(lb_est)__: (1*2 matrix) bounds on the average persuasion rate in the form of [lb, 1]

> __e(lb_ci)__: (1*2 matrix) confidence interval for the average persuasion rate in the form of [lb_ci, 1] 


### Macros

> __e(cilevel)__: confidence level

> __e(inference_method)__: inference method: "normal" or "bootstrap" 

Authors
-------

Sung Jae Jun, Penn State University, <sjun@psu.edu> 

Sokbae Lee, Columbia University, <sl3841@columbia.edu>

License
-------

GPL-3

References
----------

Sung Jae Jun and Sokbae Lee (2019), 
Identifying the Effect of Persuasion, 
[arXiv:1812.02276 [econ.EM]](https://arxiv.org/abs/1812.02276) 

***/
capture program drop persuasio4yz
program persuasio4yz, eclass

	version 14.2
	
	syntax varlist (min=2) [if] [in] [, level(cilevel) model(string) method(string) nboot(numlist >0 integer) title(string)]
		
	aprlb `varlist' `if' `in', model("`model'")
	
	* displaying results
	if "`title'" != "" {
    
	display "`title':"
    
	}
		
	display "--- Estimating Average Persuation Rate (APR) ---"
	display "The estimated lower bound on the APR is:"	
    display e(lb_coef)	
	scalar lb_coef = e(lb_coef)
	
	* inference based on normal approximation
	if "`method'" == "" | "`method'" == "normal" { 
	
		if "`level'" != "" {	
		local alpha_level = `level'/100
		}
		if "`level'" == "" {	
		local alpha_level = 0.95
		}
		
		scalar cv_cns = invnormal(`alpha_level')   /* one-sided critical value */
		scalar lower_bound_ci = e(lb_coef) - cv_cns*e(lb_se)
		
		display "--- Inference Based on Normal Approximation ---"
		display "The standard error of the lower bound on the APR is:"
		display e(lb_se)
		
		display "The left-end point of the confidence interval for the lower bound on the APR is:"
		display lower_bound_ci
	    display "(Note. The one-sided nominal coverage probability is " `alpha_level' ")"  
        display "------------------------------------------------" 
	
	}
	
	* inference based on bootstrap
	if "`method'" == "bootstrap" { 
	
		if "`level'" != "" {	
		local alpha_level = `level'/100
		}
		if "`level'" == "" {	
		local alpha_level = 0.95
		}
		
		local cv_cns = invnormal(`alpha_level')   /* one-sided critical value */
		local bs_level = round(10000*(1-(1-`alpha_level')*2))/100 /* level for bootstrap */
		
		if "`nboot'" != "" {
			bootstrap coef=e(lb_coef), reps(`nboot') level(`bs_level') notable nowarn: aprlb `varlist' `if' `in', model("`model'") 
		}
		if "`nboot'" == "" {
			bootstrap coef=e(lb_coef), reps(50) level(`bs_level') notable nowarn: aprlb `varlist' `if' `in', model("`model'")
			
		}
			
		matrix bs_ci_percentile = e(ci_percentile)
		scalar lower_bound_ci = bs_ci_percentile[1,1] 

		display "--- Inference Based on Bootstrap ---"
		display "The left-end point of the percentile bootstrap confidence interval for the lower bound on the APR is:"
		display lower_bound_ci
	    display "(Note. the one-sided nominal coverage probability is: " `alpha_level' ")"  
        display "------------------------------------------------" 	
	}
	
	matrix lb_coef_matrix = (lb_coef,1)
	matrix lb_ci_matrix = (lower_bound_ci,1)
	
	ereturn clear
	ereturn matrix lb_est = lb_coef_matrix
	ereturn matrix lb_ci = lb_ci_matrix
	ereturn local cilevel = `alpha_level'*100
	ereturn local inference_method "`method'"
	
end
