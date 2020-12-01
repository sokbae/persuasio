/***

_version 0.1.0_ 

[To be updated]

Title
-----

{phang}{cmd:lpr4ytz} {hline 2} Estimates the upper bound on the average persuasion rate

Syntax
------

> {cmd:lpr4ytz} _depvar_ _treatrvar_ _instrvar_ [_covariates_] [_if_] [_in_] [, {cmd:model}(_string_) {cmd:title}(_string_)]

### Options

| _option_          | _Description_           | 
|-------------------|-------------------------|
| {cmd:model}(_string_)   | Regression model when _covariates_ are present |
| {cmd:title}(_string_)   | Title of estimation     |


Description
-----------

__lpr4ytz__ estimates the upper bound on the average persuation rate (APR).
_varlist_ should include _depvar_ _treatrvar_ _instrvar_ _covariates_ in order.
Here, _depvar_ is binary outcome (_y_), _treatrvar_ is binary treatment (_t_), 
_instrvar_ is binary instrument (_z_), and _covariates_ (_x_) are optional. 

There are two cases: (i) _covariates_ are absent and (ii) _covariates_ are present.

- If _x_ are absent, the upper bound ({cmd:theta_U}) on the APR is defined by 

	{cmd:theta_U} = {E[{it:A}|{it:z}=1] - E[{it:B}|{it:z}=0]}/{1 - E[{it:B}|{it:z}=0]},

	where {it:A} = 1({it:y}=1,{it:t}=1)+1-1({it:t}=1) and 
		  {it:B} = 1({it:y}=1,{it:t}=0).
	
	The estimate and its standard error are obtained by the following procedure:
	
1. E[{it:A}|{it:z}=1] is estimated by regressing {it:A} on _z_.
2. E[{it:B}|{it:z}=0] is estimated by regressing {it:B} on _z_.
3. {cmd:theta_U} is computed using the estimates obtained above.
4. The standard error is computed via STATA command __nlcom__. 

- If _x_ are present, the upper bound ({cmd:theta_U}) on the APR is defined by 

	{cmd:theta_U} = E[{cmd:theta_U}({it:x})],
	
	where

	{cmd:theta_U}({it:x}) = {E[{it:A}|{it:z}=1,{it:x}] - E[{it:B}|{it:z}=0,{it:x}]}/{1 - E[{it:B}|{it:z}=0,{it:x}]}.
	
The estimate is obtained by the following procedure.
	
If {cmd:model}("no_interaction") is selected (default choice),
	
1. E[{it:A}|{it:z}=1,{it:x}] is estimated by regressing {it:A} on _z_ and _x_.
2. E[{it:B}|{it:z}=0,{it:x}] is estimated by regressing {it:B} on _z_ and _x_.
	
Alternatively, if {cmd:model}("interaction") is selected,
	
1. E[{it:A}|{it:z}=1,{it:x}] is estimated by regressing {it:A} on _x_ given _z_ = 1.
2. E[{it:B}|{it:z}=0,{it:x}] is estimated by regressing {it:B} on _x_ given _z_ = 0.
	
Ater step 1, both options are followed by:
	
3. For each _x_ in the estimation sample, {cmd:theta_U}({it:x}) is evaluated.
4. The estimates of {cmd:theta_U}({it:x}) are averaged to estimate {cmd:theta_U}.
	
	When _covariates_ are present, the standard error is missing because an analytic formula for the standard error is complex.
	Bootstrap inference is implemented when this package's command __persuasio__ is called to conduct inference. 
	
Options
-------

{cmd:model}(_string_) specifies a regression model.

This option is only releveant when _x_ is present.
The dependent variable is 
either {it:A} or {it:B}. 
The default option is "no_interaction" between _z_ and _x_. 
When "interaction" is selected, full interactions between _z_ and _x_ are allowed.

{cmd:title}(_string_) specifies the title of estimation.

Remarks
-------

It is recommended to use this package's command __persuasio__ instead of calling __lpr4ytz__ directly.

Examples 
--------

We first call the dataset included in the package.

		. use GKB, clear

The first example estimates the upper bound on the APR without covariates.
		
		. lpr4ytz voteddem_all post

The second example adds a covariate.

		. lpr4ytz voteddem_all post MZwave2

Stored results
--------------

### Scalars

> __e(N)__: sample size

> __e(ub_coef)__: estimate of the upper bound on the average persuasion rate

> __e(ub_se)__: standard error of the upper bound on the average persuasion rate


### Macros

> __e(outcome)__: variable name of the binary outcome variable

> __e(treatment)__: variable name of the binary treatment variable 

> __e(instrument)__: variable name of the binary instrumental variable 

> __e(covariates)__: variable name(s) of the covariates if they exist

> __e(model)__: regression model specification ("no_interaction" or "interaction")

### Functions:

> __e(sample)__: 1 if the observations are used for estimation, and 0 otherwise. 


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
capture program drop lpr4ytz
program lpr4ytz, eclass

	version 14.2
	
	syntax varlist (min=3) [if] [in] [, model(string) title(string)]
	
	marksample touse
	
	gettoken Y varlist_without_Y : varlist
	gettoken T varlist_without_YT : varlist_without_Y
	gettoken Z X : varlist_without_YT
	
	quietly levelsof `Y'
	if "`r(levels)'" != "0 1" {
	
	display "`Y' is not a 0/1 variable"
	error 450	
	}
	
	quietly levelsof `T'
	if "`r(levels)'" != "0 1" {
	
	display "`T' is not a 0/1 variable"
	error 450
	}
	
	quietly levelsof `Z'
	if "`r(levels)'" != "0 1" {
	
	display "`Z' is not a 0/1 variable"
	error 450
	}
	
	display " "
	display as text "{hline 65}"
	display "{bf:lpr4ytz:} Estimating the Local Persuasion Rate"
	display as text "{hline 65}"
	display " "
	display " - Binary outcome: `Y'"
	display " - Binary treatment: `T'"
	display " - Binary instrument: `Z'"
	display " - Covariates (if exist): `X'"
    display " "
	
	
	* generate variables used in estimating the LPR

	tempvar case_id den_lpr
	gen  `case_id' = _n            /* generate temporary Case ID */
	gen `den_lpr' = (1-`Y')*(1-`T')
	
	* if there are no covariates (X) or no interaction terms between Z and X
	if "`X'" == "" | "`model'" == "" | "`model'" == "no_interaction" { 
		
	quietly {
		reg `Y' `Z' `X' if `touse'
		local nobs = e(N)
		est store num_reg
		reg `den_lpr' `Z' `X' if `touse'
		est store den_reg
		suest num_reg den_reg, vce(cluster `case_id') 

		* estimate of the local persuation rate  
		
		nlcom (local_persuasion_rate: ([num_reg_mean]`Z')/(-[den_reg_mean]`Z'))
		}
				
    tempname b V lpr se
	
	matrix `b' = r(b)
	matrix `V' = r(V)	
	scalar `lpr' = `b'[1,1]
	scalar `se' = sqrt(`V'[1,1])
	
	ereturn post `b' `V', obs(`nobs') esample(`touse')
	ereturn display, nopv	
	
	display " "
	display "Note: It is recommended to use {bf:persuasio} for causal inference."
    display " "
	
	ereturn scalar lpr_coef = `lpr'
    ereturn scalar lpr_se = `se'
    ereturn local outcome `Y'
	ereturn local treatment `T'
    ereturn local instrument `Z'
	ereturn local covariates `X'
	ereturn local model `model'
		
	}
	
	* if there are interaction terms between Z and X
	if "`X'" != "" & "`model'" == "interaction" { 
	
	tempvar `Y'_1 `Y'_0 `T'_1 `T'_0 `den_lpr'_1 `den_lpr'_0
	
	quietly {
		foreach var in `Y' `T' `den_lpr' { 
			foreach value in 0 1 {
				reg `var' `X' if `Z'==`value' & `touse'
				predict ``var'_`value'' if `touse'
				replace ``var'_`value'' = min(max(``var'_`value'',0),1)
				}
			}	
		}
	
	tempvar thetahat_wgt thetahat_num thetahat_den thetahat_lpr thetahat
	
	gen `thetahat_wgt' = ``T'_1' - ``T'_0'
	gen `thetahat_num' = ``Y'_1' - ``Y'_0'
	gen `thetahat_den' = ``den_lpr'_0' - ``den_lpr'_1'
	quietly replace `thetahat_den' = max(`thetahat_den', 1e-8)
	gen `thetahat_lpr' = `thetahat_num'/`thetahat_den'
	gen `thetahat' = `thetahat_lpr'*`thetahat_wgt'
    
	tempname lpr_num lpr_den
	
	quietly sum `thetahat' if `touse'
	scalar `lpr_num' = r(mean)
	local nobs = r(N)
	
	quietly sum `thetahat_wgt' if `touse'
	scalar `lpr_den' = r(mean)
		
	tempname lpr b se
	
	scalar `lpr' = `lpr_num'/`lpr_den'
	scalar `se' = .
		
	matrix `b' = `lpr'
	matrix colnames `b' = local_persuasion_rate
	
    ereturn post `b', obs(`nobs') esample(`touse')
	ereturn display, nopv	
	
	display " "
	display "Notes: It is recommended to use {bf:persuasio} for causal inference."
	display "      Standard errors are missing if model-interaction option is selected."
    display " "
	
	ereturn scalar lpr_coef = `lpr'
    ereturn scalar lpr_se = `se'
    ereturn local outcome `Y'
	ereturn local treatment `T'
    ereturn local instrument `Z'
	ereturn local covariates `X'
	ereturn local model `model'
	
	}
	
	display "Reference: Jun and Lee (2019), arXiv:1812.02276 [econ.EM]"

end
