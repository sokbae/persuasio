foreach topic in persuasio aprlb aprub calc4persuasio persuasio4yz persuasio4ytz lpr4ytz persuasio4ytz2lpr  {
    
	markdoc `topic'.ado, export(sthlp) replace
	
    translate `topic'.sthlp `topic'.pdf, translator(smcl2pdf) replace header(off) logo(off) pagesize(letter)
	
	copy `topic'.pdf docs/`topic'.pdf, replace
	
	rm `topic'.pdf
}

