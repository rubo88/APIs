// ine_jaxi_function.do
// Usage: do ine_jaxi_function.do, tableid(67821) nocab(1) directory(t) locale(es) variant(csv_bdsc) outcsv("data.csv")

program define ine_jaxi_function, rclass
    version 15.0
    syntax , tableid(string) [ nocab(string) directory(string) locale(string) variant(string) outcsv(string) ]

    if missing(`"`nocab'"') local nocab "1"
    if missing(`"`directory'"') local directory "t"
    if missing(`"`locale'"') local locale "es"
    if missing(`"`variant'"') local variant "csv_bdsc"

    local base "https://www.ine.es/jaxiT3/files"
    local url "`base'/`directory'/`locale'/`variant'/`tableid'.csv?nocab=`nocab'"

    // Download to a temp file
    tempfile tmpcsv
    quietly copy "`url'" "`tmpcsv'", replace

    // Return path so caller can import
    return local csvfile "`tmpcsv'"
end





