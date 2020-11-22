*! version 0.1.0 Simon Lee 22Nov2020
program persuasionyz, eclass

	version 14.2
	
	syntax varlist (min=2) [if] [in],  ///
			[level(cilevel) method(string) nboot(numlist >0 integer) title(string)]
		
	aprlb `varlist'
	
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
			bootstrap coef=e(lb_coef), reps(`nboot') level(`bs_level') notable nowarn: aprlb `varlist'
		}
		if "`nboot'" == "" {
			bootstrap coef=e(lb_coef), reps(100) level(`bs_level') notable nowarn: aprlb `varlist'
			
		}
			
		matrix bs_ci_bc = e(ci_bc)
		scalar lower_bound_ci_bc = bs_ci_bc[1,1] 
		
		matrix bs_ci_percentile = e(ci_percentile)
		scalar lower_bound_ci = bs_ci_percentile[1,1] 

		display "--- Inference Based on Bootstrap ---"
		display "The left-end point of the percentile bootstrap confidence interval for the lower bound on the APR is:"
		display lower_bound_ci
		display "The left-end point of bc bootstrap confidence interval for the lower bound on the APR is:"
		display lower_bound_ci_bc
	    display "(Note. the one-sided nominal coverage probability is: " `alpha_level' ")"  
        display "------------------------------------------------" 	
	}
	
	matrix lb_coef_matrix = (lb_coef,1)
	matrix lb_ci_matrix = (lower_bound_ci,1)
	
	ereturn clear
	ereturn matrix lb_coef = lb_coef_matrix
	ereturn matrix lb_ci = lb_ci_matrix
	ereturn local cilevel = `alpha_level'*100
	ereturn local inference_method "`method'"
	
end

