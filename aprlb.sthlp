{smcl}

{p 4 4 2}
{it:version 0.1.0}


{title:aprlb}

{p 4 4 2}
Estimates the lower bound on the average persuasion rate


{title:Syntax }

{p 8 8 2} {bf:aprlb} {it:varlist} [{it:if}] [{it:in}] [, {it:title(string)}]

{p 4 4 2}{bf:Options}

{col 5}{it:option}{col 24}{it:Description}
{space 4}{hline 44}
{col 5}{it:title(string)}{col 24}Title of estimation
{space 4}{hline 44}


{title:Description}

{p 4 4 2}
Estimates the lower bound on the average persuation rate (APR). 

{p 4 4 2}
{it:varlist} should include {it:y} {it:z} {it:x} in order.

{p 4 4 2}
Here, {it:y} is binary outcomes, {it:z} is binary treatment and {it:x} is optional covariates. 

{p 4 4 2}
There are two cases: (i) {it:x} is absent and (ii) {it:x} is present.

{break}    - If {it:x} is absent, the lower bound (theta) on the APR is defined by 

{p 4 4 2}
	theta = {Pr( {it:y} = 1 | {it:z} = 1 ) - Pr( {it:y} = 1 | {it:z} = 0 )}/{1 - Pr( {it:y} = 1 | {it:z} = 0 )}.

{p 4 4 2}
	The estimate and its standard error are obtained by the following procedure:
	
{break}    	1. Pr( {it:y} = 1 | {it:z} = 1 ) and Pr( {it:y} = 1 | {it:z} = 0 ) are estimated by regressing {it:y} on {it:z}.
{break}    	2. The lower bound on the APR is computed using the estimates obtained above.
{break}    	3. The standard error of the estimate is computed via command {bf:nlcom}. 

{break}    - If {it:x} is present, the lower bound (theta) on the APR is defined by 

{p 4 4 2}
	theta(x) = {Pr( {it:y} = 1 | {it:z} = 1, {it:x} ) - Pr( {it:y} = 1 | {it:z} = 0, {it:x} )}/{1 - Pr( {it:y} = 1 | {it:z} = 0, {it:x} )},
	
{p 4 4 2}
	theta = E [ theta(x) ].
	
{p 4 4 2}
	The estimate is obtained by the following procedure:
	
{break}    	1. Pr( {it:y} = 1 | {it:z} = 1, {it:x} ) is estimated by regressing {it:y} on {it:x} given {it:z} = 1.
{break}    	2. Pr( {it:y} = 1 | {it:z} = 0, {it:x} ) is estimated by regressing {it:y} on {it:x} given {it:z} = 0.
{break}    	3. For each x in the estimation sample, theta(x) is computed using the estimates obtained above.
{break}    	4. The estimates of theta(x) are averaged to obtain the estimate of theta.
	
{p 4 4 2}
	In this case, the standard error is missing because an analytic formula for the standard error is complex. 
	
{p 4 4 2}
	Bootstrap inference will be implemented when command {bf:persuasionyz} is called to conduct inference. 
	

{title:Options}

{p 4 4 2}
{it:title(string)} specifies the title of estimation.


{title:Remarks}

{p 4 4 2}
It is recommended to use command {bf:persuasionyz} to estimate the effect of persuasion instead of calling {bf:aprlb} directly.


{title:Examples }

{p 4 4 2}
We first call the dataset included in the package.

{p 4 4 2}
		. use GKB, clear

{p 4 4 2}
The first example estimates the lower bound on the APR without covariates.
		
{p 4 4 2}
		. aprlb voteddem_all post

{p 4 4 2}
The second example adds covariates.

{p 4 4 2}
		. aprlb voteddem_all post doperator*


{title:Stored results }

{p 4 4 2}{bf:Scalars}

{p 8 8 2} {bf:e(lb_coef)}: estimate of the lower bound on the average persuasion rate

{p 8 8 2} {bf:e(lb_se)}: standard error of the lower bound on the average persuasion rate


{p 4 4 2}{bf:Matrices}

{p 8 8 2} {bf:e(outcomes)}: variable name of the binary outcome variable

{p 8 8 2} {bf:e(instrument)}: variable name of the binary instrumental variable 

{p 8 8 2} {bf:e(covariates)}: variable name(s) of the covariates if they exist



{title:Authors }

{p 4 4 2}
Sung Jae Jun, Penn State University, <sjun@psu.edu> 

{p 4 4 2}
Sokbae Lee, Columbia University, <sl3841@columbia.edu>


{title:License }

{p 4 4 2}
GPL-3


{title:References }

{p 4 4 2}
Sung Jae Jun and Sokbae Lee (2019), Identifying the Effect of Persuasion, 
{browse "https://arxiv.org/abs/1812.02276":arXiv:1812.02276 [econ.EM]} 



