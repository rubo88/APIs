from __future__ import annotations

import io
from typing import Dict, Iterable

import pandas as pd
import requests


def imf_api_function(
    dataset_identifier: str,
    data_selection: str,
    filters: Dict[str, Iterable[str]] | None = None,
    agency_identifier: str = "IMF.STA",
    dataset_version: str = "+",
    accept_csv_version: str = "1.0.0",
    base_url: str = "https://api.imf.org/external/sdmx/3.0/data/dataflow",
) -> pd.DataFrame:
    """
    Descargar datos desde el FMI (SDMX 3.0 CSV) y devolver un DataFrame.
    - dataset_identifier: p. ej., "QNEA"
    - data_selection: clave SDMX (p. ej., "ESP.B1GQ.Q.SA.XDC.Q" o "ESP+FRA.B1GQ.Q.SA.XDC.Q")
    - filters: dict como { 'TIME_PERIOD': ['ge:2020-Q1','le:2020-Q4'] }
    """
    if filters is None:
        filters = {}

    # Construir la URL SDMX 3.0 CSV: base/agency/dataset/version/key
    # Codificar conservando reservados útiles (+,*,:,/ ,)
    from urllib.parse import quote

    def urlencode_keep_reserved(s: str) -> str:
        return quote(str(s), safe="+*:,/,")

    url = (
        f"{base_url}/"
        f"{agency_identifier}/"
        f"{dataset_identifier}/"
        f"{urlencode_keep_reserved(dataset_version)}/"
        f"{urlencode_keep_reserved(data_selection)}"
    )

    # Filtros como c[DIM] = v1+v2 (unir con '+')
    params: Dict[str, str] = {}
    for dim, values in filters.items():
        if values is None:
            continue
        if isinstance(values, (list, tuple, set)):
            joined = "+".join(map(str, values))
        else:
            joined = str(values)
        params[f"c[{dim}]"] = joined

    headers = {
        "Accept": f"application/vnd.sdmx.data+csv;version={accept_csv_version}",
        "Cache-Control": "no-cache",
    }

    resp = requests.get(url, params=params, headers=headers, timeout=180)
    resp.raise_for_status()

    text_stream = io.StringIO(resp.content.decode("utf-8"))
    df = pd.read_csv(text_stream)
    return df
