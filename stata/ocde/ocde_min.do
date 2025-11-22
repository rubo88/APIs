global agency_identifier "OECD.ECO.MAD"
global dataset_identifier "DSD_EO@DF_EO"
global data_selection "FRA+DEU.PDTY.A"
global startPeriod "1965"
global endPeriod "2023"

import delimited "https://sdmx.oecd.org/public/rest/data/${agency_identifier},${dataset_identifier},/${data_selection}?format=csvfile&startPeriod=${startPeriod}&endPeriod=${endPeriod}", encoding("utf-8") clear  