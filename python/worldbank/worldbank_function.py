from __future__ import annotations

import pandas as pd
import requests


def worldbank_api_function(
    iso3: str,
    indicator: str,
    date: str | None = None,
    per_page: int = 20000,
    base_url: str = "https://api.worldbank.org/v2",
) -> pd.DataFrame:
    path = f"/country/{iso3}/indicator/{indicator}"
    url = f"{base_url}{path}"
    q = {"format": "json", "per_page": per_page}
    if date:
        q["date"] = date

    resp = requests.get(url, params=q, headers={"Accept": "application/json"}, timeout=120)
    resp.raise_for_status()
    obj = resp.json()
    if not isinstance(obj, list) or len(obj) < 2 or obj[1] is None:
        raise RuntimeError("Unexpected World Bank response structure; no data array present.")
    return pd.DataFrame(obj[1])


