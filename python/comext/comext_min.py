import os
import requests
import pandas as pd
from comext_utils import comext_json_to_labeled_df


def main() -> None:
    # Cambiar directorio a la carpeta del script para rutas consistentes
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Parámetros del dataset y filtros (parámetros repetidos para multiselección)
    dataset_id = "DS-059341"
    base = f"https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/{dataset_id}"
    params = [
        ("reporter", "ES"),
        ("partner", "US"),
        ("product", "1509"),
        ("product", "8703"),
        ("flow", "2"),
        ("freq", "A"),
        ("time", "2015"),
        ("time", "2016"),
        ("time", "2017"),
        ("time", "2018"),
        ("time", "2019"),
        ("time", "2020"),
    ]

    resp = requests.get(base, params=params, headers={"Accept": "application/json"}, timeout=180)
    resp.raise_for_status()
    doc = resp.json()
    df = comext_json_to_labeled_df(doc)
    df.to_csv("comext_min.csv", index=False)


if __name__ == "__main__":
    main()


