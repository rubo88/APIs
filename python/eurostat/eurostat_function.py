from __future__ import annotations

import io
from typing import Dict, Iterable

import pandas as pd
import requests


def eurostat_api_function(
    dataset_identifier: str,
    filters: Dict[str, Iterable[str]],
    agency_identifier: str = "ESTAT",
    dataset_version: str = "1.0",
    compress: str = "false",
    format: str = "csvdata",
    formatVersion: str = "2.0",
    lang: str = "en",
    labels: str = "name",
):
    """
    Descargar datos desde Eurostat SDMX 3.0 (CSV) y devolver DataFrame.
    Replica la firma de la función R correspondiente.
    """
    base_url = "https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow"

    data_identifier = f"{agency_identifier}/{dataset_identifier}/{dataset_version}"
    url = f"{base_url}/{data_identifier}/"

    if not isinstance(filters, dict):
        raise ValueError("'filters' debe ser un dict nombrado de dimension -> valores")

    # Convertir filtros a c[dim]=val1,val2
    filters_params = {f"c[{k}]": ",".join(map(str, v)) if isinstance(v, (list, tuple, set)) else str(v) for k, v in filters.items()}

    common_params = dict(
        compress=compress,
        format=format,
        formatVersion=formatVersion,
        lang=lang,
        labels=labels,
    )
    params = {**filters_params, **common_params}

    headers = {"Accept": "application/vnd.sdmx.data+csv; version=2.0.0"}
    resp = requests.get(url, params=params, headers=headers, timeout=180)
    resp.raise_for_status()

    text_stream = io.StringIO(resp.content.decode("utf-8"))
    df = pd.read_csv(text_stream)
    return df


