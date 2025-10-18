# Descargador mínimo OCDE SDMX (CSV)
# ----------------------------------------------------------------------------
# Objetivo
#   Descarga datos SDMX de la OCDE y guarda un CSV
# ----------------------------------------------------------------------------
import os
import io
import pandas as pd
import requests


def main() -> None:
    # Cambiar directorio a la carpeta del script para rutas consistentes
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Parámetros
    base_url = "https://sdmx.oecd.org/public/rest/data"
    agency_identifier = "OECD.ECO.MAD"
    dataset_identifier = "DSD_EO@DF_EO"
    dataset_version = ""

    # Construcción de URL y petición
    data_identifier = f"{agency_identifier},{dataset_identifier},{dataset_version}"
    url = f"{base_url}/{data_identifier}/FRA+DEU.PDTY.A"
    params = {
        "startPeriod": "1965",
        "endPeriod": "2023",
        "dimensionAtObservation": "AllDimensions",
    }
    resp = requests.get(url, params=params, headers={"Accept": "text/csv"}, timeout=180)
    resp.raise_for_status()
    text_stream = io.StringIO(resp.content.decode("utf-8"))
    pd.read_csv(text_stream).to_csv("oecd_min.csv", index=False)


if __name__ == "__main__":
    main()


