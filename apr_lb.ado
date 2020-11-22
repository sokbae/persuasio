*! version 0.1.0 Simon Lee 22Nov2020
program apr_lb, eclass

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
	
	tempvar yhat yhat1 yhat0 thetahat_num thetahat_den thetahat
	
	quietly reg `Y' `Z' `X' if `touse', robust
	matrix reg_b = e(b)
	quietly predict `yhat' if `touse'
	
	scalar coeff_b = reg_b[1,1]
	
	gen `yhat1' = `yhat' + coeff_b - coeff_b*`Z'
	gen `yhat0' = `yhat' - coeff_b*`Z'

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
