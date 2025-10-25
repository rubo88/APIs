version 15.0

local tableid 67821
local nocab 1
local output_name "ine_ejemplo"

cap mkdir data
local outcsv "data/`output_name'.csv"

local url "https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/`tableid'.csv?nocab=`nocab'"
cap noi copy "`url'" "`outcsv'", replace
if _rc {
    di as error "Stata copy failed (rc = " _rc ") — falling back to curl"
    // Use curl with redirects and relaxed TLS verification as a fallback
    !curl -sSLk --retry 3 --fail -o "`outcsv'" "`url'"
    // Don't trust _rc after shell; verify file presence instead
    capture confirm file "`outcsv'"
    if _rc {
        di as error "curl did not produce output file '" + "`outcsv'" + "'"
        error 5100
    }
}


