from __future__ import annotations

import io
from urllib.parse import quote

import pandas as pd
import requests

# Parámetros básicos (análogos a R/imf/imf_min.R)
base_url = "https://api.imf.org/external/sdmx/3.0/data/dataflow"
agency_identifier = "IMF.STA"
dataset_identifier = "QNEA"
dataset_version = "+"

# Clave SDMX (múltiples países con '+')
data_selection = "ESP+FRA.B1GQ.Q.SA.XDC.Q"

# Filtro de fechas
filters = {
    "TIME_PERIOD": ["ge:2020-Q1", "le:2020-Q4"],
}

# Construcción de URL y query
url = (
    f"{base_url}/"
    f"{agency_identifier}/"
    f"{dataset_identifier}/"
    f"{quote(dataset_version, safe='+*:,/ ,')}/"
    f"{quote(data_selection, safe='+*:,/ ,')}"
)
params = {f"c[{k}]": "+".join(v) for k, v in filters.items()}

headers = {
    "Accept": "application/vnd.sdmx.data+csv;version=1.0.0",
    "Cache-Control": "no-cache",
}

resp = requests.get(url, params=params, headers=headers, timeout=180)
resp.raise_for_status()

df = pd.read_csv(io.StringIO(resp.content.decode("utf-8")))
df.to_csv("imf_min.csv", index=False)
