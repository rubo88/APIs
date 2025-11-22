# Minimal IMF API downloader (link only). Notice is a xml file, not a csv file.
# Requires: install.packages("rsdmx")
library(rsdmx)
# Disable SSL verification for this session if you encounter certificate errors
httr::set_config(httr::config(ssl_verifypeer = 0L, ssl_verifyhost = 0L))
df <- as.data.frame(readSDMX("https://api.imf.org/external/sdmx/3.0/data/dataflow/IMF.STA/QNEA/%2B/ESP%2BFRA.B1GQ.Q.SA.XDC.Q"))


