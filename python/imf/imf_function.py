from __future__ import annotations

import dataclasses
from typing import Any, Dict, List

import pandas as pd
import requests


@dataclasses.dataclass
class _Obs:
    time_period: str
    value: float | None


def _normalize_obs_list(obs_raw: Any) -> List[_Obs]:
    # Obs can be a dict (single obs) or a list of dicts
    if isinstance(obs_raw, dict) and "@TIME_PERIOD" in obs_raw:
        obs_raw = [obs_raw]
    result: List[_Obs] = []
    if isinstance(obs_raw, list):
        for o in obs_raw:
            if not isinstance(o, dict):
                continue
            tp = o.get("@TIME_PERIOD")
            val = o.get("@OBS_VALUE")
            num = None
            if val is not None:
                try:
                    num = float(val)
                except (TypeError, ValueError):
                    num = None
            if tp is not None:
                result.append(_Obs(time_period=str(tp), value=num))
    return result


def _extract_series_df(series: Dict[str, Any]) -> pd.DataFrame | None:
    # Dimension attributes come prefixed by '@' (SDMX-JSON CompactData)
    attr_names = [n for n in series.keys() if n.startswith("@")]
    dim_values = {n[1:]: series.get(n) for n in attr_names}

    obs = series.get("Obs")
    normalized = _normalize_obs_list(obs)
    if not normalized:
        return None

    obs_df = pd.DataFrame(
        {
            "TIME_PERIOD": [o.time_period for o in normalized],
            "OBS_VALUE": [o.value for o in normalized],
        }
    )

    if dim_values:
        # Repeat dimension row for each observation
        dim_df = pd.DataFrame([dim_values])
        dim_df = pd.concat([dim_df] * len(obs_df), ignore_index=True)
        return pd.concat([dim_df, obs_df], axis=1)
    return obs_df


def imf_api_function(
    dataset: str,
    key: str,
    startPeriod: str | None = None,
    endPeriod: str | None = None,
    base_url: str = "https://dataservices.imf.org/REST/SDMX_JSON.svc",
) -> pd.DataFrame:
    """
    Descargar datos del FMI (SDMX-JSON CompactData) y devolver DataFrame.

    Parameters
    ----------
    dataset : str
        Identificador del dataset (p. ej., "IFS").
    key : str
        Clave SDMX completa, típicamente FREQ.COUNTRY.INDICATOR (p. ej., "M.ES.PCPI_IX").
    startPeriod, endPeriod : str | None
        Límites de periodo (p. ej., "2018", "2023").
    base_url : str
        Host del servicio SDMX JSON del FMI.
    """
    if not dataset:
        raise ValueError("'dataset' es obligatorio (p. ej., 'IFS')")
    if not key:
        raise ValueError("'key' es obligatorio (p. ej., 'M.ES.PCPI_IX')")

    url = f"{base_url}/CompactData/{dataset}/{requests.utils.quote(key, safe='')}"
    params: Dict[str, Any] = {}
    if startPeriod is not None:
        params["startPeriod"] = startPeriod
    if endPeriod is not None:
        params["endPeriod"] = endPeriod

    resp = requests.get(url, params=params, headers={"Accept": "application/json"}, timeout=120)
    resp.raise_for_status()
    obj = resp.json()

    # Navigate SDMX CompactData structure
    data_set = obj.get("CompactData", {}).get("DataSet")
    if not data_set:
        return pd.DataFrame()
    series_list = data_set.get("Series") if isinstance(data_set, dict) else None
    if series_list is None:
        return pd.DataFrame()

    # Normalize to list of series
    if isinstance(series_list, dict) and "Obs" in series_list:
        series_list = [series_list]

    frames: List[pd.DataFrame] = []
    for ser in series_list:
        if not isinstance(ser, dict):
            continue
        df = _extract_series_df(ser)
        if df is not None and not df.empty:
            frames.append(df)

    if not frames:
        return pd.DataFrame()
    return pd.concat(frames, ignore_index=True)
