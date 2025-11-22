% Minimal Eurostat API downloader (link only)
url = "https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/ESTAT/nama_10_a64/1.0/?c[geo]=ES,FR&c[na_item]=B1G,P1&c[unit]=CLV20_MEUR&c[TIME_PERIOD]=ge:1995&compress=false&format=csvdata&formatVersion=2.0&lang=en&labels=name";
t = readtable(url);

