global indicator "NY.GDP.MKTP.KD.ZG"


* 1. Download ZIP
copy "https://api.worldbank.org/v2/en/indicator/${indicator}?downloadformat=csv" ///
    "wb_gdp_growth.zip", replace

* 2. Unzip
unzipfile "wb_gdp_growth.zip", replace

* list files if you want to see exact name
dir

* 3. Import the main data CSV (adjust filename to what you see)
import delimited "API_${indicator}_DS2_en_csv_v2_260128.csv", ///
    varnames(1) rowrange(5) encoding(UTF-8) clear