clear
cap log close
set more off

cd /Users/sokbaelee/Dropbox/Persuasion/STATAcodes/persuasio
log using persuasio_turnout, replace

matrix turnout = ///
  ( 0.472, 0.448, 0.279, 0 \ ///
	0.310, 0.286, 0.293, 0 \ ///
	0.711, 0.660, 0.737, 0 \ ///
	0.416, 0.405, 0.414, 0 \ ///
	0.455, 0.435, 0.800, 0 \ ///
	0.700, 0.690, 0.250, 0 )
	
matrix results = J(1,4,.)
	
foreach j of numlist 1/6 {	

	display `j'

	scalar y1 = turnout[`j',1]
	scalar y0 = turnout[`j',2]
	scalar e1 = turnout[`j',3]
	scalar e0 = turnout[`j',4]

	calc4persuasio y1 y0 e1 e0

	matrix results = results \ (r(apr_lb), r(apr_ub), r(lpr_lb), r(lpr_ub)) 

}

matrix results = 100*results[2..7,1..4]

frmttable using persuasio_turnout_20201204, statmat(results) tex replace sdec(1) ///
	ctitles("", APR (LB), APR (UB), LPR (LB), LPR (UB) )  ///
	rtitles("Green and Gerber (2000)" \ "Green, Gerber, and Nickerson (2003)" \ ///
	"Green and Gerber (2001)" \ "Green and Gerber (2001)" \    ///
	"Gentzkow (2006)" \ "Gentzkow, Shapiro, and Sinkinson (2011)")  ///
	title("Persuasion Rates: Papers on Voter Turnout")

