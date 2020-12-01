foreach topic in lpr4ytz { 
*aprlb aprub calc4persuasio  persuasio4yz persuasio4ytz {
    
	markdoc `topic'.ado, export(sthlp) replace
	
    translate `topic'.sthlp `topic'.pdf, translator(smcl2pdf) replace header(off) logo(off) pagesize(letter)
}
