global agency_identifier "ESTAT"
global dataset_eurostat "nama_10_a64"    
global filters "?c[freq]=A&c[unit]=CLV_I20,CLV05_MEUR&c[nace_r2]=TOTAL&c[na_item]=B1G,P1&c[geo]=ES&c[TIME_PERIOD]=ge:1995"

import delimited "https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/${agency_identifier}/${dataset_eurostat}/1.0/${filters}&compress=false&format=csvdata&formatVersion=2.0&lang=en&labels=name", encoding("utf-8") clear

