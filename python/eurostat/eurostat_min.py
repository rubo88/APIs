# Descargador mínimo Eurostat SDMX 3.0 (CSV)
# ----------------------------------------------------------------------------
# Objetivo
#   Descarga datos Eurostat (SDMX CSV) con filtros y guarda un CSV
# ----------------------------------------------------------------------------
import os
import io
import pandas as pd
import requests


def main() -> None:
    # Cambiar directorio a la carpeta del script para rutas consistentes
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Construcción de URL y parámetros (c[dim]=val1,val2)
    base_url = "https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow"
    data_identifier = "ESTAT/nama_10_a64/1.0"
    url = f"{base_url}/{data_identifier}/"
    params = {
        "c[geo]": "IT",
        "c[na_item]": "B1G",
        "c[unit]": "CLV20_MEUR",
        "c[TIME_PERIOD]": "ge:1995",
        "compress": "false",
        "format": "csvdata",
        "formatVersion": "2.0",
        "lang": "en",
        "labels": "name",
    }
    headers = {"Accept": "application/vnd.sdmx.data+csv; version=2.0.0"}
    resp = requests.get(url, params=params, headers=headers, timeout=180)
    resp.raise_for_status()
    text_stream = io.StringIO(resp.content.decode("utf-8"))
    pd.read_csv(text_stream).to_csv("eurostat_min.csv", index=False)


if __name__ == "__main__":
    main()


