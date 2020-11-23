/***

_version 0.1.0_ 

Title
-----

{phang}{cmd:aprlb} {hline 2} Estimates the lower bound on the average persuasion rate

Syntax
------

> {cmd:aprlb} _depvar_ _instrvar_ [_covariates_] [_if_] [_in_] [, {cmd:model}(_string_) {cmd:title}(_string_)]

### Options

| _option_          | _Description_           | 
|-------------------|-------------------------|
| {cmd:model}(_string_)   | Regression model when _covariates_ are present; default is "no_interaction" |
| {cmd:title}(_string_)   | Title of estimation     |


Description
-----------

__aprlb__ estimates the lower bound on the average persuation rate (APR).
_varlist_ should include _depvar_ _instrvar_ _covariates_ in order.
Here, _depvar_ is binary outcomes (_y_), _instrvar_ is binary instruments (_z_), 
and _covariates_ (_x_) are optional. 

There are two cases: (i) _covariates_ are absent and (ii) _covariates_ are present.

- If _covariates_ are absent, the lower bound (theta_L) on the APR is defined by 

	theta_L = {Pr( _y_ = 1 | _z_ = 1 ) - Pr( _y_ = 1 | _z_ = 0 )}/{1 - Pr( _y_ = 1 | _z_ = 0 )}.

	The estimate and its standard error are obtained by the following procedure:
	
	1. Pr( _y_ = 1 | _z_ = 1 ) and Pr( _y_ = 1 | _z_ = 0 ) are estimated by regressing _y_ on _z_.
	2. The lower bound on the APR is computed using the estimates obtained above.
	3. The standard error of the estimate is computed via STATA command __nlcom__. 

- If _covariates_ are present, the lower bound (theta_L) on the APR is defined by 

	theta_L = E [ theta_L(x) ],
	
	where

	theta_L(x) = {Pr( _y_ = 1 | _z_ = 1, _x_ ) - Pr( _y_ = 1 | _z_ = 0, _x_ )}/{1 - Pr( _y_ = 1 | _z_ = 0, _x_ )}.
	
	The estimate is obtained by the following procedure.
	
	If {cmd:model}("no_interaction") is selected (default choice),
	
	1. Pr( _y_ = 1 | _z_ , _x_ ) is estimated by regressing _y_ on _z_ and _x_.
	
	Alternatively, if {cmd:model}("interaction") is selected,
	
	1a. Pr( _y_ = 1 | _z_ = 1, _x_ ) is estimated by regressing _y_ on _x_ given _z_ = 1.
	1b. Pr( _y_ = 1 | _z_ = 0, _x_ ) is estimated by regressing _y_ on _x_ given _z_ = 0.
	
	Ater step 1, both options are followed by:
	
	2. For each x in the estimation sample, theta_L(x) is computed using the estimates obtained above.
	3. The estimates of theta_L(x) are averaged to obtain the estimate of theta_L.
	
	When _covariates_ are present, the standard error is missing because an analytic formula for the standard error is complex.
	Bootstrap inference is implemented when this package's command __persuasio__ is called to conduct inference. 
	
Options
-------

{cmd:model}(_string_) specifies a regression model of _y_ on _z_ and _x_ when _covariates_ are present. 

The default option is "no_interaction" between _z_ and _x_. When "interaction" is selected, full interactions between _z_ and _x_ are allowed; this is accomplished by estimating Pr( _y_ = 1 | _z_ = 1, _x_ ) and Pr( _y_ = 1 | _z_ = 0, _x_ ), separately.

{cmd:title}(_string_) specifies the title of estimation.

Remarks
-------

It is recommended to use this package's command __persuasio__ instead of calling __aprlb__ directly.

Examples 
--------

We first call the dataset included in the package.

		. use GKB, clear

The first example estimates the lower bound on the APR without covariates.
		
		. aprlb voteddem_all post

The second example adds covariates.

		. aprlb voteddem_all post doperator*

Stored results
--------------

### Scalars

> __e(lb_coef)__: estimate of the lower bound on the average persuasion rate

> __e(lb_se)__: standard error of the lower bound on the average persuasion rate


### Macros

> __e(outcomes)__: variable name of the binary outcome variable

> __e(instrument)__: variable name of the binary instrumental variable 

> __e(covariates)__: variable name(s) of the covariates if they exist


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
capture program drop aprlb
program aprlb, eclass

	version 14.2
	
	syntax varlist (min=2) [if] [in] [, model(string) title(string)]
	
	marksample touse
	
	gettoken Y varlist_without_Y : varlist
	gettoken Z X : varlist_without_Y

	* if there are no covariates (X) 
	if "`X'" == "" { 
	
	quietly reg `Y' `Z' if `touse', robust	
	
	quietly nlcom _b[`Z']/(1-_b[_cons])	 

	matrix lower_bound_est = r(b)
	matrix lower_bound_avar = r(V)
	scalar lower_bound_coef = lower_bound_est[1,1]
	scalar lower_bound_se = sqrt(lower_bound_avar[1,1])
		
	}
	
	* if there are covariates (X)
	if "`X'" != "" {
	
	tempvar yhat yhat1 yhat0 thetahat_num thetahat_den thetahat
	
		if "`model'" == "" | "`model'" == "no_interaction" { 
	
		quietly reg `Y' `Z' `X' if `touse', robust
		
		tempname bhat b_coef
		
		matrix `bhat' = e(b)
		scalar `b_coef' = `bhat'[1,1]
		
		quietly predict `yhat' if `touse'
		
		gen `yhat1' = `yhat' + `b_coef' - `b_coef'*`Z'
		gen `yhat0' = `yhat' - `b_coef'*`Z'
	
		}
		
		if "`model'" == "interaction" { 
	
		quietly reg `Y' `X' if `Z'==1 & `touse', robust
		quietly predict `yhat1' if `touse'
	
		quietly reg `Y' `X' if `Z'==0 & `touse', robust
		quietly predict `yhat0' if `touse'
		}
		
	quietly replace `yhat1' = min(max(`yhat1',0),1)
	quietly replace `yhat0' = min(max(`yhat0',0),1)

	gen `thetahat_num' = `yhat1' - `yhat0'
	gen `thetahat_den' = 1 - `yhat0'
	quietly replace `thetahat_den' = max(`thetahat_den', 1e-8)
	gen `thetahat' = `thetahat_num'/`thetahat_den'
    
	quietly sum `thetahat' if `touse'
	scalar lower_bound_coef = r(mean)
	scalar lower_bound_se = .
	
	}
	
	ereturn clear
	ereturn scalar lb_coef = lower_bound_coef
	ereturn scalar lb_se = lower_bound_se
	ereturn local outcomes `Y'
	ereturn local instrument `Z'
	ereturn local covariates `X'

end
