from __future__ import annotations

import io
import pandas as pd
import requests


def ecb_api_function(
    dataset: str,
    series_key: str,
    base_url: str = "https://data-api.ecb.europa.eu/service/data",
) -> pd.DataFrame:
    """
    Descargar datos del BCE (ECB Data) en CSV (csvdata) y devolver DataFrame.

    Parameters
    ----------
    dataset : str
        Identificador del dataset (p. ej., "BSI").
    series_key : str
        Clave completa de la serie (dimensiones concatenadas con '.').
    base_url : str
        Host del servicio de datos del BCE.
    """

    url = f"{base_url}/{dataset}/{series_key}"
    params = {"format": "csvdata"}
    resp = requests.get(url, params=params, headers={"Accept": "text/csv"}, timeout=120)
    resp.raise_for_status()

    text_stream = io.StringIO(resp.content.decode("utf-8"))
    df = pd.read_csv(text_stream)
    return df


