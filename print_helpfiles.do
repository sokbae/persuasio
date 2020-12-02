foreach topic in persuasio4ytz2lpr { 
*aprlb aprub calc4persuasio persuasio4yz persuasio4ytz lpr4ytz {
    
	markdoc `topic'.ado, export(sthlp) replace
	
    translate `topic'.sthlp `topic'.pdf, translator(smcl2pdf) replace header(off) logo(off) pagesize(letter)
}
