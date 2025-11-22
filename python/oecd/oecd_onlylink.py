# Minimal OECD API downloader (link only)
import pandas as pd
df = pd.read_csv("https://sdmx.oecd.org/public/rest/data/OECD.ECO.MAD,DSD_EO@DF_EO,/FRA+DEU.PDTY.A?format=csvfile&startPeriod=1965&endPeriod=2023")

