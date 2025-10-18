# Descargador mínimo Banco Mundial (JSON -> CSV)
# ----------------------------------------------------------------------------
# Objetivo
#   Consulta indicadores del Banco Mundial y guarda un CSV
# ----------------------------------------------------------------------------
import os
import pandas as pd
import requests


def main() -> None:
    # Cambiar directorio a la carpeta del script para rutas consistentes
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Construcción de URL y petición
    base_url = "https://api.worldbank.org/v2"
    path = "/country/ESP/indicator/NY.GDP.MKTP.KD.ZG"
    url = f"{base_url}{path}"
    params = {"format": "json", "per_page": 20000, "date": "2000:2023"}
    resp = requests.get(url, params=params, headers={"Accept": "application/json"}, timeout=120)
    resp.raise_for_status()
    obj = resp.json()
    if not isinstance(obj, list) or len(obj) < 2 or obj[1] is None:
        raise RuntimeError("Unexpected World Bank response structure; no data array present.")
    pd.DataFrame(obj[1]).to_csv("worldbank_min.csv", index=False)


if __name__ == "__main__":
    main()


