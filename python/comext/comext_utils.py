from __future__ import annotations

from typing import Any, Dict, List

import pandas as pd


def _compute_strides(sizes: List[int]) -> List[int]:
    n = len(sizes)
    strides: List[int] = [0] * n
    for k in range(n):
        if k == n - 1:
            strides[k] = 1
        else:
            prod = 1
            for v in sizes[k + 1 :]:
                prod *= int(v)
            strides[k] = prod
    return strides


def _invert_index_map(index_map: Dict[str, int]) -> Dict[int, str]:
    # index_map is like {code: pos}; invert to {pos: code}
    return {int(pos): code for code, pos in index_map.items()}


def comext_json_to_labeled_df(doc: Dict[str, Any]) -> pd.DataFrame:
    """
    Convert Eurostat COMEXT JSON (SDMX-like) to a labeled pandas DataFrame.

    Expected keys in doc: value (dict), id (list), size (list), dimension (dict)
    """
    values_obj = doc.get("value")
    if not values_obj:
        return pd.DataFrame()

    dim_ids: List[str] = list(doc.get("id", []))
    sizes = [int(s) for s in doc.get("size", [])]
    dims = doc.get("dimension", {})
    num_dims = len(dim_ids)

    strides = _compute_strides(sizes)

    # Prepare per-dimension inverted index maps and labels
    dim_pos_to_code: Dict[str, Dict[int, str]] = {}
    dim_code_to_label: Dict[str, Dict[str, str]] = {}
    for dn in dim_ids:
        d = dims.get(dn) or {}
        cat = d.get("category") or {}
        index_map = cat.get("index") or {}
        labels = cat.get("label") or {}
        dim_pos_to_code[dn] = _invert_index_map({k: int(v) for k, v in index_map.items()})
        dim_code_to_label[dn] = {str(k): str(v) for k, v in labels.items()} if isinstance(labels, dict) else {}

    value_keys = [int(k) for k in values_obj.keys()]
    value_vals = list(values_obj.values())

    records: List[Dict[str, Any]] = []
    for i, idx in enumerate(value_keys):
        r = int(idx)
        pos: List[int] = [0] * num_dims
        for k in range(num_dims):
            stride = strides[k]
            pos[k] = r // stride
            r = r % stride

        rec: Dict[str, Any] = {"value": pd.to_numeric(value_vals[i], errors="coerce")}
        for k, dn in enumerate(dim_ids):
            code = dim_pos_to_code.get(dn, {}).get(pos[k])
            rec[dn] = code
            lbl_map = dim_code_to_label.get(dn, {})
            rec[f"{dn}_label"] = lbl_map.get(code) if code is not None else None

        records.append(rec)

    df = pd.DataFrame.from_records(records)
    return df


