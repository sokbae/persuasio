foreach topic in persuasio4yz aprlb calc4persuasio {
    translate `topic'.sthlp `topic'.pdf, translator(smcl2pdf) replace header(off) logo(off) pagesize(A4)
}
