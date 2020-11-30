foreach topic in persuasio4yz persuasio4ytz { 
*aprlb aprub calc4persuasio {
    translate `topic'.sthlp `topic'.pdf, translator(smcl2pdf) replace header(off) logo(off) pagesize(letter)
}
