version 15.0

local tableid 67821
local nocab 1
local output_name "ine_ejemplo"

cap mkdir data
local outcsv "data/`output_name'.csv"

local url "https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/`tableid'.csv?nocab=`nocab'"
copy "`url'" "`outcsv'", replace


