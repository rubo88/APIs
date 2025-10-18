from __future__ import annotations

import io
import pandas as pd
import requests


def oecd_api_function(
    agency_identifier: str,
    dataset_identifier: str,
    data_selection: str,
    base_url: str = "https://sdmx.oecd.org/public/rest/data",
    dataset_version: str = "",
    startPeriod: str | None = None,
    endPeriod: str | None = None,
    dimensionAtObservation: str | None = None,
) -> pd.DataFrame:
    """
    Descargar datos de la OCDE (SDMX CSV) y devolver DataFrame.
    """
    data_identifier = f"{agency_identifier},{dataset_identifier},{dataset_version}"
    params: dict[str, str] = {}
    if startPeriod:
        params["startPeriod"] = startPeriod
    if endPeriod:
        params["endPeriod"] = endPeriod
    if dimensionAtObservation:
        params["dimensionAtObservation"] = dimensionAtObservation

    url = f"{base_url}/{data_identifier}/{data_selection}"
    resp = requests.get(url, params=params, headers={"Accept": "text/csv"}, timeout=180)
    resp.raise_for_status()

    text_stream = io.StringIO(resp.content.decode("utf-8"))
    df = pd.read_csv(text_stream)
    return df


