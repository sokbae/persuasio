/***

_version 0.1.0_ 

[To be updated]

Title
-----

{phang}{cmd:persuasio4ytz2lpr} {hline 2} Conducts causal inference on persuasive effects 
for binary outcome _y_, binary treament _t_ and binary instrument _z_

Syntax
------

> {cmd:persuasio4ytz2lpr} _depvar_ _treatvar_ _instrvar_ [_covariates_] [_if_] [_in_] [, {cmd:level}(#) {cmd:model}(_string_) {cmd:method}(_string_) {cmd:nboot}(#) {cmd:title}(_string_)]

### Options

| _option_          | _Description_           | 
|-------------------|-------------------------|
| {cmd:level}(#) | Set confidence level; default is {cmd:level}(95) |
| {cmd:model}(_string_)   | Regression model when _covariates_ are present |
| {cmd:method}(_string_) | Inference method; default is {cmd:method}("normal")    |
| {cmd:nboot}(#) | Perform # bootstrap replications |
| {cmd:title}(_string_) | Title of estimation     |

Description
-----------

{cmd:persuasio4ytz2lpr} conducts causal inference on persuasive effects.

It is assumed that binary outcome _y_, binary treatment _t_, and binary instrument _z_ are observed. 
This command is for the case when persuasive treatment (_t_) is observed, 
using estimates of the lower and upper bounds on the average persuation rate (APR) via 
this package's commands {cmd:aprlb} and {cmd:aprub}.

_varlist_ should include _depvar_ _treatvar_ _instrvar_ _covariates_ in order. 
Here, _depvar_ is binary outcome (_y_), _treatvar_ is binary treatment,
_instrvar_ is binary instrument (_z_), and _covariates_ (_x_) are optional. 

There are two cases: (i) _covariates_ are absent and (ii) _covariates_ are present.

- If _x_ are absent, the lower bound ({cmd:theta_L}) on the APR is defined by 

	{cmd:theta_L} = {Pr({it:y}=1|{it:z}=1) - Pr({it:y}=1|{it:z}=0)}/{1 - Pr({it:y}=1|{it:z}=0)},
	
	and the upper bound ({cmd:theta_U}) on the APR is defined by 

	{cmd:theta_U} = {E[{it:A}|{it:z}=1] - E[{it:B}|{it:z}=0]}/{1 - E[{it:B}|{it:z}=0]},

	where {it:A} = 1({it:y}=1,{it:t}=1)+1-1({it:t}=1) and 
		  {it:B} = 1({it:y}=1,{it:t}=0).	

	The lower bound is estimated by the following procedure:
	
1. Pr({it:y}=1|{it:z}=1) and Pr({it:y}=1|{it:z}=0)) are estimated by regressing _y_ on _z_.
2. {cmd:theta_L} is computed using the estimates obtained above.
3. The standard error is computed via STATA command __nlcom__. 

	The upper boound is stimated by the following procedure:
	
1. E[{it:A}|{it:z}=1] is estimated by regressing {it:A} on _z_.
2. E[{it:B}|{it:z}=0] is estimated by regressing {it:B} on _z_.
3. {cmd:theta_U} is computed using the estimates obtained above.
4. The standard error is computed via STATA command __nlcom__. 

	Then, a confidence interval for the APR is set by 

{p 8 8 2}		[ _est_lb_ - _cv_ * _se_lb_ , _est_ub_ + _cv_ * _se_ub_ ],
	
where _est_lb_ and _est_ub_ are the estimates of the lower and upper bounds, 
_se_lb_ and _se_ub_ are the corresponding standard errors, and 
_cv_ is the critical value obtained via the method of Stoye (2009).
	
- If _x_ are present, the lower bound ({cmd:theta_L}) on the APR is defined by 

	{cmd:theta_L} = E[{cmd:theta_L}(x)],
	
	where

	{cmd:theta_L}(x) = {Pr({it:y}=1|{it:z}=1,{it:x}) - Pr({it:y}=1|{it:z}=0,{it:x})}/{1 - Pr({it:y}=1|{it:z}=0,{it:x})},
	
  and the upper bound ({cmd:theta_U}) on the APR is defined by 

	{cmd:theta_U} = E[{cmd:theta_U}({it:x})],
	
	where

	{cmd:theta_U}({it:x}) = {E[{it:A}|{it:z}=1,{it:x}] - E[{it:B}|{it:z}=0,{it:x}]}/{1 - E[{it:B}|{it:z}=0,{it:x}]}.
			
The lower bound is estimated by the following procedure:
	
If {cmd:model}("no_interaction") is selected (default choice),
	
1. Pr({it:y}=1|{it:z},{it:x}) is estimated by regressing _y_ on _z_ and _x_.
	
Alternatively, if {cmd:model}("interaction") is selected,
	
1a. Pr({it:y}=1|{it:z}=1,{it:x}) is estimated by regressing _y_ on _x_ given _z_ = 1.
1b. Pr({it:y}=1|{it:z}=0,{it:x}) is estimated by regressing _y_ on _x_ given _z_ = 0.
	
Ater step 1, both options are followed by:
	
2. For each x in the estimation sample, {cmd:theta_L}(x) is evaluated.
3. The estimates of {cmd:theta_L}(x) are averaged to estimate {cmd:theta_L}.

The upper boound is stimated by the following procedure:
	
If {cmd:model}("no_interaction") is selected (default choice),
	
1. E[{it:A}|{it:z}=1,{it:x}] is estimated by regressing {it:A} on _z_ and _x_.
2. E[{it:B}|{it:z}=0,{it:x}] is estimated by regressing {it:B} on _z_ and _x_.
	
Alternatively, if {cmd:model}("interaction") is selected,
	
1. E[{it:A}|{it:z}=1,{it:x}] is estimated by regressing {it:A} on _x_ given _z_ = 1.
2. E[{it:B}|{it:z}=0,{it:x}] is estimated by regressing {it:B} on _x_ given _z_ = 0.
	
Ater step 1, both options are followed by:
	
3. For each _x_ in the estimation sample, {cmd:theta_U}({it:x}) is evaluated.
4. The estimates of {cmd:theta_U}({it:x}) are averaged to estimate {cmd:theta_U}.

Then, a bootstrap confidence interval for the APR is set by 

{p 8 8 2}		[ bs_est_lb(_alpha_) , bs_est_ub(_alpha_) ],
		
where bs_est_lb(_alpha_) is the _alpha_ quantile of the bootstrap estimates of {cmd:theta_L},
	  bs_est_ub(_alpha_) is the 1 - _alpha_ quantile of the bootstrap estimates of {cmd:theta_U},
and 1 - _alpha_ is the confidence level. 

The resulting coverage probability is 1 - _alpha_ if the identified interval never reduces to a singleton set.
More generally, it will be 1 - 2*{it:alpha} by Bonferroni correction.   
	
The bootstrap procedure is implemented via STATA command {cmd:bootstrap}. 
		
Options
-------

{cmd:model}(_string_) specifies a regression model of _y_ on _z_ and _x_. 

This option is only releveant when _x_ is present.
The default option is "no_interaction" between _z_ and _x_. 
When "interaction" is selected, full interactions between _z_ and _x_ are allowed.

{cmd:level}(#) sets confidence level; default is {cmd:level}(95). 

{cmd:method}(_string_) refers the method for inference.

The default option is {cmd:method}("normal").
By the naure of identification, one-sided confidence intervals are produced. 

{p 4 8 2}1. When _x_ are present, it needs to be set as {cmd:method}("bootstrap"); 
otherwise, the confidence interval will be missing.
	
{p 4 8 2}2. When _x_ are absent, both options yield non-missing confidence intervals.
	
{cmd:nboot}(#) chooses the number of bootstrap replications.

The default option is {cmd:nboot}(50).
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
		
		. persuasio4ytz2lpr voteddem_all readsome post, level(80) method("normal")
		
The second example conducts bootstrap inference on the APR.
		
		. persuasio4ytz2lpr voteddem_all readsome post, level(80) method("bootstrap") nboot(1000)	
		
The third example conducts bootstrap inference on the APR with a covariate, MZwave2, interacting with the instrument, post. 
		
		. persuasio4ytz2lpr voteddem_all readsome post MZwave2, level(80) model("interaction") method("bootstrap") nboot(1000)			
		
Stored results
--------------

### Matrices

> __e(lb_est)__: (1*2 matrix) bounds on the average persuasion rate in the form of [lb, ub]

> __e(lb_ci)__: (1*2 matrix) confidence interval for the average persuasion rate in the form of [lb_ci, ub_ci] 


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
capture program drop persuasio4ytz2lpr
program persuasio4ytz2lpr, eclass

	version 14.2
	
	syntax varlist (min=3) [if] [in] [, level(cilevel) model(string) method(string) nboot(numlist >0 integer) title(string)]
			
	marksample touse
	
	gettoken Y varlist_without_Y : varlist
	gettoken T varlist_without_YT : varlist_without_Y
	gettoken Z X : varlist_without_YT
		
	quietly lpr4ytz `Y' `T' `Z' `X' `if' `in', model("`model'")
		
	tempname lpr_coef lpr_se
	scalar `lpr_coef' = e(lpr_coef)
	scalar `lpr_se' = e(lpr_se)
		
	* displaying results
	if "`title'" != "" {
    
	display "`title':"
    
	}
		
	* inference based on normal approximation
	if "`method'" == "" | "`method'" == "normal" { 
	
		if "`level'" != "" {	
		local alpha_level = 1 - `level'/100
		}
		if "`level'" == "" {	
		local alpha_level = 0.05
		}
		
		tempname cv_cns lb_end ub_end
		scalar `cv_cns' = invnormal(1-`alpha_level'/2) /* two-sided critical value */
		scalar `lb_end' = max(0,`lpr_coef' - `cv_cns'*`lpr_se')
		scalar `ub_end' = min(1,`lpr_coef' + `cv_cns'*`lpr_se')
		
		*scalar `lb_end' = `lpr_coef' - `cv_cns'*`lpr_se'
		*scalar `ub_end' = `lpr_coef' + `cv_cns'*`lpr_se'
				
		* Displaying results
	    display " "
		display as text "{hline 65}"
		display "{bf:persuasio4ytz2lpr:} Causal inference on the local Persuasion rate"
		display " when outcome, instrument and instrument are observed"
		display as text "{hline 65}"
		display " "
		if "`title'" != "" {
		display "Title: `title'"
		}
		display " - Binary outcome: `e(outcome)'"
		display " - Binary treatment: `e(treatment)'"
		display " - Binary instrument: `e(instrument)'"
		display " - Covariates (if exist): `e(covariates)'"
		display " - Regression model (if specified): `e(model)'"
		display " "
		display as text "{hline 25}{c TT}{hline 40}"

		display as text %24s  "Parameter" " {c |}" /*
		*/ _col(28) "Estimate" /*
		*/ _col(48) "`level'% Conf. Interval" 
        display as text "{hline 25}{c +}{hline 40}"
	    
		display as text %24s "Local Persuasion Rate" " {c |}" /*
		*/ as result /*
		*/ _col(27) %8.0g `lpr_coef' " " /*
		*/ _col(47) %8.0g `lb_end' " "  /*
		*/ _col(53) %8.0g `ub_end' " "
		
		display as text "{hline 25}{c BT}{hline 40}"

		display " "
		display "Note: `level'% conf. interval is based on normal approximation."
		display "   Conf. interval is missing (given as [0,1])  if interactions are"
		display "   allowed between x and z. Use option bootstrap for that case."
		display " "
	
	}
	
	* inference based on bootstrap
	if "`method'" == "bootstrap" { 
	
	    * Displaying results
	    display " "
		display as text "{hline 65}"
		display "{bf:persuasio4ytz2lpr:} Causal inference on the local persuasion rate"
		display " when outcome, instrument and instrument are observed"
		display as text "{hline 65}"
		display " "
		if "`title'" != "" {
		display "Title: `title'"
		}
		display " - Binary outcome: `e(outcome)'"
		display " - Binary treatment: `e(treatment)'"
		display " - Binary instrument: `e(instrument)'"
		display " - Covariates (if exist): `e(covariates)'"
		display " - Regression model (if specified): `e(model)'"
		display " "
	
		if "`level'" != "" {	
		local alpha_level = 1 - `level'/100
		}
		if "`level'" == "" {	
		local alpha_level = 0.05
		}

		local bs_level = round(10000*(1 - `alpha_level'))/100 /* level for bootstrap */
		
		* lower bound
		
		if "`nboot'" != "" {
			bootstrap coef=e(lpr_coef), reps(`nboot') level(`bs_level') notable nowarn: lpr4ytz `Y' `T' `Z' `X' `if' `in', model("`model'")
		}
		if "`nboot'" == "" {
			bootstrap coef=e(lpr_coef), reps(50) level(`bs_level') notable nowarn: lpr4ytz `Y' `T' `Z' `X' `if' `in', model("`model'")
			
		}
		
		tempname bs_ci_percentile lb_end ub_end
		matrix `bs_ci_percentile' = e(ci_percentile)
		scalar `lb_end' = max(0,`bs_ci_percentile'[1,1]) 
		scalar `ub_end' = min(1,`bs_ci_percentile'[2,1]) 
		
		* Displaying results further
		display " "
		display as text "{hline 25}{c TT}{hline 40}"

		display as text %24s  "Parameter" " {c |}" /*
		*/ _col(28) "Estimate" /*
		*/ _col(48) "`level'% Conf. Interval" 
        display as text "{hline 25}{c +}{hline 40}"
	    
		display as text %24s "Local Persuasion Rate" " {c |}" /*
		*/ as result /*
		*/ _col(27) %8.0g `lpr_coef' " " /*
		*/ _col(47) %8.0g `lb_end' " " /*
		*/ _col(53) %8.0g `ub_end' " "
		
		display as text "{hline 25}{c BT}{hline 40}"

		display " "
		display "Note: `level'% conf. interval is based on percentile bootstrap."
		display " "
	
	}
	
	tempname coef_matrix ci_matrix
	
	matrix `coef_matrix' = (`lpr_coef')
	matrix `ci_matrix' = (`lb_end',`ub_end')
	
	ereturn clear
	ereturn matrix lpr_est = `coef_matrix'
	ereturn matrix lpr_ci = `ci_matrix'
	ereturn local cilevel = (1-`alpha_level')*100
	ereturn local inference_method "`method'"
	
	display "Reference: Jun and Lee (2019), arXiv:1812.02276 [econ.EM]"
	
end

