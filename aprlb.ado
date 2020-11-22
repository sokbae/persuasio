/***

_version 0.1.0_ 

aprlb
======

Estimates the lower bound on the average persuasion rate

Syntax 
------

> __aprlb__ _varlist_ [_if_] [_in_] [, _title(string)_]

### Options

| _option_          | _Description_           | 
|-------------------|-------------------------|
| _title(string)_   | Title of estimation     |


Description
-----------

Estimates the lower bound on the average persuation rate (APR). 

_varlist_ should include _y_ _z_ _x_ in order.

Here, _y_ is binary outcomes, _z_ is binary treatment and _x_ is optional covariates. 

There are two cases: (i) _x_ is absent and (ii) _x_ is present.

- If _x_ is absent, the lower bound (theta) on the APR is defined by 

	theta = {Pr( _y_ = 1 | _z_ = 1 ) - Pr( _y_ = 1 | _z_ = 0 )}/{1 - Pr( _y_ = 1 | _z_ = 0 )}.

	The estimate and its standard error are obtained by the following procedure:
	
	1. Pr( _y_ = 1 | _z_ = 1 ) and Pr( _y_ = 1 | _z_ = 0 ) are estimated by regressing _y_ on _z_.
	2. The lower bound on the APR is computed using the estimates obtained above.
	3. The standard error of the estimate is computed via command __nlcom__. 

- If _x_ is present, the lower bound (theta) on the APR is defined by 

	theta(x) = {Pr( _y_ = 1 | _z_ = 1, _x_ ) - Pr( _y_ = 1 | _z_ = 0, _x_ )}/{1 - Pr( _y_ = 1 | _z_ = 0, _x_ )},
	
	theta = E [ theta(x) ].
	
	The estimate is obtained by the following procedure:
	
	1. Pr( _y_ = 1 | _z_ = 1, _x_ ) is estimated by regressing _y_ on _x_ given _z_ = 1.
	2. Pr( _y_ = 1 | _z_ = 0, _x_ ) is estimated by regressing _y_ on _x_ given _z_ = 0.
	3. For each x in the estimation sample, theta(x) is computed using the estimates obtained above.
	4. The estimates of theta(x) are averaged to obtain the estimate of theta.
	
	In this case, the standard error is missing because an analytic formula for the standard error is complex. 
	
	Bootstrap inference will be implemented when command __persuasionyz__ is called to conduct inference. 
	
Options
-------

_title(string)_ specifies the title of estimation.

Remarks
-------

It is recommended to use command __persuasionyz__ instead of calling __aprlb__ directly.

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


### Matrices

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

Sung Jae Jun and Sokbae Lee (2019), Identifying the Effect of Persuasion, 
[arXiv:1812.02276 [econ.EM]](https://arxiv.org/abs/1812.02276) 

***/
*! version 0.1.0 Simon Lee 22Nov2020
program aprlb, eclass

	version 14.2
	
	syntax varlist [if] [in] [, title(string)]
	
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
	
	tempvar yhat1 yhat0 thetahat_num thetahat_den thetahat
		
	quietly reg `Y' `X' if `Z'==1 & `touse', robust
	quietly predict `yhat1' if `touse'
	
	quietly reg `Y' `X' if `Z'==0 & `touse', robust
	quietly predict `yhat0' if `touse'
	
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
