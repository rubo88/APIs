# Descargador mínimo BCE Data API (CSV) — autocontenido (no usa la función)
# ----------------------------------------------------------------------------
# Objetivo
#   Descarga una serie del BCE (csvdata) y la guarda como CSV
# ----------------------------------------------------------------------------
import os
import io
import pandas as pd
import requests


def main() -> None:
    # Cambiar directorio a la carpeta del script para rutas consistentes
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Parámetros mínimos
    dataset = "BSI"
    series_key = "M.U2.Y.V.M30.X.I.U2.2300.Z01.A"

    # Construcción de URL y petición
    url = f"https://data-api.ecb.europa.eu/service/data/{dataset}/{series_key}"
    params = {"format": "csvdata"}
    resp = requests.get(url, params=params, headers={"Accept": "text/csv"}, timeout=120)
    resp.raise_for_status()

    # Guardar CSV
    text_stream = io.StringIO(resp.content.decode("utf-8"))
    pd.read_csv(text_stream).to_csv("ecb_min.csv", index=False)


if __name__ == "__main__":
    main()


