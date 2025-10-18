from __future__ import annotations

import io
import os
from typing import Optional

import pandas as pd
import requests


def fredgraph_api_function(graph_id: str) -> pd.DataFrame:
    url = "https://fred.stlouisfed.org/graph/fredgraph.csv"
    resp = requests.get(url, params={"g": graph_id}, headers={"Accept": "text/csv"}, timeout=120)
    resp.raise_for_status()
    text_stream = io.StringIO(resp.content.decode("utf-8"))
    return pd.read_csv(text_stream)


def fred_api_function(
    series_id: str,
    observation_start: Optional[str] = None,
    observation_end: Optional[str] = None,
    realtime_start: Optional[str] = None,
    realtime_end: Optional[str] = None,
    limit: Optional[int] = None,
    offset: Optional[int] = None,
    sort_order: str = "asc",
    units: Optional[str] = None,
    frequency: Optional[str] = None,
    aggregation_method: Optional[str] = None,
    output_type: Optional[int] = None,
    vintage_dates: Optional[str] = None,
    api_key: Optional[str] = None,
):
    if api_key is None:
        api_key = os.environ.get("FRED_API_KEY")
    if not api_key:
        raise RuntimeError("Defina la variable de entorno FRED_API_KEY para usar fred_api_function.")

    if units is not None:
        allowed_units = {"lin","chg","ch1","pch","pc1","pca","cch","cca","log"}
        if units not in allowed_units:
            raise ValueError(f"Valor de 'units' no válido: {units}")
    if frequency is not None:
        allowed_freq = {"d","w","bw","m","q","sa","a","wef","weth","wew","wetu","wem","wesu","wesa","bwew","bwem"}
        if frequency not in allowed_freq:
            raise ValueError(f"Valor de 'frequency' no válido: {frequency}")
    if aggregation_method is not None:
        allowed_agg = {"avg","sum","eop"}
        if aggregation_method not in allowed_agg:
            raise ValueError(f"Valor de 'aggregation_method' no válido: {aggregation_method}")
    if output_type is not None and output_type not in {1,2,3,4}:
        raise ValueError("'output_type' debe ser uno de 1,2,3,4")

    url = "https://api.stlouisfed.org/fred/series/observations"
    q = {
        "series_id": series_id,
        "api_key": api_key,
        "file_type": "json",
    }
    if observation_start: q["observation_start"] = observation_start
    if observation_end: q["observation_end"] = observation_end
    if realtime_start: q["realtime_start"] = realtime_start
    if realtime_end: q["realtime_end"] = realtime_end
    if limit is not None: q["limit"] = limit
    if offset is not None: q["offset"] = offset
    if sort_order: q["sort_order"] = sort_order
    if units: q["units"] = units
    if frequency: q["frequency"] = frequency
    if aggregation_method: q["aggregation_method"] = aggregation_method
    if output_type is not None: q["output_type"] = output_type
    if vintage_dates: q["vintage_dates"] = vintage_dates

    resp = requests.get(url, params=q, headers={"Accept": "application/json"}, timeout=120)
    resp.raise_for_status()
    obj = resp.json()
    if "observations" not in obj:
        raise RuntimeError("Estructura inesperada de la API de FRED; falta 'observations'.")
    return pd.DataFrame(obj["observations"])  # already flattened keys


