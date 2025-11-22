% Minimal OECD API downloader (link only)
url = "https://sdmx.oecd.org/public/rest/data/OECD.ECO.MAD,DSD_EO@DF_EO,/FRA+DEU.PDTY.A?format=csvfile&startPeriod=1965&endPeriod=2023";
t = readtable(url);

