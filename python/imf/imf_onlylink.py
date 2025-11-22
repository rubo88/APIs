# Minimal IMF API downloader (link only). Notice is a xml file, not a csv file.
# Requires: pip install pandasdmx
import pandasdmx as sdmx
df = sdmx.read_url("https://api.imf.org/external/sdmx/3.0/data/dataflow/IMF.STA/QNEA/%2B/ESP%2BFRA.B1GQ.Q.SA.XDC.Q").to_pandas()

