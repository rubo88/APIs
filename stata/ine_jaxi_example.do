version 15.0

do "stata/ine_jaxi_function.do", tableid(67821) nocab(1)
local tmpcsv `r(csvfile)'

// import semicolon-delimited CSV
import delimited using "`tmpcsv'", clear delim(";") varnames(1) stringcols(_all)

// Save to the same example path as R example
export delimited using "R/ine/ine_jaxi_example.csv", replace delim(";")


