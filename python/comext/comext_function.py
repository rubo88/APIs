from __future__ import annotations

from typing import Dict, Iterable, List

import pandas as pd
import requests

from comext_utils import comext_json_to_labeled_df


def _build_query_params(filters: Dict[str, Iterable[str]]) -> List[tuple]:
    params: List[tuple] = []
    for dim_name, values in filters.items():
        if values is None:
            continue
        for v in values:
            params.append((dim_name, str(v)))
    return params


def comext_api_function(dataset_id: str, filters: Dict[str, Iterable[str]]) -> pd.DataFrame:
    if not isinstance(filters, dict) or not filters:
        raise ValueError("'filters' debe ser un dict nombrado: dimension -> lista de valores")

    base = f"https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/{dataset_id}"
    params = _build_query_params(filters)
    resp = requests.get(base, params=params, headers={"Accept": "application/json"}, timeout=120)
    resp.raise_for_status()

    doc = resp.json()
    df = comext_json_to_labeled_df(doc)
    return df


