# Repository Codes Documentation

# Python

## COMEXT

### Guía rápida: Eurostat Comext con Python

Este documento explica cómo usar la función en `python/comext/comext_function.py` para descargar datos desde el endpoint Eurostat COMEXT en JSON y convertirlos a un `pandas.DataFrame` etiquetado.

#### Requisitos
- Paquetes: `requests`, `pandas`

#### Codigos ejemplo
- `comext_min.py`: ejemplo mínimo que descarga y guarda `comext_min.csv`.
- `comext_example.py`: ejemplo de uso de la función `comext_api_function` (implícito en la descripción).

#### Inputs
- **Obligatorios**
  - `dataset_id`: id del dataset Comext (p. ej., `"DS-059341"`).
  - `filters`: diccionario nombrado dimensión -> lista de valores. Para multiselección se envían parámetros repetidos.

#### Cómo elegir inputs
1) Identifique el dataset en la guía de Comext y el portal de Eurostat.
2) Consulte la estructura del dataset en la guía Comext para conocer las dimensiones válidas y sus valores.
3) Ajuste `filters` con nombres de dimensiones válidos. Para múltiples valores use listas (enviamos parámetros repetidos).

#### Sintaxis de la API (COMEXT)
- **Formato general:**
  ```
  https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/{dataset_id}?{dim}={val}&{dim}={val}...
  ```

- **Ejemplo:**
  ```
  https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/DS-059341?reporter=ES&partner=US&product=1509&product=8703&flow=2&freq=A&time=2015&time=2016
  ```

#### Output
- Un `pandas.DataFrame` con códigos por dimensión, columnas de etiquetas `*_label` y la columna numérica `value`.

#### Notas
- Si la API devuelve error, verifique el `dataset_id` y las dimensiones en la documentación de Comext.

#### Función auxiliar para convertir JSON a DataFrame
La función `comext_json_to_labeled_df` convierte el JSON en un DataFrame con columnas por dimensión (códigos y `*_label`) y la columna `value` (numérica cuando procede).

#### Enlaces útiles
- Guía de Comext: https://ec.europa.eu/eurostat/web/user-guides/data-browser/api-data-access/api-getting-started/comext-database
- Portal Eurostat: https://ec.europa.eu/eurostat/


### comext_example.py

```python
# Ejemplo de uso — Eurostat COMEXT (JSON -> DataFrame -> CSV)
# ----------------------------------------------------------------------------
# 1) Cargar la función
# 2) Ejecutar la consulta con filtros (parámetros repetidos para multiselección)
# 3) Guardar el resultado como CSV
# ----------------------------------------------------------------------------
import os
from comext_function import comext_api_function


def main() -> None:
    # Asegurar rutas relativas coherentes
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Ejecutar la consulta
    df = comext_api_function(
        dataset_id="DS-059341",
        filters={
            "reporter": ["ES"],
            "partner": ["US"],
            "product": ["1509"],
            "flow": ["2"],
            "freq": ["A"],
            "time": ["2019", "2020"],
        },
    )

    # Guardar el resultado
    df.to_csv("comext_example.csv", index=False)


if __name__ == "__main__":
    main()



```

### comext_function.py

```python
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



```

### comext_min.py

```python
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



```

### comext_utils.py

```python
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



```

## ECB

### Guía rápida: BCE con Python

Este documento explica cómo usar `python/ecb/ecb_function.py` para descargar series del BCE en formato CSV y obtener un `pandas.DataFrame`.

#### Requisitos
- Paquetes: `requests`, `pandas`

#### Codigos ejemplo
- `ecb_onlylink.py`: ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `ecb_min.py`: ejemplo mínimo para descargar datos del BCE sin usar la función `ecb_api_function`.
- `ecb_example.py`: ejemplo de uso de la función `ecb_api_function`.

#### Inputs
- **Obligatorios**
  - `dataset`: identificador del dataset (p. ej., `"BSI"`).
  - `series_key`: clave completa de la serie (dimensiones separadas por `.`).

#### Cómo elegir inputs
1) Abra el dataset en el portal BCE (p. ej., BSI): https://data.ecb.europa.eu/data/datasets/BSI
2) Use los filtros hasta ver la serie concreta; la clave `series_key` aparece en el recuadro de la serie.
3) Cada elemento de `series_key` es una dimensión del dataset; puede cambiar `U2` (Área del euro) por `ES` (España), etc. Pinchando en `view all` se pueden ver todas las dimensiones del dataset y sus códigos. Para conocer qué valores puede tomar una dimensión, vea un dataset concreto con `.../structure`.

#### Sintaxis de la API (BCE)
- **Formato general:**
  ```
  https://data-api.ecb.europa.eu/service/data/{dataset}/{seriesKey}?format=csvdata
  ```

- **Ejemplo:**
  ```
  https://data-api.ecb.europa.eu/service/data/BSI/M.U2.Y.V.M30.X.I.U2.2300.Z01.A?format=csvdata
  ```

#### Output
- Un `pandas.DataFrame` con los datos descargados.

#### Notas
- El parámetro `format=csvdata` se añade automáticamente.

#### Enlaces útiles
- Portal de datos del BCE (datasets): https://data.ecb.europa.eu/data/datasets/
- Documentación de la API de datos del BCE: https://data.ecb.europa.eu/help/api/overview
- API de datos (servicio): https://data-api.ecb.europa.eu/service/


### ecb_example.py

```python
# Ejemplo de uso — BCE Data API (CSV)
# ----------------------------------------------------------------------------
# 1) Cargar la función
# 2) Ejecutar la consulta indicando dataset y series_key
# 3) Guardar el resultado como CSV
# ----------------------------------------------------------------------------
import os
from ecb_function import ecb_api_function


def main() -> None:
    # Asegurar rutas relativas coherentes
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Ejecutar la consulta
    df = ecb_api_function(
        dataset="BSI",
        series_key="M.U2.Y.V.M30.X.I.U2.2300.Z01.A",
    )

    # Guardar el resultado
    df.to_csv("ecb_example.csv", index=False)


if __name__ == "__main__":
    main()



```

### ecb_function.py

```python
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



```

### ecb_min.py

```python
# Descargador mínimo BCE Data API (CSV) — autocontenido (no usa la función)
# ----------------------------------------------------------------------------
# Objetivo
#   Descarga una serie del BCE (csvdata) y la guarda como CSV
# ----------------------------------------------------------------------------
import os
import io
import pandas as pd
import requests


def main() -> None:
    # Cambiar directorio a la carpeta del script para rutas consistentes
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Parámetros mínimos
    dataset = "BSI"
    series_key = "M.U2.Y.V.M30.X.I.U2.2300.Z01.A"

    # Construcción de URL y petición
    url = f"https://data-api.ecb.europa.eu/service/data/{dataset}/{series_key}"
    params = {"format": "csvdata"}
    resp = requests.get(url, params=params, headers={"Accept": "text/csv"}, timeout=120)
    resp.raise_for_status()

    # Guardar CSV
    text_stream = io.StringIO(resp.content.decode("utf-8"))
    pd.read_csv(text_stream).to_csv("ecb_min.csv", index=False)


if __name__ == "__main__":
    main()



```

### ecb_onlylink.py

```python
# Minimal ECB Data API downloader (link only)
import pandas as pd
df = pd.read_csv("https://data-api.ecb.europa.eu/service/data/BSI/M.U2.Y.V.M30.X.I.U2.2300.Z01.A?format=csvdata")


```

## ESIOS

## EUROSTAT

### Guía rápida: Eurostat con Python

Este documento explica cómo usar `python/eurostat/eurostat_function.py` para descargar datos Eurostat en formato SDMX-CSV 2.0 y obtener un `pandas.DataFrame`.

#### Requisitos
- Paquetes: `requests`, `pandas`

#### Codigos ejemplo
- `eurostat_onlylink.py`: ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `eurostat_min.py` es un ejemplo mínimo para descargar datos de Eurostat sin usar la función `eurostat_api_function`.
- `eurostat_example.py` es un ejemplo de uso de la función `eurostat_api_function`.

#### Inputs
- **Obligatorios**
  - `dataset_identifier`: identificador del dataset.
  - `filters`: diccionario de filtros (c[dim] en R), por ejemplo `{"geo": ["IT"], ...}`.

- **Opcionales**
  - `agency_identifier` (por defecto `"ESTAT"`).
  - `dataset_version` (`"1.0"`).
  - `compress`, `format`, `formatVersion`, `lang`, `labels` (opcionales).

#### Cómo elegir inputs
1) Lo más sencillo es ir a Eurostat, buscar la serie de interés y copiar el código de la serie. Mire el código de las variables y los valores a filtrar.
2) Use el código de la serie como `dataset_identifier`.
3) Ajuste filtros (`filters`):
   - Añada o cambie dimensiones válidas del dataset (p. ej., `geo`, `na_item`, `unit`, `freq`, `TIME_PERIOD`).
   - Para valores múltiples use listas en Python: `["ES", "FR"]`.
   - En `TIME_PERIOD` puede usar operadores SDMX: `ge:YYYY`, `le:YYYY`, `YYYY:YYYY`, `ge:200Q1`, etc.
4) Cambie parámetros opcionales si es necesario.

#### Sintaxis de la API (SDMX 3.0)
- **Formato general:**
  ```
  {base_url}/{agency_identifier}/{dataset_identifier}/{dataset_version}/?{filters_params}&{common_params}
  ```
  Donde `base_url` es `https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow`.

- **Ejemplo:**
  ```
  https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/ESTAT/nama_10_a64/1.0/?c[geo]=ES,FR&c[na_item]=B1G,P1&c[freq]=A&c[unit]=CLV20_MEUR&c[TIME_PERIOD]=ge:1995&compress=false&format=csvdata&formatVersion=2.0&lang=en&labels=name
  ```

#### Output
- Un `pandas.DataFrame` con los datos descargados.

#### Notas
- Se usa el encabezado `Accept: application/vnd.sdmx.data+csv; version=2.0.0`.

#### Enlaces útiles
- Guía de consultas de datos (SDMX 3.0, Eurostat): [API - Detailed guidelines - SDMX3.0 API - data query](https://ec.europa.eu/eurostat/web/user-guides/data-browser/api-data-access/api-detailed-guidelines/sdmx3-0/data-query)
- [API - Getting started with statistics API - Retrieving your first content](https://ec.europa.eu/eurostat/web/user-guides/data-browser/api-data-access/api-getting-started/api#APIGettingstartedwithstatisticsAPI-Retrievingyourfirstcontent)


### eurostat_example.py

```python
# Ejemplo de uso — Eurostat SDMX 3.0 (CSV)
# ----------------------------------------------------------------------------
# 1) Cargar la función
# 2) Ejecutar la consulta con filtros (c[dim] en R -> dict en Python)
# 3) Guardar el resultado como CSV
# ----------------------------------------------------------------------------
import os
from eurostat_function import eurostat_api_function


def main() -> None:
    # Asegurar rutas relativas coherentes
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Ejecutar la consulta
    df = eurostat_api_function(
        dataset_identifier="nama_10_a64",
        filters={
            "geo": ["IT"],
            "na_item": ["B1G"],
            "unit": "CLV20_MEUR",
            "TIME_PERIOD": "ge:1995",
        },
    )

    # Guardar el resultado
    df.to_csv("eurostat_example.csv", index=False)


if __name__ == "__main__":
    main()



```

### eurostat_function.py

```python
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



```

### eurostat_min.py

```python
# Descargador mínimo Eurostat SDMX 3.0 (CSV)
# ----------------------------------------------------------------------------
# Objetivo
#   Descarga datos Eurostat (SDMX CSV) con filtros y guarda un CSV
# ----------------------------------------------------------------------------
import os
import io
import pandas as pd
import requests


def main() -> None:
    # Cambiar directorio a la carpeta del script para rutas consistentes
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Construcción de URL y parámetros (c[dim]=val1,val2)
    base_url = "https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow"
    data_identifier = "ESTAT/nama_10_a64/1.0"
    url = f"{base_url}/{data_identifier}/"
    params = {
        "c[geo]": "IT",
        "c[na_item]": "B1G",
        "c[unit]": "CLV20_MEUR",
        "c[TIME_PERIOD]": "ge:1995",
        "compress": "false",
        "format": "csvdata",
        "formatVersion": "2.0",
        "lang": "en",
        "labels": "name",
    }
    headers = {"Accept": "application/vnd.sdmx.data+csv; version=2.0.0"}
    resp = requests.get(url, params=params, headers=headers, timeout=180)
    resp.raise_for_status()
    text_stream = io.StringIO(resp.content.decode("utf-8"))
    pd.read_csv(text_stream).to_csv("eurostat_min.csv", index=False)


if __name__ == "__main__":
    main()



```

### eurostat_onlylink.py

```python
# Minimal Eurostat API downloader (link only)
import pandas as pd
df = pd.read_csv("https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/ESTAT/nama_10_a64/1.0/?c[geo]=ES,FR&c[na_item]=B1G,P1&c[unit]=CLV20_MEUR&c[TIME_PERIOD]=ge:1995&compress=false&format=csvdata&formatVersion=2.0&lang=en&labels=name")


```

## FRED

### Guía rápida: FRED con Python

Este documento explica cómo usar las funciones en `python/fred/fred_function.py` para descargar datos desde FRED.

#### Requisitos
- Paquetes: `requests`, `pandas`

#### Codigos ejemplo
- `fred_onlylink.py` es un ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `fred_min.py` es un ejemplo mínimo para descargar datos de FRED sin usar la función.
- `fred_example.py` es un ejemplo de uso de la función `fred_api_function`.

#### Inputs
- **fredgraph_api_function**
  - `graph_id` (Obligatorio): identificador del gráfico compartido en FRED.

- **fred_api_function**
  - `series_id` (Obligatorio): identificador de la serie (p. ej., `"GDP"`).
  - Opcionales: `observation_start`, `observation_end`, `realtime_start`, `realtime_end`, `limit`, `offset`, `sort_order`, `units`, `frequency`, `aggregation_method`, `output_type`, `vintage_dates`, `api_key`.

#### Cómo elegir inputs
- Para `fredgraph_api_function`:
  - Obtenga `graph_id` desde el enlace compartido del gráfico (parámetro `?g=` en la URL).

- Para `fred_api_function`:
  1) Elija `series_id` (p. ej., `GDP`, esto suele estar al lado del nombre de la serie en FRED entre paréntesis).
  2) Defina `FRED_API_KEY` como variable de entorno o pásela como argumento.
  3) Si es necesario, cambie los otros parámetros opcionales.

#### Sintaxis de la API
- **fredgraph CSV:**
  ```
  https://fred.stlouisfed.org/graph/fredgraph.csv?g={graphId}
  ```
- **API v1 observaciones:**
  ```
  https://api.stlouisfed.org/fred/series/observations?series_id={id}&api_key=...&file_type=json
  ```

#### Output
- `pandas.DataFrame` con las observaciones devueltas por cada método.

#### Notas
- La API v1 admite parámetros como `units`, `frequency`, `aggregation_method`, etc. con validación básica.

#### Enlaces útiles
- Referencia oficial: [FRED observations API docs](https://fred.stlouisfed.org/docs/api/fred/series_observations.html)


### fred_example.py

```python
import os
# Ejemplo de uso — FRED (fredgraph y API v1)
# ----------------------------------------------------------------------------
# 1) Descargar CSV de fredgraph (no requiere API key)
# 2) (Opcional) Consultar API v1 con FRED_API_KEY
# ----------------------------------------------------------------------------
from fred_function import fredgraph_api_function, fred_api_function


def main() -> None:
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Ejemplo fredgraph
    df_graph = fredgraph_api_function("1wmdD")
    df_graph.to_csv("fred_graph_example.csv", index=False)

    # Ejemplo API v1 (requiere FRED_API_KEY)
    os.environ["FRED_API_KEY"] = "28ee932ab037f5486dae766aebf0bec3"
    df_api = fred_api_function(series_id="GDPC1", observation_start="2000-01-01")
    df_api.to_csv("fred_api_example.csv", index=False)


if __name__ == "__main__":
    main()



```

### fred_function.py

```python
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



```

### fred_min.py

```python
# Descargador mínimo FRED (fredgraph CSV) — autocontenido (no usa la función)
# ----------------------------------------------------------------------------
# Objetivo
#   Descarga el CSV de un gráfico compartido de FRED y lo guarda
# ----------------------------------------------------------------------------
import os
import io
import pandas as pd
import requests


def main() -> None:
    # Cambiar directorio a la carpeta del script para rutas consistentes
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Parámetros mínimos
    graph_id = "1wmdD"
    url = "https://fred.stlouisfed.org/graph/fredgraph.csv"

    # Petición y guardado
    resp = requests.get(url, params={"g": graph_id}, headers={"Accept": "text/csv"}, timeout=120)
    resp.raise_for_status()
    text_stream = io.StringIO(resp.content.decode("utf-8"))
    pd.read_csv(text_stream).to_csv("fred_graph_min.csv", index=False)


if __name__ == "__main__":
    main()



```

### fred_onlylink.py

```python
# Minimal FRED API downloader (link only)
import pandas as pd
df = pd.read_csv("https://fred.stlouisfed.org/graph/fredgraph.csv?g=1wmdD")


```

## IMF

### Guía rápida: FMI con Python

Este documento explica cómo usar la función en `python/imf/imf_function.py` para descargar datos SDMX-CSV de la API SDMX 3.0 del FMI y obtenerlos como un `pandas.DataFrame`.

#### Requisitos
- Paquetes: `requests`, `pandas`

#### Codigos ejemplo
- `imf_onlylink.py`: ejemplo que descarga y lee el csv directamente del link de la API en una linea (usando `pandasdmx`).
- `imf_min.py`: ejemplo mínimo para construir la URL SDMX-CSV y guardar en CSV.
- `imf_example.py`: ejemplo de uso de la función `imf_api_function` devolviendo un DataFrame y exportándolo a CSV.

#### Inputs
- **Obligatorios**
  - `dataset_identifier`: identificador del dataset (p. ej., "QNEA").
  - `data_selection`: clave SDMX completa tras la `/` (orden y códigos según el dataset). Ej.: "ESP.B1GQ.Q.SA.XDC.Q" o múltiples países "ESP+FRA.B1GQ.Q.SA.XDC.Q".

- **Opcionales**
  - `filters` (dict): filtros SDMX convertidos a `c[DIM]`. Para varias condiciones use `+`.
  - `agency_identifier`: por defecto "IMF.STA".
  - `dataset_version`: por defecto "+" (última versión).
  - `accept_csv_version`: por defecto "1.0.0".

#### Cómo elegir inputs
1) Localice el dataset y el indicador en el portal del FMI o en la documentación de SDMX.
2) Construya la `key` con las dimensiones requeridas por el dataset.
3) Use `filters` para condiciones adicionales.

#### Sintaxis de la API (FMI SDMX 3.0)
- **Formato general (CSV):**
  ```
  https://api.imf.org/external/sdmx/3.0/data/dataflow/{agency}/{dataset}/{version}/{key}?c[DIM]=...
  ```
  Referencia al servicio SDMX JSON del FMI: `https://dataservices.imf.org/REST/SDMX_JSON.svc`

- **Ejemplo:**
  ```
  https://api.imf.org/external/sdmx/3.0/data/dataflow/IMF.STA/QNEA/+/ESP+FRA.B1GQ.Q.SA.XDC.Q?c[TIME_PERIOD]=ge:2020-Q1
  ```

#### Output
- Un `pandas.DataFrame` con los datos descargados en formato SDMX-CSV.

#### Notas
- Los filtros `c[DIM]` solo aplican a dimensiones que queden comodín en la clave; si fija `COUNTRY` en la clave, `c[COUNTRY]` no surtirá efecto.
- Para seleccionar múltiples países, una forma robusta es ponerlos en la clave con `+` (p. ej., `ESP+FRA....`).

#### Enlaces útiles
- Conocimiento/soporte del FMI (categoría API/SDMX): https://datasupport.imf.org/knowledge?id=knowledge_category&sys_kb_id=d41858e747294ad8805d07c4f16d43e0&category_id=9959b2bc1b6391903dba646fbd4bcb6a


### imf_example.py

```python
from __future__ import annotations

from imf_function import imf_api_function

# Ejemplo: QNEA PIB trimestral SA XDC para España y Francia, 2020-Q1..2020-Q4
df = imf_api_function(
    dataset_identifier="QNEA",
    data_selection="ESP+FRA.B1GQ.Q.SA.XDC.Q",
    filters={
        "TIME_PERIOD": ["ge:2020-Q1", "le:2020-Q4"],
    },
)

df.to_csv("imf_example.csv", index=False)

```

### imf_function.py

```python
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

```

### imf_min.py

```python
from __future__ import annotations

import io
from urllib.parse import quote

import pandas as pd
import requests

# Parámetros básicos (análogos a R/imf/imf_min.R)
base_url = "https://api.imf.org/external/sdmx/3.0/data/dataflow"
agency_identifier = "IMF.STA"
dataset_identifier = "QNEA"
dataset_version = "+"

# Clave SDMX (múltiples países con '+')
data_selection = "ESP+FRA.B1GQ.Q.SA.XDC.Q"

# Filtro de fechas
filters = {
    "TIME_PERIOD": ["ge:2020-Q1", "le:2020-Q4"],
}

# Construcción de URL y query
url = (
    f"{base_url}/"
    f"{agency_identifier}/"
    f"{dataset_identifier}/"
    f"{quote(dataset_version, safe='+*:,/ ,')}/"
    f"{quote(data_selection, safe='+*:,/ ,')}"
)
params = {f"c[{k}]": "+".join(v) for k, v in filters.items()}

headers = {
    "Accept": "application/vnd.sdmx.data+csv;version=1.0.0",
    "Cache-Control": "no-cache",
}

resp = requests.get(url, params=params, headers=headers, timeout=180)
resp.raise_for_status()

df = pd.read_csv(io.StringIO(resp.content.decode("utf-8")))
df.to_csv("imf_min.csv", index=False)

```

### imf_onlylink.py

```python
# Minimal IMF API downloader (link only). Notice is a xml file, not a csv file.
# Requires: pip install pandasdmx
import pandasdmx as sdmx
df = sdmx.read_url("https://api.imf.org/external/sdmx/3.0/data/dataflow/IMF.STA/QNEA/%2B/ESP%2BFRA.B1GQ.Q.SA.XDC.Q").to_pandas()


```

## INE

### Guía rápida: INE JAXIT3 con Python

Este documento explica cómo usar la función en `python/ine/ine_jaxi_function.py` para descargar datos desde la API de INE JAXIT3 en formato CSV y obtenerlos como un `pandas.DataFrame` en Python.

#### Requisitos
- Paquetes: `requests`, `pandas`

#### Codigos ejemplo
- `ine_jaxi_onlylink.py` es un ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `ine_jaxi_min.py` es un ejemplo mínimo que descarga y guarda `ine_jaxi_min.csv`.
- `ine_jaxi_example.py` es un ejemplo de uso de la función `ine_jaxi_api_function`.

#### Inputs
- **Obligatorios**
  - `table_id`: identificador de la tabla INE (p. ej., `"67821"`).

- **Opcionales**
  - `nocab`: `"1"` para evitar cabeceras adicionales (opcional).
  - `directory`: segmento de directorio (por defecto `"t"`).
  - `locale`: idioma del recurso (por defecto `"es"`).
  - `variant`: variante del CSV (por defecto `"csv_bdsc"`).

#### Cómo elegir inputs
1) Vaya a la página de la tabla en INE y copie el identificador (número al final de la URL).
2) Use ese identificador como `table_id`.
3) Ajuste parámetros opcionales (`nocab`, `locale`, `variant`, `directory`) si es necesario.
4) Si necesita cabeceras compactas para procesamiento, mantenga `nocab = "1"`.

#### Sintaxis de la API (INE JAXIT3)
- **Formato general:**
  ```
  https://www.ine.es/jaxiT3/files/{directory}/{locale}/{variant}/{tableId}.csv?nocab={nocab}
  ```
  Donde el Host URL es `https://www.ine.es/jaxiT3/files`.

- **Ejemplo:**
  ```
  https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/67821.csv?nocab=1
  ```

#### Output
- Un `pandas.DataFrame` con los datos descargados desde INE JAXIT3.

#### Notas
- Si la API devuelve error, verifique que el `table_id` exista y sea accesible.
- El CSV se parsea con `pandas.read_csv(..., sep=';', dtype=str)` (todas las columnas como texto).

#### Enlaces útiles
- INE (Banco de datos JAXIT3): https://www.ine.es/


### ine_jaxi_example.py

```python
# Importamos la función y las librerías necesarias
from ine_jaxi_function import ine_jaxi_api_function
import os
from pathlib import Path
import pandas as pd

# Cambiamos el directorio de trabajo a la carpeta de este archivo
os.chdir(os.path.dirname(os.path.abspath(__file__)))
# Llamamos a la función (retorna un pandas DataFrame)
df = ine_jaxi_api_function(
    table_id="67821",
    nocab="1",
    )

# Guardamos el DataFrame en un archivo CSV
df.to_csv("ine_jaxi_example.csv", index=False, sep=";", encoding="utf-8")





```

### ine_jaxi_function.py

```python
import io
from typing import Optional

import requests
import pandas as pd


def ine_jaxi_api_function(
    table_id: str,
    nocab: str = "1",
    directory: str = "t",
    locale: str = "es",
    variant: str = "csv_bdsc",
) -> pd.DataFrame:
    """
    Descarga un archivo CSV de INE JAXIT3 y retorna un pandas DataFrame.

    Parámetros
    ----------
    table_id : str
        Identificador de la tabla INE (p. ej., "67821").
    nocab : str, optional
        Control de cabecera; "1" evita cabeceras adicionales. Por defecto "1".
    directory : str, optional
        Segmento de directorio. Por defecto "t".
    locale : str, optional
        Idioma del recurso. Por defecto "es".
    variant : str, optional
        Variante del CSV. Por defecto "csv_bdsc".

    Retorna
    -------
    pandas.DataFrame
        CSV parseado como un DataFrame con columnas de texto.
    """

    # URL de la API de INE JAXIT3
    base_url = "https://www.ine.es/jaxiT3/files"
    url = f"{base_url}/{directory}/{locale}/{variant}/{table_id}.csv"

    # Parámetros de la petición
    headers = {"Accept": "text/csv"}
    params = {"nocab": nocab}

    # Hacemos la petición
    resp = requests.get(url, headers=headers, params=params, timeout=60)
    try:
        resp.raise_for_status()
    except requests.HTTPError as exc:
        raise RuntimeError(f"INE JAXIT3 request failed [{resp.status_code}]") from exc

    # Parseamos el CSV con pandas
    text_stream = io.StringIO(resp.content.decode("utf-8-sig"))
    df: pd.DataFrame = pd.read_csv(text_stream, sep=";", dtype=str)
    return df



```

### ine_jaxi_min.py

```python
# Descargador mínimo INE JAXIT3 (CSV) — autocontenido (no usa la función)
# ----------------------------------------------------------------------------
# Objetivo
#   Descarga el CSV del INE JAXIT3 con parámetros mínimos y lo guarda
# ----------------------------------------------------------------------------
import os
import requests

# Cambiamos el directorio de trabajo a la carpeta de este archivo
os.chdir(os.path.dirname(os.path.abspath(__file__)))

# Parámetros mínimos
table_id = "67821"  # identificador de la tabla INE (p. ej., "67821")
nocab = "1"         # "1" para evitar cabeceras adicionales

# Construcción de URL y petición
url = f"https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/{table_id}.csv"
params = {"nocab": nocab}
resp = requests.get(url, params=params, headers={"Accept": "text/csv"}, timeout=60)
resp.raise_for_status()

# Guardar contenido en CSV en esta carpeta
with open("ine_jaxi_min.csv", "wb") as f:
    f.write(resp.content)



```

### ine_jaxi_onlylink.py

```python
# Minimal INE JAXIT3 API downloader (link only)
import pandas as pd
df = pd.read_csv("https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/67821.csv?nocab=1")


```

## OECD

### Guía rápida: OECD con Python

Este documento explica cómo usar la función en `python/oecd/oecd_function.py` para descargar datos SDMX de la OCDE en CSV y obtener un `pandas.DataFrame`.

#### Requisitos
- Paquetes: `requests`, `pandas`

#### Codigos ejemplo
- `oecd_onlylink.py` es un ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `oecd_min.py` es un ejemplo mínimo para descargar datos de la OCDE sin usar la función `oecd_api_function`.
- `oecd_example.py` es un ejemplo de uso de la función `oecd_api_function`.

#### Inputs
- **Obligatorios**
  - `agency_identifier`: identificador de la agencia (p. ej., `"OECD.ECO.MAD"`).
  - `dataset_identifier`: identificador del dataset (p. ej., `"DSD_EO@DF_EO"`).
  - `data_selection`: clave SDMX (dimensiones) tras la `/` (p. ej., `"FRA+DEU.PDTY.A"`).

- **Opcionales**
  - `dataset_version`: versión del dataset (p. ej., `""`).
  - `startPeriod`, `endPeriod`, `dimensionAtObservation`: parámetros comunes de consulta.

#### Cómo elegir inputs
1) Buscar el dataset en el explorador OCDE: https://data-explorer.oecd.org/
2) Seleccionar las dimensiones que se quieren descargar y consultar la sección "Developer API" para obtener `Agency identifier`, `Dataset identifier` y `Dataset version`.
3) Construir `data_selection` con las dimensiones requeridas por el dataset (p. ej., `PAISES.VARIABLE.FRECUENCIA`).
4) Ajustar parámetros opcionales (`startPeriod`, `endPeriod`, `dimensionAtObservation`).

#### Sintaxis de la API (OCDE)
- **Formato general:**
  ```
  {Host URL}/{Agency identifier},{Dataset identifier},{Dataset version}/{Data selection}?{otros parámetros}
  ```
  Donde `base_url` por defecto es `https://sdmx.oecd.org/public/rest/data`.

- **Ejemplo:**
  ```
  https://sdmx.oecd.org/public/rest/data/OECD.ECO.MAD,DSD_EO@DF_EO, /FRA+DEU.PDTY.A?startPeriod=1965&endPeriod=2023&dimensionAtObservation=AllDimensions
  ```

#### Output
- Un `pandas.DataFrame` con los datos descargados.

#### Notas
- Si la API devuelve error, verifique que `agency_identifier`, `dataset_identifier` y `data_selection` sean válidos.
- Revise la documentación del dataset para conocer las dimensiones y códigos disponibles.

#### Enlaces útiles
- Explorador OCDE: https://data-explorer.oecd.org/
- Documentación de la API: https://www.oecd.org/en/data/insights/data-explainers/2024/09/api.html


### oecd_example.py

```python
# Ejemplo de uso — OCDE SDMX (CSV)
# ----------------------------------------------------------------------------
# 1) Cargar la función
# 2) Ejecutar la consulta indicando agencia, dataset y selección
# 3) Guardar el resultado como CSV
# ----------------------------------------------------------------------------
import os
from oecd_function import oecd_api_function


def main() -> None:
    # Asegurar rutas relativas coherentes
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Ejecutar la consulta
    df = oecd_api_function(
        agency_identifier="OECD.ECO.MAD",
        dataset_identifier="DSD_EO@DF_EO",
        data_selection="FRA+DEU.PDTY.A",
        startPeriod="1965",
        endPeriod="2023",
        dimensionAtObservation="AllDimensions",
    )

    # Guardar el resultado
    df.to_csv("oecd_example.csv", index=False)


if __name__ == "__main__":
    main()



```

### oecd_function.py

```python
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



```

### oecd_min.py

```python
# Descargador mínimo OCDE SDMX (CSV)
# ----------------------------------------------------------------------------
# Objetivo
#   Descarga datos SDMX de la OCDE y guarda un CSV
# ----------------------------------------------------------------------------
import os
import io
import pandas as pd
import requests


def main() -> None:
    # Cambiar directorio a la carpeta del script para rutas consistentes
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Parámetros
    base_url = "https://sdmx.oecd.org/public/rest/data"
    agency_identifier = "OECD.ECO.MAD"
    dataset_identifier = "DSD_EO@DF_EO"
    dataset_version = ""

    # Construcción de URL y petición
    data_identifier = f"{agency_identifier},{dataset_identifier},{dataset_version}"
    url = f"{base_url}/{data_identifier}/FRA+DEU.PDTY.A"
    params = {
        "startPeriod": "1965",
        "endPeriod": "2023",
        "dimensionAtObservation": "AllDimensions",
    }
    resp = requests.get(url, params=params, headers={"Accept": "text/csv"}, timeout=180)
    resp.raise_for_status()
    text_stream = io.StringIO(resp.content.decode("utf-8"))
    pd.read_csv(text_stream).to_csv("oecd_min.csv", index=False)


if __name__ == "__main__":
    main()



```

### oecd_onlylink.py

```python
# Minimal OECD API downloader (link only)
import pandas as pd
df = pd.read_csv("https://sdmx.oecd.org/public/rest/data/OECD.ECO.MAD,DSD_EO@DF_EO,/FRA+DEU.PDTY.A?format=csvfile&startPeriod=1965&endPeriod=2023")


```

## OURWORLDINDATA

### Guía rápida: Our World in Data con Python

Este documento muestra cómo importar datos directamente desde los gráficos de Our World in Data (OWID) a Python usando `pandas`.

#### Requisitos
- Paquetes: `pandas`, `requests`

#### Codigos ejemplo
- `worldindata_onlylink.py` es un ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `worldindata_min.py` es un ejemplo mínimo para descargar datos de OWID.

#### Inputs
- **Obligatorios**
  - `url`: URL directa del archivo CSV proporcionada por OWID para un gráfico específico.

#### Cómo elegir inputs
1) Vaya a un gráfico en [Our World in Data](https://ourworldindata.org/).
2) Haga clic en la pestaña "Download".
3) Haga clic derecho en el botón de descarga "Full data (CSV)" y seleccione "Copiar dirección del enlace".
4) Use esa URL en su script de Python.

#### Sintaxis de la API
- **Formato general:**
  ```
  https://ourworldindata.org/grapher/{chart-slug}.csv?v=1&csvType=full&useColumnShortNames=true
  ```

- **Ejemplo:**
  ```
  https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.csv?v=1&csvType=full&useColumnShortNames=true
  ```

#### Output
- Un `pandas.DataFrame` con los datos descargados desde OWID.

#### Enlaces útiles
- Portal: https://ourworldindata.org/


### worldindata_min.py

```python
import pandas as pd
import requests
import os

# Fetch the data.
df = pd.read_csv("https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.csv?v=1&csvType=full&useColumnShortNames=true", storage_options = {'User-Agent': 'Our World In Data data fetch/1.0'})

# Fetch the metadata
metadata = requests.get("https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.metadata.json?v=1&csvType=full&useColumnShortNames=true").json()

# Save the data to CSV
output_path = os.path.join(os.path.dirname(__file__), "labor_productivity.csv")
df.to_csv(output_path, index=False)
print(f"Data saved to {output_path}")
```

### worldindata_onlylink.py

```python
# Minimal OurWorldInData downloader (link only)
import pandas as pd
df = pd.read_csv("https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.csv?v=1&csvType=full&useColumnShortNames=true")


```

## WORLDBANK

### Guía rápida: Banco Mundial con Python

Este documento explica cómo usar `python/worldbank/worldbank_function.py` para consultar indicadores del Banco Mundial y obtener un `pandas.DataFrame`.

#### Requisitos
- Paquetes: `requests`, `pandas`

#### Codigos ejemplo
- `worldbank_min.py` es un ejemplo mínimo para descargar datos del Banco Mundial sin usar la función `worldbank_api_function`.
- `worldbank_example.py` es un ejemplo de uso de la función `worldbank_api_function`.

#### Inputs
- **Obligatorios**
  - `iso3`: código(s) de país ISO-3, separados por ';' si son múltiples.
  - `indicator`: código(s) de indicador, separados por ';' si son múltiples.

- **Opcionales**
  - `date`: rango temporal, p. ej., `"2020:2023"`.
  - `per_page`: tamaño de página.

#### Cómo elegir inputs
1) Elija país(es) `iso3` (estándar ISO 3166-1 alpha-3). Puede listar países: https://api.worldbank.org/v2/country?format=json
2) Elegir indicador (`indicator`)
   - Buscar en la web del World Bank la serie de interés. Seleccionar las variables y pinchar en `Metadata` -> `Series`. Copiar el código de la serie. Puede ser una lista de indicadores separados por `;`.
   - Busque indicadores en: https://api.worldbank.org/v2/indicator?format=json (listado paginado) o en el portal de datos del Banco Mundial.
   - También puede abrir un indicador concreto para ver su nombre/meta: https://api.worldbank.org/v2/indicator/NY.GDP.MKTP.KD.ZG?format=json.
3) Rango temporal
   - La API soporta `date=YYYY:YYYY` para filtrar.
   - Si por ejemplo es mensual, sería `date=2012M01:2012M08`.

#### Sintaxis de la API (World Bank)
- **Formato general:**
  ```
  https://api.worldbank.org/v2/country/{ISO3}/indicator/{INDICATOR}?format=json&per_page={N}&date={DATE}
  ```

- **Ejemplo:**
  ```
  https://api.worldbank.org/v2/country/ESP;FRA/indicator/NY.GDP.MKTP.KD.ZG?format=json&per_page=20000&date=2020:2023
  ```

#### Output
- Un `pandas.DataFrame` con el array de datos `[1]` de la respuesta JSON.

#### Enlaces útiles
- Indicadores (API): https://datahelpdesk.worldbank.org/knowledgebase/articles/889392-about-the-indicators-api-documentation
- Estructura de llamadas: https://datahelpdesk.worldbank.org/knowledgebase/articles/898581-api-basic-call-structures
- Países (JSON): https://api.worldbank.org/v2/country?format=json
- Indicadores (JSON): https://api.worldbank.org/v2/indicator?format=json


### worldbank_example.py

```python
import os
# Ejemplo de uso — Banco Mundial (JSON -> DataFrame -> CSV)
# ----------------------------------------------------------------------------
# 1) Cargar la función
# 2) Ejecutar la consulta indicando país(es) e indicador(es)
# 3) Guardar el resultado como CSV
# ----------------------------------------------------------------------------
from worldbank_function import worldbank_api_function


def main() -> None:
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    df = worldbank_api_function(
        iso3="ESP",
        indicator="NY.GDP.MKTP.KD.ZG",
        date="2000:2023",
    )
    df.to_csv("worldbank_example.csv", index=False)


if __name__ == "__main__":
    main()



```

### worldbank_function.py

```python
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



```

### worldbank_min.py

```python
# Descargador mínimo Banco Mundial (JSON -> CSV)
# ----------------------------------------------------------------------------
# Objetivo
#   Consulta indicadores del Banco Mundial y guarda un CSV
# ----------------------------------------------------------------------------
import os
import pandas as pd
import requests


def main() -> None:
    # Cambiar directorio a la carpeta del script para rutas consistentes
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Construcción de URL y petición
    base_url = "https://api.worldbank.org/v2"
    path = "/country/ESP/indicator/NY.GDP.MKTP.KD.ZG"
    url = f"{base_url}{path}"
    params = {"format": "json", "per_page": 20000, "date": "2000:2023"}
    resp = requests.get(url, params=params, headers={"Accept": "application/json"}, timeout=120)
    resp.raise_for_status()
    obj = resp.json()
    if not isinstance(obj, list) or len(obj) < 2 or obj[1] is None:
        raise RuntimeError("Unexpected World Bank response structure; no data array present.")
    pd.DataFrame(obj[1]).to_csv("worldbank_min.csv", index=False)


if __name__ == "__main__":
    main()



```

# R

## COMEXT

### Guía rápida: Eurostat Comext con R

Este documento explica cómo usar la función en `comext/comext_function.R` para descargar datos del endpoint Comext de Eurostat (SDMX‑JSON) y obtenerlos como un data frame etiquetado en R.

#### Requisitos
- Paquetes `httr` y `jsonlite` instalados

#### Codigos ejemplo
- `comext_min.R` es un ejemplo mínimo para descargar datos de Comext y convertirlos a CSV sin usar la función `comext_api_function`.
- `comext_example.R` es un ejemplo de uso de la función `comext_api_function`.

#### Inputs
- **Obligatorios**
  - `dataset_id`: identificador del dataset Comext (prefijo `"DS-"`, p. ej., `"DS-059341"`).
  - `filters`: lista NOMBRADA de filtros (dimensión -> valores). Los nombres deben ser las dimensiones válidas del dataset (p. ej., `reporter`, `partner`, `product`, `flow`, `freq`, `time`, `indicators`, ...). Los valores pueden ser `"string"` o vectores `c("...","...")`.

#### Cómo elegir inputs
1) Identifique el dataset en la guía de Comext y el portal de Eurostat.
2) Consulte la estructura del dataset en la guía Comext para conocer las dimensiones válidas y sus valores.
3) Ajuste `filters` con nombres de dimensiones válidos. Para múltiples valores use vectores.

#### Sintaxis de la API (Comext statistics)
- **Formato general:**
  ```
  https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/{dataset_id}?reporter=...&partner=...&product=...&flow=...&freq=...&time=...
  ```

- **Ejemplo:**
  ```
  https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/DS-059341?reporter=ES&partner=US&product=1509&product=8703&flow=2&freq=A&time=2015&time=2016&...&time=2020
  ```

#### Output
- Un `data.frame` con columnas por dimensión (códigos y `*_label`) y la columna `value`.

#### Funcion auxiliar para convertir JSON a data frame
La funcion `comext_json_to_labeled_df` es una funcion auxiliar para convertir el JSON a un data frame con columnas por dimensión (códigos y `*_label`) y la columna `value`.

#### Enlaces útiles
- Guía de Comext: https://ec.europa.eu/eurostat/web/user-guides/data-browser/api-data-access/api-getting-started/comext-database
- Portal Eurostat: https://ec.europa.eu/eurostat/


### comext_example.R

```R
# Ejemplo de uso de la función comext_api_function
library(httr)
library(jsonlite)

#setwd("comext")
source("comext_function.R")

# Ejemplo de uso
df <- comext_api_function(
  dataset_id = "DS-059341",
  filters = list(
    reporter = c("ES"),
    partner  = c("US"),
    product  = c("1509", "8703"),
    flow     = c("2"),
    freq     = c("A"),
    time     = 2015:2020
  )
)

write.csv(df, "comext_example.csv", row.names = FALSE)



```

### comext_function.R

```R
# Función para descargar y etiquetar datos de Eurostat COMEXT (JSON -> data.frame)

# Inputs obligatorios:
# - dataset_id: id del dataset Comext (p. ej., "DS-059341")
# - filters: lista nombrada (dimension -> valores). Los nombres deben ser las
#            dimensiones válidas del dataset (p. ej., reporter, partner, product,
#            flow, freq, time, indicators, etc.). Los valores pueden ser string o
#            vector de strings. Para multiselección se envían parámetros repetidos.
#
# Output:
# - df: data.frame con códigos por dimensión, etiquetas *_label y la columna numeric 'value'

comext_api_function <- function(
  dataset_id,
  filters
) {
  base <- paste0("https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/", dataset_id)

  if (missing(filters) || is.null(filters)) stop("'filters' debe ser una lista nombrada dimension -> valores")
  if (!is.list(filters) || is.null(names(filters)) || any(names(filters) == "")) {
    stop("'filters' debe ser una lista NOMBRADA: names(filters) son las dimensiones")
  }

  # Construye query string con parámetros repetidos para multiselección
  q <- list()
  for (dim_name in names(filters)) {
    values <- filters[[dim_name]]
    if (is.null(values)) next
    values <- as.character(values)
    for (v in values) {
      q <- c(q, setNames(list(v), dim_name))
    }
  }

  res <- httr::GET(base, query = q, httr::accept("application/json"))
  if (httr::http_error(res)) stop(sprintf("COMEXT request failed [%s]", httr::status_code(res)))

  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  doc <- jsonlite::fromJSON(txt, simplifyVector = FALSE)

  # utilidades locales (o usar scripts/comext_utils.R según la organización)
  if (!exists("comext_json_to_labeled_df")) source("comext_utils.R")
  df <- comext_json_to_labeled_df(doc)
  return(df)
}



```

### comext_min.R

```R
# Descargador Eurostat COMEXT (CSV con etiquetas por dimensión)
# ----------------------------------------------------------------------------
# Objetivo
#   Descarga datos del endpoint Comext (Eurostat) en formato JSON y los convierte a un CSV "largo" con columnas
# ----------------------------------------------------------------------------

library(httr)
library(jsonlite)

# Carga utilidades locales
source("comext_utils.R")

# --- Parámetros editables -----------------------------------------------------
# ID del dataset Comext (prefijo DS-)
dataset_id <- "DS-059341"

# Dimensiones (aceptan vectores). Se enviarán como parámetros repetidos.
reporter <- c("ES")
partner  <- c("US")
product  <- c("1509", "8703")
flow     <- c("2")
freq     <- c("A")
time     <- 2015:2020

# Salida
output_name <- "comext_ejemplo"
out_file <- paste0("data/", output_name, ".csv")

# --- Construcción de la query-string ----------------------------------------
add_multi <- function(q, name, values) {
  if (length(values) == 0) return(q)
  for (v in as.character(values)) q <- c(q, setNames(list(v), name))
  q
}

q <- list()
q <- add_multi(q, "reporter", reporter)
q <- add_multi(q, "partner",  partner)
q <- add_multi(q, "product",  product)
q <- add_multi(q, "flow",     flow)
q <- add_multi(q, "freq",     freq)
q <- add_multi(q, "time",     time)

if (!dir.exists("data")) dir.create("data", recursive = TRUE, showWarnings = FALSE)

# --- Construcción de URL y parámetros ----------------------------------------
base <- paste0("https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/", dataset_id)

# --- Petición HTTP y parseo --------------------------------------------------
res <- httr::GET(base, query = q, httr::accept("application/json"))
if (httr::http_error(res)) stop(sprintf("COMEXT request failed [%s]", httr::status_code(res)))

txt <- httr::content(res, as = "text", encoding = "UTF-8")
doc <- jsonlite::fromJSON(txt, simplifyVector = FALSE)

df <- comext_json_to_labeled_df(doc)

utils::write.csv(df, out_file, row.names = FALSE, na = "")



```

### comext_utils.R

```R
# Utilidades COMEXT: conversión de JSON (SDMX-like) a data.frame etiquetado
# Copiado desde `scripts/comext_utils.R` para uso local en la carpeta `comext/`.

comext_json_to_labeled_df <- function(doc) {
  vals <- doc$value
  if (is.null(vals) || length(vals) == 0) return(data.frame())

  ids <- doc$id
  sizes <- as.integer(unlist(doc$size))
  dims <- doc$dimension
  n_dims <- length(ids)

  get_strides <- function(sz) {
    n <- length(sz)
    s <- integer(n)
    for (k in seq_len(n)) s[k] <- if (k == n) 1 else prod(sz[(k + 1):n])
    s
  }
  strides <- get_strides(sizes)

  pos_to_code <- function(index_map, pos) {
    codes <- names(index_map)[which(unname(index_map) == pos)]
    if (length(codes) == 0) return(NA_character_)
    codes[[1]]
  }

  value_keys <- as.integer(names(vals))
  value_vals <- as.numeric(unlist(vals, use.names = FALSE))

  make_row <- function(i) {
    idx <- value_keys[[i]]
    r <- idx
    pos <- integer(n_dims)
    for (k in seq_len(n_dims)) { pos[k] <- r %/% strides[k]; r <- r %% strides[k] }

    rec <- list(value = value_vals[[i]])
    for (k in seq_along(ids)) {
      dn <- ids[[k]]
      d <- dims[[dn]]; if (is.null(d)) next
      imap <- unlist(d$category$index)
      lbl  <- d$category$label
      code_k <- pos_to_code(imap, pos[k])
      rec[[dn]] <- code_k
      rec[[paste0(dn, "_label")]] <- if (!is.null(lbl) && !is.null(code_k)) lbl[[code_k]] else NA_character_
    }
    as.data.frame(rec, stringsAsFactors = FALSE)
  }

  rows <- lapply(seq_along(value_keys), make_row)
  df <- do.call(rbind, rows)
  if ("value" %in% names(df)) df$value <- as.numeric(df$value)
  df
}



```

## ECB

### Guía rápida: BCE con R 

Este documento explica cómo usar la función en `ecb/ecb_function.R` para descargar una serie del BCE (dataset SDMX) en formato CSV y obtenerla como un data frame en R.

#### Requisitos
- Paquete `httr` instalado (`install.packages("httr")` si fuera necesario)


#### Codigos ejemplo 
- `ecb_onlylink.R` es un ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `ecb_min.R` es un ejemplo mínimo para descargar datos del BCE sin usar la función `ecb_api_function`.
- `ecb_example.R` es un ejemplo de uso de la función `ecb_api_function`.

#### Inputs
  - `dataset`: identificador del dataset del BCE (p. ej., `"BSI"`). Vease los datasets disponibles en https://data.ecb.europa.eu/data/datasets/
  - `seriesKey`: clave completa de la serie (dimensiones concatenadas con `.`).


#### Cómo elegir inputs
1) Abra el dataset en el portal BCE (p. ej., BSI): https://data.ecb.europa.eu/data/datasets/BSI
2) Use los filtros hasta ver la serie concreta; la clave `seriesKey` aparece en el recuadro de la serie.
3) Cada elemento de `seriesKey` es una dimensión del dataset; puede cambiar `U2` (Área del euro) por `ES` (España), etc. Pinchando en `view all` se pueden ver todas las dimensiones del dataset y sus codigos. Para conocer que valores puede tomar una dimensión, vease https://data.ecb.europa.eu/data/datasets/PAY/structure.

#### Sintaxis de la URL de la API (BCE)
- **Formato general:**
  ```
  https://data-api.ecb.europa.eu/service/data/{dataset}/{seriesKey}?format=csvdata
  ```

- **Ejemplo:**
  ```
  https://data-api.ecb.europa.eu/service/data/BSI/M.U2.Y.V.M30.X.I.U2.2300.Z01.A?format=csvdata
  ```


#### Output
- Un `data.frame` con los datos descargados desde el BCE.


#### Enlaces útiles
- Portal de datos del BCE (datasets): https://data.ecb.europa.eu/data/datasets/
- Documentación de la API de datos del BCE: https://data.ecb.europa.eu/help/api/overview
- Estructura de los codigos de las dimensiones: https://data.ecb.europa.eu/data/datasets/PAY/structure
- API de datos (servicio): https://data-api.ecb.europa.eu/service/




### ecb_example.R

```R
# Ejemplo de uso de la función ecb_api_function
library(httr)

#setwd("ecb")
source("ecb_function.R")

# Ejemplo de uso
df <- ecb_api_function(
  dataset = "BSI",
  seriesKey = "M.U2.Y.V.M30.X.I.U2.2300.Z01.A"
)

write.csv(df, "ecb_example.csv", row.names = FALSE)



```

### ecb_function.R

```R
# Función mínima BCE Data API (CSV)

# Inputs obligatorios:
# - dataset: identificador del dataset (p. ej., "BSI")
# - seriesKey: clave completa de la serie (dimensiones concatenadas con '.')
#
# Inputs opcionales:
# - base_url: host del servicio de datos del BCE
#
# Output:
# - df: data.frame con los datos descargados

ecb_api_function <- function(
  dataset,
  seriesKey,
  base_url = "https://data-api.ecb.europa.eu/service/data"
) {
  url <- paste0(base_url, "/", dataset, "/", seriesKey)
  res <- httr::GET(url, query = list(format = "csvdata"), httr::accept("text/csv"))
  if (httr::http_error(res)) stop(sprintf("ECB request failed [%s]", httr::status_code(res)))

  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  df <- utils::read.csv(text = txt, stringsAsFactors = FALSE)
  return(df)
}



```

### ecb_min.R

```R
# Minimal ECB Data API downloader (CSV)
#
# How to customize:
# - Change dataset (BSI) and seriesKey for the specific series
# - Change out_file to control the output file name

library(httr)

# --- Editable parameters ---
dataset <- "BSI"  # ECB dataset id
seriesKey <- "M.U2.Y.V.M30.X.I.U2.2300.Z01.A"
output_name <- "ecb_ejemplo"
out_file <- paste0("data/ecb_", gsub("[./]", "_", output_name), ".csv")

# --- Crear directorio de datos si no existe ---
if (!dir.exists("data")) dir.create("data", recursive = TRUE, showWarnings = FALSE)

# --- Descargar archivo CSV ---
url <- paste0("https://data-api.ecb.europa.eu/service/data/", dataset, "/", seriesKey)
res <- httr::GET(url, query = list(format = "csvdata"), httr::accept("text/csv"))
if (httr::http_error(res)) stop(sprintf("ECB request failed [%s]", httr::status_code(res)))
writeBin(httr::content(res, as = "raw"), out_file)



```

### ecb_onlylink.R

```R
# Minimal ECB Data API downloader (link only)
df <- read.csv("https://data-api.ecb.europa.eu/service/data/BSI/M.U2.Y.V.M30.X.I.U2.2300.Z01.A?format=csvdata")


```

## ESIOS

### Guía rápida: REE e·sios con R

Este documento explica cómo usar la función en `esios/esios_function.R` para descargar valores de indicadores del portal e·sios de Red Eléctrica (REE) y obtenerlos como un data frame en R.

#### Requisitos
- Paquetes `httr` y `jsonlite` instalados
- Token personal de e·sios en la variable de entorno `ESIOS_TOKEN`

#### Codigos ejemplo
- `esios_min.R`: script mínimo que guarda CSV usando parámetros básicos.
- `esios_example.R`: ejemplo práctico con promedio diario nacional del último mes.
- `esios_list_indicators.R`: listado completo de indicadores y metadatos.

#### Inputs
- **Obligatorios**
  - `indicator_id`: id numérico del indicador (p. ej., `10211`).
  - `start_date`, `end_date`: fechas en ISO8601 con zona Z (ej.: `2025-01-01T00:00:00Z`).

- **Opcionales**
  - `time_agg`: agregación temporal ("sum" o "avg").
  - `time_trunc`: recorte temporal ("five_minutes", "ten_minutes", "fifteen_minutes", "hour", "day", "month", "year").
  - `geo_agg`: agregación por geografía ("sum" o "avg").
  - `geo_trunc`: nivel geográfico ("country", "electric_system", "autonomous_community", "province", "electric_subsystem", "town", "drainage_basin").
  - `geo_ids`: vector de ids geográficos (se envía como parámetros repetidos `geo_ids[]`).
  - `locale`: idioma de respuesta ("es" o "en").
  - `token`: API key (por defecto lee `Sys.getenv("ESIOS_TOKEN")`).

#### Cómo elegir inputs
1) Hay dos opciones para el `indicator_id`:
   - Descargandose el listado de indicadores y metadatos con `esios_list_indicators.R`.
   - Buscando en la web con la herramienta interactiva. Una vez seleccionada la serie, puedes descargar el CSV y el id está en la primera columna.
2) Para los otros parámetros, consulte la documentación oficial si tiene dudas.

#### Output
- Un `data.frame` con los valores del indicador. La función normaliza la respuesta leyendo `indicator$values` (o `values`) y convierte la columna `value` a numérica cuando procede.

#### Clave API
- Para conseguir la API hay que escribir un mail a consultasios@ree.es solicitando un token.
- Una vez obtenida la clave, debes establecerla como variable de entorno `ESIOS_TOKEN` antes de ejecutar. Ejemplo en R:
  ```r
  Sys.setenv(ESIOS_TOKEN = "SU_TOKEN_AQUI")
  ```

#### Enlaces útiles
- Portal y catálogo de endpoints: https://api.esios.ree.es/
- Ejemplo de parámetros/aggregaciones de indicadores: https://api.esios.ree.es/doc/indicator/getting_a_disaggregated_indicator_filtering_values_by_a_date_range_and_geo_ids,_grouped_by_geo_id_and_month,_using_avg_aggregation_for_geo_and_avg_for_time_without_time_trunc.html


### esios_example.R

```R
# Ejemplo de uso de la función esios_api_function
library(httr)
library(jsonlite)

#setwd("R/esios")
source("esios_function.R")

# Ejemplo: precio medio horario final (suma de componentes) id=10211
# Objetivo: promedio nacional por día del último mes

# Clave API
token <- Sys.getenv("ESIOS_TOKEN")

# Fechas ISO8601 (UTC)
end_date_date <- Sys.Date()
start_date_date <- end_date_date - 30
start_date <- paste0(format(start_date_date, "%Y-%m-%d"), "T00:00:00Z")
end_date   <- paste0(format(end_date_date, "%Y-%m-%d"), "T23:59:59Z")

df <- esios_api_function(
  indicator_id = 10211,
  start_date = start_date,
  end_date = end_date,
  time_agg = "avg",
  time_trunc = "day",
  geo_agg = "avg",
  geo_trunc = "country",
  locale = "es"
)

write.csv(df, "esios_example.csv", row.names = FALSE)





```

### esios_function.R

```R
# Función mínima para descargar indicadores de REE e·sios (JSON -> data.frame)

library(httr)
library(jsonlite)

# esios_api_function: descarga valores de un indicador con filtros comunes
# - indicator_id: id numérico del indicador (p. ej., 1001, 10211)
# - start_date, end_date: ISO8601 ("YYYY-MM-DDTHH:MM:SSZ")
# - time_agg: "sum"|"avg"
# - time_trunc: "five_minutes"|"ten_minutes"|"fifteen_minutes"|"hour"|"day"|"month"|"year"
# - geo_agg: "sum"|"avg"
# - geo_trunc: "country"|"electric_system"|"autonomous_community"|"province"|"electric_subsystem"|"town"|"drainage_basin"
# - geo_ids: vector opcional de ids geográficos (num/char)
# - locale: "es"|"en"
# - token: por defecto toma Sys.getenv("ESIOS_TOKEN")

esios_api_function <- function(
  indicator_id,
  start_date,
  end_date,
  time_agg = NULL,
  time_trunc = NULL,
  geo_agg = NULL,
  geo_trunc = NULL,
  geo_ids = NULL,
  locale = "es",
  token = Sys.getenv("ESIOS_TOKEN")
) {
  if (missing(indicator_id)) stop("'indicator_id' es obligatorio")
  if (missing(start_date) || missing(end_date)) stop("'start_date' y 'end_date' son obligatorios (ISO8601)")
  if (!nzchar(token)) stop("Defina su token en la variable de entorno ESIOS_TOKEN o páselo en 'token'")

  base_url <- paste0("https://api.esios.ree.es/indicators/", indicator_id)

  # Construcción de parámetros
  q <- list(start_date = start_date, end_date = end_date)
  if (!is.null(time_agg))   q$time_agg <- match.arg(tolower(time_agg), c("sum","avg","average"))
  if (!is.null(time_trunc)) q$time_trunc <- match.arg(tolower(time_trunc), c("five_minutes","ten_minutes","fifteen_minutes","hour","day","month","year"))
  if (!is.null(geo_agg))    q$geo_agg <- match.arg(tolower(geo_agg), c("sum","avg","average"))
  if (!is.null(geo_trunc))  q$geo_trunc <- match.arg(tolower(geo_trunc), c("country","electric_system","autonomous_community","province","electric_subsystem","town","drainage_basin"))
  if (!is.null(geo_ids) && length(geo_ids)) {
    # Repetir parámetro geo_ids[] por cada valor
    for (g in as.character(geo_ids)) q <- c(q, setNames(list(g), "geo_ids[]"))
  }

  hdrs <- httr::add_headers(
    "x-api-key" = token,
    "Accept" = "application/json; application/vnd.esios-api-v1+json",
    "Accept-Language" = locale,
    "Content-Type" = "application/json"
  )

  res <- httr::GET(base_url, query = q, hdrs)
  if (httr::http_error(res)) stop(sprintf("ESIOS request failed [%s]", httr::status_code(res)))

  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  obj <- jsonlite::fromJSON(txt, flatten = TRUE)

  # Normalizar: valores suelen venir en indicator$values
  values_df <- NULL
  if (!is.null(obj$indicator$values)) {
    values_df <- obj$indicator$values
  } else if (!is.null(obj$values)) {
    values_df <- obj$values
  } else {
    stop("Estructura de respuesta inesperada; no se encontró 'indicator.values'.")
  }
  if ("value" %in% names(values_df)) values_df$value <- suppressWarnings(as.numeric(values_df$value))
  return(values_df)
}



```

### esios_list_indicators.R

```R
# Listado de indicadores ESIOS (JSON -> CSV)

library(httr)
library(jsonlite)

# --- Parámetros ---
output_name <- "esios_indicators"
out_file <- paste0( output_name, ".csv")

# Requiere token en variable de entorno ESIOS_TOKEN
Sys.setenv(ESIOS_TOKEN = "c9957840f6e4bbdc76f4958cd33676cc1f97665758a55b21ea006a5fbbd660b3")
token <- Sys.getenv("ESIOS_TOKEN")
if (!nzchar(token)) stop("Defina su token en la variable de entorno ESIOS_TOKEN")

# --- Llamada a API: listado de indicadores ---
base_url <- "https://api.esios.ree.es/indicators"
hdrs <- httr::add_headers(
  "x-api-key" = token,
  "Accept" = "application/json",
  "Accept-Language" = "es",
  "Content-Type" = "application/json"
)

res <- httr::GET(base_url, query = list(locale = "es"), hdrs)
if (httr::http_error(res)) stop(sprintf("ESIOS request failed [%s]", httr::status_code(res)))

txt <- httr::content(res, as = "text", encoding = "UTF-8")
obj <- jsonlite::fromJSON(txt, flatten = TRUE)

indicators_df <- NULL
if (!is.null(obj$indicators)) {
  indicators_df <- obj$indicators
} else if (!is.null(obj$data$indicators)) {
  indicators_df <- obj$data$indicators
} else {
  stop("Estructura de respuesta inesperada; no se encontró 'indicators'.")
}

utils::write.csv(indicators_df, out_file, row.names = FALSE, na = "")



```

### esios_min.R

```R
# Descargador mínimo REE e·sios (JSON -> CSV)
#
# Cómo personalizar:
# - Defina el ID del indicador en 'indicator_id' (por defecto: precio spot OMIE)
# - Cambie 'output_name' para definir el nombre del archivo de salida (CSV)
# - Exporte su token personal en la variable de entorno ESIOS_TOKEN
#
# Referencia API:
# - Documentación general: https://www.esios.ree.es/es/pagina/api
# - Endpoints v2: https://api.esios.ree.es/

library(httr)
library(jsonlite)

# --- Parámetros editables ---
# Indicador de precio Precio medio horario final suma de componentes
indicator_id <- 10211
output_name <- "esios_precio_hoy"
out_file <- paste0("data/", output_name, ".csv")
token <- Sys.getenv("ESIOS_TOKEN")
# --- Crear directorio de datos si no existe ---
if (!dir.exists("data")) dir.create("data", recursive = TRUE, showWarnings = FALSE)

# --- Fechas: último mes (UTC) ---
end_date_date <- Sys.Date()
start_date_date <- end_date_date - 30
start_date <- paste0(format(start_date_date, "%Y-%m-%d"), "T00:00:00Z")
end_date   <- paste0(format(end_date_date, "%Y-%m-%d"), "T23:59:59Z")

# --- Descargar JSON ---
base_url <- paste0("https://api.esios.ree.es/indicators/", indicator_id)
hdrs <- httr::add_headers(
  "x-api-key" = token,
  "Accept" = "application/json",
  "Accept-Language" = "es",
  "Content-Type" = "application/json"
)

res <- httr::GET(
  base_url,
  query = list(
    start_date = start_date,
    end_date = end_date,
    time_agg = "avg",
    time_trunc = "day",
    geo_agg = "avg",
    geo_trunc = "country"
  ),
  hdrs
)
if (httr::http_error(res)) stop(sprintf("ESIOS request failed [%s]", httr::status_code(res)))

txt <- httr::content(res, as = "text", encoding = "UTF-8")
obj <- jsonlite::fromJSON(txt, flatten = TRUE)

# La estructura típica es obj$indicator$values
values_df <- NULL
if (!is.null(obj$indicator$values)) {
  values_df <- obj$indicator$values
} else if (!is.null(obj$values)) {
  values_df <- obj$values
} else {
  stop("Estructura de respuesta inesperada; no se encontró 'indicator.values'.")
}

# Coaccionar 'value' a numérico si existe
if ("value" %in% names(values_df)) values_df$value <- suppressWarnings(as.numeric(values_df$value))

utils::write.csv(values_df, out_file, row.names = FALSE, na = "")



```

## EUROSTAT

### Guía rápida: Eurostat con R

Este documento explica cómo usar la función en `eurostat/eurostat_function.R` para descargar datos de la API SDMX 3.0 de Eurostat en formato CSV (SDMX-CSV 2.0) y obtenerlos como un data frame en R.

#### Requisitos
- Paquete `httr` instalado (`install.packages("httr")` si fuera necesario)

#### Codigos ejemplo
- `eurostat_onlylink.R` es un ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `eurostat_min.R` es un ejemplo minimo para descargar datos de Eurostat sin usar la función `eurostat_api_function`.
- `eurostat_example.R` es un ejemplo de uso de la función `eurostat_api_function`.

#### Inputs
- **Obligatorios**
  - `dataset_identifier`: identificador del dataset (p. ej., `"nama_10_a64"`).
  - `filters`: lista nombrada de filtros SDMX. Tiene que tener formato `list(dim1 = c("val1", "val2"), dim2 = "val3", ...)`.

- **Opcionales**
  - `agency_identifier`: agencia mantenedora (por defecto `"ESTAT"`).
  - `dataset_version`: versión del dataset (por defecto `"1.0"`).
  - `compress`: `"false"` para CSV legible.
  - `format`/`formatVersion`: para SDMX-CSV 2.0 use `"csvdata"` + `"2.0"`.
  - `lang`: idioma de etiquetas (`"en"`, etc.).
  - `labels`: `"id"` (solo codigos), `"name"` (descripciones y codigos), `"both"` (ambos).

#### Cómo elegir inputs
1) Lo más sencillo es ir a Eurostat, buscar la serie de interés y copiar el codigo de la serie. Mirar el codigo de las variables que nos interesan y los codigos de los valores que queremos filtrar.
2) Usar el codigo de la serie como `dataset_identifier`.
3) Ajustar filtros (`filters`).
   - Añada o cambie dimensiones válidas del dataset (p. ej., `geo`, `na_item`, `unit`, `freq`, `TIME_PERIOD`).
   - Para valores múltiples use vectores en R: `c("ES", "FR")`.
   - En `TIME_PERIOD` puede usar operadores SDMX: `ge:YYYY`, `le:YYYY`, `YYYY:YYYY`, `ge:200Q1`, etc.
4) Cambiar parametros opcionales si es necesario.

#### Sintaxis de la API (SDMX 3.0)
- **Formato general:**
  ```
  {base_url}/{agency_identifier}/{dataset_identifier}/{dataset_version}/?{filters_params}&{common_params}
  ```
  Donde `base_url` es `https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow`.

- **Ejemplo:**
  ```
  https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/ESTAT/nama_10_a64/1.0/?c[geo]=ES,FR&c[na_item]=B1G,P1&c[freq]=A&c[unit]=CLV20_MEUR&c[TIME_PERIOD]=ge:1995&compress=false&format=csvdata&formatVersion=2.0&lang=en&labels=name
  ```

#### Output
- Un `data.frame` con los datos descargados desde Eurostat.

#### Notas
- Si la API devuelve error, verifique que los códigos de dimensiones/valores sean válidos para el dataset escogido.
- `labels = "id"` devuelve códigos; `labels = "name"` devuelve descripciones legibles; `"both"` incluye ambos.

#### Enlaces útiles
- Guía de consultas de datos (SDMX 3.0, Eurostat): [API - Detailed guidelines - SDMX3.0 API - data query](https://ec.europa.eu/eurostat/web/user-guides/data-browser/api-data-access/api-detailed-guidelines/sdmx3-0/data-query)
- [API - Getting started with statistics API - Retrieving your first content](https://ec.europa.eu/eurostat/web/user-guides/data-browser/api-data-access/api-getting-started/api#APIGettingstartedwithstatisticsAPI-Retrievingyourfirstcontent)
- https://ec.europa.eu/eurostat/web/query-builder/tool


### eurostat_example.R

```R
# Ejemplo de uso de la función eurostat_api_function
library(httr)

#setwd("R/eurostat")
source("eurostat_function_check.R")

# Ejemplo de uso with check function
df <- eurostat_api_function_check(
  dataset_identifier = "nama_10_a64",
  filters = list(
    geo = c("IT"),
    na_item = c("B1G"),
    unit = "CLV20_MEUR",
    TIME_PERIOD = "ge:1995"
  ),
  toc_path = "table_of_contents_en.txt"
)

# Ejemplo de uso
#df <- eurostat_api_function(
#  dataset_identifier = "nama_10_a64",
#  filters = list(
#    geo = c("IT"),
#    na_item = c("B1G"),
#    unit = "CLV20_MEUR",
#    TIME_PERIOD = "ge:1995"
#  )
#)
#write.csv(df, "eurostat_example.csv", row.names = FALSE)
```

### eurostat_function.R

```R
# Función mínima para descargar datos de Eurostat (SDMX-CSV 2.0)

# Inputs obligatorios:
# - dataset_identifier: identificador del dataset
# - filters: lista de filtros
#
# Inputs opcionales:
# - agency_identifier: identificador de la agencia
# - dataset_version: versión del dataset
# - compress: compresión
# - format: formato
# - formatVersion: versión del formato
# - lang: idioma
# - labels: etiquetas
#
# Outputs:
# - df: data frame con los datos
#
# Example:
# df <- eurostat_api_function(
#   dataset_identifier = "nama_10_a64",
#   filters = list(geo = c("IT"), na_item = c("B1G"), unit = "CLV20_MEUR", TIME_PERIOD = "ge:1995")
# )

eurostat_api_function <- function(
  dataset_identifier,
  filters,
  agency_identifier = "ESTAT",
  dataset_version = "1.0",
  compress = "false",
  format = "csvdata",
  formatVersion = "2.0",
  lang = "en",
  labels = "name"
) {
  base_url <- "https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow"

  # Construir identificador completo: context/agency/dataset/version
  data_identifier <- paste(agency_identifier, dataset_identifier, dataset_version, sep = "/")
  url <- paste0(base_url, "/", data_identifier, "/")

  # Convertir filtros a parámetros tipo c[dimension]=valor1,valor2
  if (!is.list(filters)) stop("'filters' debe ser una lista nombrada de dimensiones -> valores")
  filters_params <- stats::setNames(
    lapply(filters, function(v) if (length(v) > 1) paste(v, collapse = ",") else v),
    paste0("c[", names(filters), "]")
  )

  common_params <- list(
    compress = compress,
    format = format,
    formatVersion = formatVersion,
    lang = lang,
    labels = labels
  )

  params <- c(filters_params, common_params)

  res <- httr::GET(url, query = params, httr::accept("application/vnd.sdmx.data+csv; version=2.0.0"))
  if (httr::http_error(res)) stop(sprintf("Eurostat request failed [%s]", httr::status_code(res)))

  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  df <- utils::read.csv(text = txt, stringsAsFactors = FALSE)

  return(df)
}

```

### eurostat_function_check.R

```R
# Función mínima para descargar datos de Eurostat (SDMX-CSV 2.0)

# Inputs obligatorios:
# - dataset_identifier: identificador del dataset
# - filters: lista de filtros
#
# Inputs opcionales:
# - agency_identifier: identificador de la agencia
# - dataset_version: versión del dataset
# - compress: compresión
# - format: formato
# - formatVersion: versión del formato
# - lang: idioma
# - labels: etiquetas
#
# Outputs:
# - df: data frame con los datos
#
# Example:
# df <- eurostat_api_function(
#   dataset_identifier = "nama_10_a64",
#   filters = list(geo = c("IT"), na_item = c("B1G"), unit = "CLV20_MEUR", TIME_PERIOD = "ge:1995")
# )

eurostat_api_function_check <- function(
  dataset_identifier,
  filters,
  agency_identifier = "ESTAT",
  dataset_version = "1.0",
  compress = "false",
  format = "csvdata",
  formatVersion = "2.0",
  lang = "en",
  labels = "name",
  toc_path = NULL
) {
  # Endpoints (SDMX 3.0)
  # Eurostat CSV 2.0 data endpoint (works with path including 'dataflow')
  data_endpoint_base <- "https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow"
  # Nota: validación por metadatos deshabilitada en modo local; mantener solo endpoint de datos

  # -----------------------
  # Validaciones de entrada
  # -----------------------
  if (!is.character(dataset_identifier) || length(dataset_identifier) != 1 || nchar(dataset_identifier) == 0) {
    stop("'dataset_identifier' debe ser un string no vacío", call. = FALSE)
  }
  if (!is.list(filters) || is.null(names(filters)) || any(names(filters) == "")) {
    stop("'filters' debe ser una lista NOMBRADA: lista(dimension = valores)", call. = FALSE)
  }
  # Validar tipos de valores de filtros y que no haya NA/NULL
  bad_filter_values <- names(Filter(function(v) {
    is.null(v) || length(v) == 0 || any(is.na(v)) || !(is.character(v) || is.numeric(v) || is.logical(v))
  }, filters))
  if (length(bad_filter_values) > 0) {
    stop(sprintf(
      "Los siguientes filtros tienen valores inválidos: %s. Use vectores de character/numeric/logical sin NA.",
      paste(bad_filter_values, collapse = ", ")
    ), call. = FALSE)
  }

  # -----------------------------------------
  # Verificar existencia del dataset (local TOC solamente)
  # -----------------------------------------
  # Validación local usando ÚNICAMENTE table_of_contents_en.txt (TSV)
  if (is.null(toc_path)) {
    toc_candidates <- c(
      "table_of_contents_en.txt",
      file.path(getwd(), "table_of_contents_en.txt")
    )
    toc_candidates <- unique(toc_candidates)
    for (cand in toc_candidates) {
      if (file.exists(cand)) { toc_path <- cand; break }
    }
  }
  if (is.null(toc_path) || !file.exists(toc_path)) {
    stop("No se encontró 'table_of_contents_en.txt'. Especifique 'toc_path' apuntando a ese archivo.", call. = FALSE)
  }
  # Archivo TSV: columnas incluyen "code"
  toc_df <- try(utils::read.delim(toc_path, sep = "\t", header = TRUE, quote = '"', stringsAsFactors = FALSE, check.names = FALSE), silent = TRUE)
  if (!inherits(toc_df, "try-error") && is.data.frame(toc_df) && "code" %in% names(toc_df)) {
    if (!any(toc_df$code == dataset_identifier, na.rm = TRUE)) {
      stop(sprintf(
        "Dataset no encontrado en table_of_contents_en.txt: id='%s'. Verifique el identificador localmente o actualice el TOC.",
        dataset_identifier
      ), call. = FALSE)
    }
  } else {
    # Fallback simple: búsqueda de la cadena con comillas
    toc_txt <- try(readLines(toc_path, warn = FALSE), silent = TRUE)
    if (!inherits(toc_txt, "try-error") && length(toc_txt) > 0) {
      needle <- paste0('"', dataset_identifier, '"')
      if (!any(grepl(needle, toc_txt, fixed = TRUE))) {
        stop(sprintf(
          "Dataset no encontrado en table_of_contents_en.txt: id='%s'.",
          dataset_identifier
        ), call. = FALSE)
      }
    }
  }

  # No usar validación por metadatos ni DSD cuando se solicita local-only: elegimos versión suministrada
  chosen_version <- dataset_version

  # -----------------------------------------
  # Construcción de la petición de datos (CSV 2.0)
  # Nota: mantenemos el endpoint actual usado en la función original
  # -----------------------------------------
  data_identifier <- paste(agency_identifier, dataset_identifier, chosen_version, sep = "/")
  url <- paste0(data_endpoint_base, "/", data_identifier, "/")

  # Convertir filtros a parámetros tipo c[dimension]=valor1,valor2
  filters_params <- stats::setNames(
    lapply(filters, function(v) if (length(v) > 1) paste(v, collapse = ",") else v),
    paste0("c[", names(filters), "]")
  )

  common_params <- list(
    compress = compress,
    format = format,
    formatVersion = formatVersion,
    lang = lang,
    labels = labels
  )

  params <- c(filters_params, common_params)

  res <- try(httr::GET(url, query = params, httr::accept("application/vnd.sdmx.data+csv; version=2.0.0"), httr::timeout(30)), silent = TRUE)
  if (inherits(res, "try-error") || is.null(res)) {
    stop("No se pudo conectar al endpoint de datos de Eurostat. Revise su conexión.", call. = FALSE)
  }
  if (httr::http_error(res)) {
    status_code <- httr::status_code(res)
    body_txt <- try(httr::content(res, as = "text", encoding = "UTF-8"), silent = TRUE)
    body_snippet <- if (!inherits(body_txt, "try-error") && nzchar(body_txt)) substr(body_txt, 1, 500) else ""

    hint <- switch(as.character(status_code),
      "400" = "Solicitud inválida: verifique nombres de dimensiones y formato de filtros.",
      "404" = "No se encontraron datos: verifique 'dataset_identifier' o que los filtros no sean contradictorios.",
      "406" = "No aceptable: verifique el encabezado Accept (CSV 2.0) o parámetros 'format/formatVersion'.",
      "413" = "Respuesta demasiado grande: refine los filtros para limitar el volumen.",
      NULL
    )

    base_msg <- sprintf("Eurostat devolvió error [HTTP %s]", status_code)
    if (!is.null(hint)) base_msg <- paste(base_msg, "-", hint)
    if (nzchar(body_snippet)) base_msg <- paste0(base_msg, ". Detalle: ", body_snippet)
    stop(base_msg, call. = FALSE)
  }

  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  if (!nzchar(txt)) {
    stop("Respuesta vacía recibida del servicio de datos de Eurostat.", call. = FALSE)
  }
  df <- utils::read.csv(text = txt, stringsAsFactors = FALSE)

  if (nrow(df) == 0) {
    stop(
      "La respuesta no contiene filas. Es probable que los filtros sean demasiado restrictivos o no coincidan con códigos válidos.",
      call. = FALSE
    )
  }

  return(df)
}

```

### eurostat_min.R

```R
# Descargador mínimo de Eurostat (CSV)
#
# Cómo personalizar:
# - Cambiar dataset_identifier por el codigo de la serie de interés.
# - Cambiar filters para seleccionar las dimensiones de la serie de interés. Si no queremos filtrar, no incluimos la variable en la lista.

library(httr)

# --- Parámetros editables ---
# Identificadores de dataset
  base_url <- "https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow" # Endpoint SDMX 3.0 de Eurostat
  agency_identifier <- "ESTAT"
  dataset_identifier <- "nama_10_a64"
  dataset_version <- "1.0"

# Filtros (modificar libremente)
  filters <- list(
    geo = c("ES", "FR"),
    na_item = c("B1G", "P1"),
    unit = "CLV20_MEUR",
    TIME_PERIOD = "ge:1995"
  )

# Parámetros comunes de salida (SDMX-CSV 2.0)
  common_params <- list(
    compress = "false",
    format = "csvdata",
    formatVersion = "2.0",
    lang = "en",
    labels = "name"
  )

# Nombre del archivo de salida
  output_name <- "eurostat_ejemplo"
  out_file <- paste0("data/", output_name, ".csv")


# -- Construir la URL ---
# Construir ruta completa (context/agency/dataset/version)
  data_identifier <- paste(agency_identifier, dataset_identifier, dataset_version, sep = "/")
  url <- paste0(base_url, "/", data_identifier, "/")
# Convertir filtros a parámetros tipo c[...]=
  filters_params <- setNames(
    lapply(filters, function(v) if (length(v) > 1) paste(v, collapse = ",") else v),
    paste0("c[", names(filters), "]")
  )
  params <- c(filters_params, common_params)

# --- Crear directorio de datos si no existe ---
if (!dir.exists("data")) dir.create("data", recursive = TRUE, showWarnings = FALSE)

# --- Descargar archivo CSV and store in a data frame---
res <- httr::GET(url, query = params, httr::accept("application/vnd.sdmx.data+csv; version=2.0.0"))
if (httr::http_error(res)) stop(sprintf("Eurostat request failed [%s]", httr::status_code(res)))
txt <- httr::content(res, as = "text", encoding = "UTF-8")
df <- read.csv(text = txt, stringsAsFactors = FALSE)
utils::write.csv(df, out_file, row.names = FALSE, na = "")

```

### eurostat_onlylink.R

```R
# Minimal Eurostat API downloader (link only)
df <- read.csv("https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/ESTAT/nama_10_a64/1.0/?c[geo]=ES,FR&c[na_item]=B1G,P1&c[unit]=CLV20_MEUR&c[TIME_PERIOD]=ge:1995&compress=false&format=csvdata&formatVersion=2.0&lang=en&labels=name")


```

## FRED

### Guía rápida: FRED con R

Este documento explica cómo usar las funciones en `fred_function.R` para descargar datos desde FRED.

#### Requisitos
- Paquetes `httr` y `jsonlite` instalados

#### Codigos ejemplo
- `fred_onlylink.R` es un ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `fred_min.R` es un ejemplo mínimo que descarga un CSV de fredgraph sin usar la función.
- `fred_example.R` es un ejemplo de uso de ambas funciones (`fredgraph_api_function` y `fred_api_function`).

#### Inputs
- **fredgraph_api_function**
  - `graphId` (Obligatorio): identificador del gráfico compartido en FRED.

- **fred_api_function**
  - `series_id` (Obligatorio): identificador de la serie (p. ej., `"GDP"`).
  - Opcionales: `observation_start`, `observation_end`, `realtime_start`, `realtime_end`, `limit`, `offset`, `sort_order`, `units`, `frequency`, `aggregation_method`, `output_type`, `vintage_dates`, `api_key`.

#### Cómo elegir inputs
- Para `fredgraph_api_function`:
  - Obtenga `graphId` desde el enlace compartido del gráfico (parámetro `?g=` en la URL).

- Para `fred_api_function`:
  1) Elija `series_id` (p. ej., `GDP`, esto suele estar al lado del nombre de la serie en FRED entre paréntesis).
  2) Defina `FRED_API_KEY` como variable de entorno o pásela como argumento.
  3) Si es necesario, cambie los otros parámetros opcionales.

#### Sintaxis de la API
- **fredgraph CSV:**
  ```
  https://fred.stlouisfed.org/graph/fredgraph.csv?g={graphId}
  ```
- **API v1 observaciones:**
  ```
  https://api.stlouisfed.org/fred/series/observations?series_id={id}&api_key=...&file_type=json
  ```

#### Output
- `data.frame` con las observaciones devueltas por cada método.

#### Parámetros detallados (fred_api_function)
- `series_id`: p. ej., `GDP`, `CPIAUCSL`.
- `observation_start / observation_end`: formato `YYYY-MM-DD`.
- `realtime_start / realtime_end`: ventana de tiempo real.
- `limit`, `offset`: para paginación.
- `sort_order`: `"asc"` o `"desc"`.
- `units`: `"lin"`, `"chg"`, `"ch1"`, `"pch"`, `"pc1"`, `"pca"`, `"cch"`, `"cca"`, `"log"`.
- `frequency`: `"d"`, `"w"`, `"bw"`, `"m"`, `"q"`, `"sa"`, `"a"`, etc.
- `aggregation_method`: `"avg"`, `"sum"`, `"eop"`.
- `output_type`: `1` (realtime), `2` (vintages), `3` (new/revised), `4` (initial).
- `vintage_dates`: fechas separadas por comas.

#### Como conseguir una API key
- Regístrese en FRED, vaya a "API keys" y solicite una key.
- Alternativa: use `fredgraph_api_function` que no requiere key.

#### Enlaces útiles
- Referencia oficial: [FRED observations API docs](https://fred.stlouisfed.org/docs/api/fred/series_observations.html)


### fred_example.R

```R
# Ejemplos de uso de funciones FRED
library(httr)
library(jsonlite)

#setwd("fred")
source("fred_function.R")

# 1) fredgraph (no API key)
df_graph <- fredgraph_api_function(graphId = "1wmdD")
write.csv(df_graph, "fred_graph_example.csv", row.names = FALSE)

# 2) API v1 (requiere FRED_API_KEY)
 Sys.setenv(FRED_API_KEY = "28ee932ab037f5486dae766aebf0bec3")
df_api <- fred_api_function(series_id = "GDP", observation_start = NULL, observation_end = NULL)
write.csv(df_api, "fred_api_example.csv", row.names = FALSE)

# 2a) API v1 con parametros
df_parameters <- fred_api_function(series_id='CPIAUCSL', observation_start='2015-01-01', units='pc1', frequency='m', aggregation_method='avg', sort_order='desc', limit=5)

write.csv(df_parameters, 'fred_api_example_params.csv', row.names=FALSE)
```

### fred_function.R

```R
# Funciones para descargar datos de FRED

# 1) Método fredgraph (no requiere API key) -> CSV directo de un gráfico compartido
fredgraph_api_function <- function(graphId) {
  url <- "https://fred.stlouisfed.org/graph/fredgraph.csv"
  res <- httr::GET(url, query = list(g = graphId), httr::accept("text/csv"))
  if (httr::http_error(res)) stop(sprintf("FRED fredgraph request failed [%s]", httr::status_code(res)))
  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  df <- utils::read.csv(text = txt, stringsAsFactors = FALSE)
  return(df)
}

# 2) Método API v1 (requiere variable de entorno FRED_API_KEY) -> JSON con observaciones
fred_api_function <- function(
  series_id,
  observation_start = NULL,
  observation_end = NULL,
  realtime_start = NULL,
  realtime_end = NULL,
  limit = NULL,
  offset = NULL,
  sort_order = c("asc", "desc"),
  units = NULL,
  frequency = NULL,
  aggregation_method = NULL,
  output_type = NULL,
  vintage_dates = NULL,
  api_key = Sys.getenv("FRED_API_KEY", unset = NA_character_)
) {
  if (is.na(api_key) || api_key == "") stop("Defina la variable de entorno FRED_API_KEY para usar fred_api_function.")

  # Validaciones ligeras según documentación oficial
  if (!is.null(units)) {
    allowed_units <- c("lin", "chg", "ch1", "pch", "pc1", "pca", "cch", "cca", "log")
    if (!units %in% allowed_units) stop(sprintf("Valor de 'units' no válido: %s", units))
  }
  if (!is.null(frequency)) {
    allowed_freq <- c("d","w","bw","m","q","sa","a","wef","weth","wew","wetu","wem","wesu","wesa","bwew","bwem")
    if (!frequency %in% allowed_freq) stop(sprintf("Valor de 'frequency' no válido: %s", frequency))
  }
  if (!is.null(aggregation_method)) {
    allowed_agg <- c("avg","sum","eop")
    if (!aggregation_method %in% allowed_agg) stop(sprintf("Valor de 'aggregation_method' no válido: %s", aggregation_method))
  }
  if (!is.null(output_type)) {
    output_type <- as.integer(output_type)
    if (!output_type %in% c(1L,2L,3L,4L)) stop(sprintf("Valor de 'output_type' no válido: %s", output_type))
  }
  sort_order <- match.arg(sort_order)

  url <- "https://api.stlouisfed.org/fred/series/observations"
  q <- list(
    series_id = series_id,
    api_key = api_key,
    file_type = "json"
  )
  if (!is.null(observation_start)) q$observation_start <- observation_start
  if (!is.null(observation_end)) q$observation_end <- observation_end
  if (!is.null(realtime_start)) q$realtime_start <- realtime_start
  if (!is.null(realtime_end)) q$realtime_end <- realtime_end
  if (!is.null(limit)) q$limit <- limit
  if (!is.null(offset)) q$offset <- offset
  if (!is.null(sort_order)) q$sort_order <- sort_order
  if (!is.null(units)) q$units <- units
  if (!is.null(frequency)) q$frequency <- frequency
  if (!is.null(aggregation_method)) q$aggregation_method <- aggregation_method
  if (!is.null(output_type)) q$output_type <- output_type
  if (!is.null(vintage_dates)) q$vintage_dates <- vintage_dates

  res <- httr::GET(url, query = q, httr::accept("application/json"))
  if (httr::http_error(res)) stop(sprintf("FRED API request failed [%s]", httr::status_code(res)))
  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  obj <- jsonlite::fromJSON(txt, flatten = TRUE)
  if (is.null(obj$observations)) stop("Estructura inesperada de la API de FRED; falta 'observations'.")
  return(obj$observations)
}



```

### fred_min.R

```R
# Descargador mínimo FRED (fredgraph CSV)
#
# Cómo personalizar:
# - Cambie 'graphId' por el identificador del gráfico compartido en FRED
# - Cambie 'out_file' para definir el nombre del archivo de salida (CSV)

library(httr)

# --- Parámetros editables ---
graphId <- "1wmdD"
output_name <- "fred_graph_ejemplo"
out_file <- paste0("data/", output_name, ".csv")

# --- Crear directorio de datos si no existe ---
if (!dir.exists("data")) dir.create("data", recursive = TRUE, showWarnings = FALSE)

# --- Descargar archivo CSV ---
url <- "https://fred.stlouisfed.org/graph/fredgraph.csv"
res <- httr::GET(url, query = list(g = graphId), httr::accept("text/csv"))
if (httr::http_error(res)) stop(sprintf("FRED fredgraph request failed [%s]", httr::status_code(res)))
writeBin(httr::content(res, as = "raw"), out_file)



```

### fred_onlylink.R

```R
# Minimal FRED API downloader (link only)
df <- read.csv("https://fred.stlouisfed.org/graph/fredgraph.csv?g=1wmdD")


```

## IMF

### Guía rápida: FMI con R

Este documento explica cómo usar la función en `imf/imf_function.R` para descargar datos del FMI (servicio SDMX-JSON CompactData) y obtenerlos como un data frame en R.

#### Requisitos
- Paquetes `httr` y `jsonlite` instalados

#### Codigos ejemplo
- `imf_onlylink.R`: ejemplo que descarga y lee el csv directamente del link de la API en una linea (usando `rsdmx`).
- `imf_min.R`: ejemplo mínimo que descarga y guarda CSV sin usar la función `imf_api_function`.
- `imf_example.R`: ejemplo de uso de la función `imf_api_function` y guardado de CSV.

#### Inputs
- **Obligatorios**
  - `dataset`: identificador del dataset SDMX del FMI, p. ej., "IFS" (International Financial Statistics).
  - `key`: clave SDMX con dimensiones concatenadas por punto `.`. El patrón típico en IFS es `Frecuencia.País.Indicador` (p. ej., "M.ES.PCPI_IX").

- **Opcionales**
  - `startPeriod`, `endPeriod`: límites de periodo (p. ej., "2018", "2023").

#### Cómo elegir inputs
1) Localice el dataset y el indicador en el portal del FMI o en la documentación de SDMX.
2) Construya la `key` con las dimensiones requeridas por el dataset. En IFS suele ser `FREQ.REF_AREA.INDICATOR`.
3) Use `startPeriod` y `endPeriod` para acotar el periodo temporal si lo necesita.

#### Sintaxis de la API (FMI SDMX CompactData)
- **Formato general:**
  ```
  https://api.imf.org/external/sdmx/3.0/data/{context}/{agencyID}/{resourceID}/{version}/{key}[?c][&updatedAfter][&firstNObservations][&lastNObservations][&dimensionAtObservation][&attributes][&measures][&includeHistory][&asOf]
  ```
  Referencia al servicio SDMX JSON del FMI: `https://dataservices.imf.org/REST/SDMX_JSON.svc`

#### Output
- Un `data.frame` con columnas de dimensiones devueltas por la serie (por ejemplo `FREQ`, `REF_AREA`, `INDICATOR` si están presentes en la respuesta), más `TIME_PERIOD` y `OBS_VALUE`.

#### Enlaces útiles
- Conocimiento/soporte del FMI (categoría API/SDMX): https://datasupport.imf.org/knowledge?id=knowledge_category&sys_kb_id=d41858e747294ad8805d07c4f16d43e0&category_id=9959b2bc1b6391903dba646fbd4bcb6a
 

### imf_example.R

```R
# Ejemplo de uso de la función imf_sdmx3_api_function
# Cómo personalizar:
# - Cambiar agency_identifier, dataset_identifier y dataset_version para seleccionar el dataset.
# - Cambiar data_selection para seleccionar las dimensiones del dataset. Buscar los datos en la web de IMF. Pinchar en ver el id de los valores y remplazar en el orden que aparecen las variables.
# - Cambiar filter_date para seleccionar las fechas del dataset.
# - Cambiar params para seleccionar los parámetros de la consulta.
# - Cambiar output_name para definir el nombre del archivo de salida.

setwd("R/imf")
library(httr)

# Asegurar ruta correcta al ejecutar desde la raíz del repo
source("imf_function.R")

# Ejemplo: PIB trimestral SA, precios corrientes (XDC) para España y Francia desde 2020-Q1 a 2020-Q4
df <- imf_api_function(
  dataset_identifier = "QNEA",
  data_selection = "ESP+FRA.B1GQ.Q.SA.XDC.Q",
  filters = list(
    TIME_PERIOD = c("ge:2020-Q1", "le:2020-Q4")
  )
)

utils::write.csv(df, "imf_example.csv", row.names = FALSE)



```

### imf_function.R

```R
# Función mínima para descargar datos del FMI (SDMX 3.0 → SDMX-CSV 1.0)
# Inspirada en eurostat_function.R, usando el flujo de imf_min.R
#
# Inputs obligatorios:
# - dataset_identifier: identificador del dataset (p. ej., "QNEA")
# - data_selection: clave SDMX (orden y códigos según el dataset), p. ej.,
#   "ESP.B1GQ.Q.SA.XDC.Q" o con múltiples países "ESP+FRA.B1GQ.Q.SA.XDC.Q".
#
# Inputs opcionales:
# - agency_identifier: p. ej., "IMF.STA"
# - dataset_version: p. ej., "+" (última versión)
# - filters: lista de filtros SDMX como c[TIME_PERIOD] = "ge:2020-Q1+le:2020-Q4".
#            Páselos como list(TIME_PERIOD = c("ge:2020-Q1","le:2020-Q4"))
#            Se convertirán a query params tipo c[TIME_PERIOD]="ge:...+le:...".
# - accept_csv_version: versión del formato SDMX-CSV (por defecto "1.0.0")
#
# Output:
# - data.frame leído de la respuesta CSV

imf_api_function <- function(
  dataset_identifier,
  data_selection,
  filters = list(),
  agency_identifier = "IMF.STA",
  dataset_version = "+",
  accept_csv_version = "1.0.0"
) {
  base_url <- "https://api.imf.org/external/sdmx/3.0/data/dataflow"

  # Construir ruta completa: {base}/{agency}/{dataset}/{version}/{key}
  # Codificamos cuidadosamente la versión ('+' -> %2B) y la clave
  url <- paste0(
    base_url, "/",
    agency_identifier, "/",
    dataset_identifier, "/",
    utils::URLencode(dataset_version, reserved = TRUE), "/",
    utils::URLencode(data_selection, reserved = TRUE)
  )

  # Construir filtros como c[DIM]=v1+v2 (TIME_PERIOD ge/le, etc.)
  if (!is.list(filters)) stop("'filters' debe ser una lista nombrada de dimensiones -> valores")
  filter_params <- list()
  if (length(filters)) {
    for (nm in names(filters)) {
      vals <- filters[[nm]]
      if (is.null(vals) || length(vals) == 0) next
      # Join con '+' (IMF acepta ge:...+le:... y múltiples valores con '+')
      filter_params[[paste0("c[", nm, "]")]] <- paste(vals, collapse = "+")
    }
  }

  headers <- httr::add_headers(
    `Cache-Control` = "no-cache",
    Accept = paste0("application/vnd.sdmx.data+csv;version=", accept_csv_version)
  )

  res <- httr::GET(url, query = filter_params, headers, httr::config(ssl_verifypeer = 0L, ssl_verifyhost = 0L))
  if (httr::http_error(res)) stop(sprintf("IMF request failed [%s]", httr::status_code(res)))

  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  df <- utils::read.csv(text = txt, stringsAsFactors = FALSE)
  return(df)
}



```

### imf_min.R

```R
## Descargador mínimo de IMF SDMX 3.0 (CSV)
# Cómo personalizar:
# - Cambiar agency_identifier, dataset_identifier y dataset_version para seleccionar el dataset.
# - Cambiar data_selection para seleccionar las dimensiones del dataset. Buscar los datos en la web de IMF. Pinchar en ver el id de los valores y remplazar en el orden que aparecen las variables.
# - Cambiar filter_date para seleccionar las fechas del dataset.
# - Cambiar params para seleccionar los parámetros de la consulta.
# - Cambiar output_name para definir el nombre del archivo de salida.

library(httr)

#setwd("R/imf")
#Request
#https://api.imf.org/external/sdmx/3.0/data/{context}/{agencyID}/{resourceID}/{version}/{key}[?c][&updatedAfter][&firstNObservations][&lastNObservations][&dimensionAtObservation][&attributes][&measures][&includeHistory][&asOf]

########################################################
# --- Parámetros editables ---
########################################################
# URL base de la API
base_url <- "https://api.imf.org/external/sdmx/3.0/data/dataflow/"

# Identificadores de dataset
agency_identifier <- "IMF.STA"
dataset_identifier <- "QNEA"
dataset_version <- "+"                       # '+' for latest version

# Variables de la consulta (separar por + varios valores o usar '*')
# Use el key para filtrar país(es) y evite c[COUNTRY] si el servidor lo ignora
data_selection <- "ESP+FRA.B1GQ.Q.SA.XDC.Q"      # COUNTRY.INDICATOR.PRICE_TYPE.S_ADJUSTMENT.TYPE_OF_TRANSFORMATION.FREQUENCY

# Filtro de fecha (puede contener múltiples condiciones unidas con '+')
# Ejemplo mensual: ge:2020-01+le:2020-12
# Ejemplo trimestral: ge:2020-Q1+le:2020-Q4
filter_date <- list(
  TIME_PERIOD = c("ge:2020-Q1", "le:2020-Q4"))

# Parametros de la consulta
params <- list(
  dimensionAtObservation = "TIME_PERIOD",  # At the observation level
  attributes = "dsd",                      # Data Structure Definition
  measures = "all",                        # All measures
  includeHistory = "false"                 # No history
)

# Nombre del archivo de salida
output_name <- "imf_min.csv"

########################################################
# -- Construir la URL y query ---
########################################################
# -- Construir la URL ---
full_url <- paste0(
  base_url,
  agency_identifier, "/",
  dataset_identifier, "/",
  utils::URLencode(dataset_version, reserved = TRUE), "/",
  utils::URLencode(data_selection, reserved = TRUE)
)

# -- Construir la query ---
query <- params
if (length(filter_date)) {
  for (nm in names(filter_date)) {
    vals <- filter_date[[nm]]
    if (is.null(vals) || length(vals) == 0) next
    query[[sprintf("c[%s]", nm)]] <- paste(vals, collapse = "+")
  }
}

# -- Construir los headers ---
headers <- httr::add_headers(
  `Cache-Control` = "no-cache",
  Accept = "application/vnd.sdmx.data+csv;version=1.0.0, text/csv"
)

########################################################
# -- Hacer la petición ---
########################################################
res <- httr::GET(full_url, query = query, headers, httr::config(ssl_verifypeer = 0L, ssl_verifyhost = 0L))
httr::stop_for_status(res)

########################################################
# -- Guardar el resultado ---
########################################################
txt <- httr::content(res, as = "text", encoding = "UTF-8")
df <- read.csv(text = txt, stringsAsFactors = FALSE)
utils::write.csv(df, output_name, row.names = FALSE, na = "")




```

### imf_onlylink.R

```R
# Minimal IMF API downloader (link only). Notice is a xml file, not a csv file.
# Requires: install.packages("rsdmx")
library(rsdmx)
# Disable SSL verification for this session if you encounter certificate errors
httr::set_config(httr::config(ssl_verifypeer = 0L, ssl_verifyhost = 0L))
df <- as.data.frame(readSDMX("https://api.imf.org/external/sdmx/3.0/data/dataflow/IMF.STA/QNEA/%2B/ESP%2BFRA.B1GQ.Q.SA.XDC.Q"))



```

## INE

### Guía rápida: INE JAXIT3 con R

Este documento explica cómo usar la función en `ine/ine_jaxi_function.R` para descargar datos desde la API de INE JAXIT3 en formato CSV y obtenerlos como un data frame en R.

#### Requisitos
- Paquete `httr` instalado (`install.packages("httr")` si fuera necesario)

#### Codigos ejemplo
- `ine_jaxi_onlylink.R` es un ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `ine_jaxi_min.R` es un ejemplo mínimo para descargar datos del INE sin usar la función `ine_jaxi_api_function`.
- `ine_jaxi_example.R` es un ejemplo de uso de la función `ine_jaxi_api_function`.

#### Inputs
- **Obligatorios**
  - `tableId`: identificador de la tabla INE (p. ej., `"67821"`).

- **Opcionales**
  - `nocab`: `"1"` para evitar cabeceras adicionales (recomendado).
  - `directory`: segmento de directorio (por defecto `"t"`).
  - `locale`: idioma del recurso (por defecto `"es"`).
  - `variant`: variante del CSV (por defecto `"csv_bdsc"`).

#### Cómo elegir inputs
1) Vaya a la página de la tabla en INE y copie el identificador (número al final de la URL).
2) Use ese identificador como `tableId`.
3) Ajuste parámetros opcionales (`nocab`, `locale`, `variant`, `directory`) si es necesario.
4) Si necesita cabeceras compactas para procesamiento, mantenga `nocab = "1"`.

#### Sintaxis de la API (INE JAXIT3)
- **Formato general:**
  ```
  https://www.ine.es/jaxiT3/files/{directory}/{locale}/{variant}/{tableId}.csv?nocab={nocab}
  ```
  Donde el Host URL es `https://www.ine.es/jaxiT3/files`.

- **Ejemplo:**
  ```
  https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/67821.csv?nocab=1
  ```

#### Output
- Un `data.frame` con los datos descargados desde INE JAXIT3.

#### Notas
- Si la API devuelve error, verifique que el `tableId` exista y sea accesible.

#### Enlaces útiles
- INE (Banco de datos JAXIT3): https://www.ine.es/


### ine_jaxi_example.R

```R
# Ejemplo de uso de la función ine_jaxi_api_function
library(httr)

#setwd("ine")
source("ine_jaxi_function.R")

# Ejemplo de uso
df <- ine_jaxi_api_function(
  tableId = "67821",
  nocab = "1"
)

write.csv(df, "ine_jaxi_example.csv", row.names = FALSE)



```

### ine_jaxi_function.R

```R
# Función mínima para descargar datos INE JAXIT3 (CSV)

# Inputs obligatorios:
# - tableId: identificador de la tabla INE (p.ej., "67821")
#
# Inputs opcionales:
# - nocab: controla cabecera ("1" evita cabeceras adicionales)
# - directory: segmento de directorio (por defecto "t")
# - locale: idioma (por defecto "es")
# - variant: variante de CSV (por defecto "csv_bdsc")
#
# Output:
# - df: data.frame con los datos descargados

ine_jaxi_api_function <- function(
  tableId,
  nocab = "1",
  directory = "t",
  locale = "es",
  variant = "csv_bdsc"
) {
  base_url <- "https://www.ine.es/jaxiT3/files"
  url <- paste0(base_url, "/", directory, "/", locale, "/", variant, "/", tableId, ".csv")

  res <- httr::GET(url, query = list(nocab = nocab), httr::accept("text/csv"))
  if (httr::http_error(res)) stop(sprintf("INE JAXIT3 request failed [%s]", httr::status_code(res)))

  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  df <- utils::read.csv(text = txt, stringsAsFactors = FALSE, sep = ";")
  return(df)
}



```

### ine_jaxi_min.R

```R
# Descargador mínimo INE JAXIT3 (CSV)
#
# Cómo personalizar:
# - Cambie 'tableId' por la tabla objetivo. 
# - Mantenga o quite 'nocab=1' según si desea cabeceras sin etiquetas
# - Cambie 'out_file' para definir el nombre del archivo de salida

library(httr)

# --- Parámetros editables ---
tableId <- "67821"      # Ejemplo de ID de tabla (el numero al final de la url en ine.es)
nocab <- "1"            # "1" para evitar cabeceras adicionales
output_name <- "ine_ejemplo"

# --- Crear directorio de datos si no existe ---
out_file <- paste0("data/", output_name, ".csv")
if (!dir.exists("data")) dir.create("data", recursive = TRUE, showWarnings = FALSE)

# --- Descargar archivo CSV ---
url <- paste0("https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/", tableId, ".csv")
res <- httr::GET(url, query = list(nocab = nocab), httr::accept("text/csv"))
if (httr::http_error(res)) stop(sprintf("INE JAXIT3 request failed [%s]", httr::status_code(res)))
writeBin(httr::content(res, as = "raw"), out_file)



```

### ine_jaxi_onlylink.R

```R
# Minimal INE JAXIT3 API downloader (link only)
df <- read.csv("https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/67821.csv?nocab=1", encoding = "UTF-8")


```

## INEAPIR


<!-- README.md is generated from README.Rmd. Please edit that file -->

### ineapir <img src="man/figures/hex_logo.png" align="right" width = "120" alt = "ineapir logo"/>

<!-- badges: start -->

[![R-CMD-check](https://github.com/es-ine/ineapir/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/es-ine/ineapir/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

#### Overview

ineapir provides a set of functions to obtain open data and metadata
published by the National Statistics Institute of Spain
([INE](https://www.ine.es/en/index.htm)). The data is obtained thanks to
calls to the INE API service which allows access via URL requests to the
available statistical information published by INE.

#### Installation

Install the released version of **ineapir** from CRAN:

``` r
install.packages("ineapir")
```

To install the development version of **ineapir** from GitHub:

``` r
remotes::install_github("es-ine/ineapir")
```

Alternatively, you can download the source code as a zip file and then
install it as follows:

``` r
remotes::install_local(path = "path/to/file.zip")
```

#### Cheatsheet

<a href="https://raw.githubusercontent.com/es-ine/ineapir/main/man/figures/ineapir.pdf"><img src="man/figures/ineapir_thumbnail.png" width="315" alt = "Cheatsheet"/></a>

#### Data request examples

The data is only associated with the series object and these can be
grouped together into statistical tables. The field named ‘*Valor*’ is
the only one that contains data. The rest of the fields are necessary
for the data to be well defined.

##### Obtaining data from a table

To get all the data of a table it is necessary to pass the `idTable`
argument, which is the identification code of the table, to the function
`get_data_table()`.

``` r
library(ineapir)

# We use the function get_data_table with the argument idTable
# and the argument tip = 'A' for a more friendly output
table <- get_data_table(idTable = 50902, tip = "A")

# Each row represents a series
table[1,c("COD", "Nombre")]
#>         COD                                   Nombre
#> 1 IPC251852 Total Nacional. Índice general. Índice.

# The Data column contains a data frame for each row with the values 
# of the different periods of each series
head(table$Data[[1]])
#>                           Fecha T3_TipoDato T3_Periodo Anyo   Valor
#> 1 2025-07-01T00:00:00.000+02:00  Definitivo        M07 2025 118.777
#> 2 2025-06-01T00:00:00.000+02:00  Definitivo        M06 2025 118.867
#> 3 2025-05-01T00:00:00.000+02:00  Definitivo        M05 2025 118.077
#> 4 2025-04-01T00:00:00.000+02:00  Definitivo        M04 2025 117.997
#> 5 2025-03-01T00:00:00.000+01:00  Definitivo        M03 2025 117.260
#> 6 2025-02-01T00:00:00.000+01:00  Definitivo        M02 2025 117.191

# We can concatenate all data frames into one using unnest = TRUE
table <- get_data_table(idTable = 50902, tip = "A", unnest = TRUE)
head(table[,c("COD", "Nombre", "Fecha", "Valor")])
#>           COD                                   Nombre
#> 1   IPC251852 Total Nacional. Índice general. Índice. 
#> 1.1 IPC251852 Total Nacional. Índice general. Índice. 
#> 1.2 IPC251852 Total Nacional. Índice general. Índice. 
#> 1.3 IPC251852 Total Nacional. Índice general. Índice. 
#> 1.4 IPC251852 Total Nacional. Índice general. Índice. 
#> 1.5 IPC251852 Total Nacional. Índice general. Índice. 
#>                             Fecha   Valor
#> 1   2025-07-01T00:00:00.000+02:00 118.777
#> 1.1 2025-06-01T00:00:00.000+02:00 118.867
#> 1.2 2025-05-01T00:00:00.000+02:00 118.077
#> 1.3 2025-04-01T00:00:00.000+02:00 117.997
#> 1.4 2025-03-01T00:00:00.000+01:00 117.260
#> 1.5 2025-02-01T00:00:00.000+01:00 117.191
```

To get the last n data from a table it is necessary to pass the `nlast`
argument as well.

``` r
# We use the function get_data_table with arguments idTable and nlast
table <- get_data_table(idTable = 50902, nlast = 2)
table[1,c("COD", "Nombre")]
#>         COD                                   Nombre
#> 1 IPC251852 Total Nacional. Índice general. Índice.
head(table$Data[[1]])
#>          Fecha FK_TipoDato FK_Periodo Anyo   Valor Secreto
#> 1 1.751321e+12           1          7 2025 118.777   FALSE
```

##### Obtaining data from a series

To get the last data of a series it is necessary to pass the `codSeries`
argument, which is the identification code of the series, to the
function `get_data_series()`.

``` r
# We use the function get_data_series with the argument codSeries
series <- get_data_series(codSeries = "IPC251856", tip = "A")
series$Data
#>                           Fecha T3_TipoDato T3_Periodo Anyo Valor
#> 1 2025-08-01T00:00:00.000+02:00      Avance        M08 2025   2.7
```

To get the last n data from a series it is necessary to pass the `nlast`
argument as well.

``` r
# We use the function get_data_series with arguments codSeries and nlast
series <- get_data_series(codSeries = "IPC251856", tip = "A", nlast = 5)
series$Data
#>                           Fecha T3_TipoDato T3_Periodo Anyo Valor
#> 1 2025-04-01T00:00:00.000+02:00  Definitivo        M04 2025   2.2
#> 2 2025-05-01T00:00:00.000+02:00  Definitivo        M05 2025   2.0
#> 3 2025-06-01T00:00:00.000+02:00  Definitivo        M06 2025   2.3
#> 4 2025-07-01T00:00:00.000+02:00  Definitivo        M07 2025   2.7
#> 5 2025-08-01T00:00:00.000+02:00      Avance        M08 2025   2.7

# Using unnest = TRUE
series <- get_data_series(codSeries = "IPC251856", tip = "A", nlast = 5,
                          unnest = TRUE)
head(series[,c("COD", "Nombre", "Fecha", "Valor")])
#>           COD                                            Nombre
#> 1   IPC251856 Total Nacional. Índice general. Variación anual. 
#> 1.1 IPC251856 Total Nacional. Índice general. Variación anual. 
#> 1.2 IPC251856 Total Nacional. Índice general. Variación anual. 
#> 1.3 IPC251856 Total Nacional. Índice general. Variación anual. 
#> 1.4 IPC251856 Total Nacional. Índice general. Variación anual. 
#>                             Fecha Valor
#> 1   2025-04-01T00:00:00.000+02:00   2.2
#> 1.1 2025-05-01T00:00:00.000+02:00   2.0
#> 1.2 2025-06-01T00:00:00.000+02:00   2.3
#> 1.3 2025-07-01T00:00:00.000+02:00   2.7
#> 1.4 2025-08-01T00:00:00.000+02:00   2.7
```

Additionally, it is possible to obtain data from a series between two
dates. The date must have and specific format (*yyyy/mm/dd*). If the end
date is not specified we obtain all the data from the start date.

``` r
# We use the function get_data_series with arguments codSeries, dateStart and dataEnd
series <- get_data_series(codSeries = "IPC251856", dateStart = "2023/01/01", 
                          dateEnd = "2023/04/01")
series$Data
#>          Fecha FK_TipoDato FK_Periodo Anyo Valor Secreto
#> 1 1.672528e+12           1          1 2023   5.9   FALSE
#> 2 1.675206e+12           1          2 2023   6.0   FALSE
#> 3 1.677625e+12           1          3 2023   3.3   FALSE
#> 4 1.680300e+12           1          4 2023   4.1   FALSE
```

#### Metadata request examples

Structural metadata are objects that describe both time series and
statistical tables and allow their definition. All these database
objects have an associated identifier that is essential for the correct
use of the service.

##### Obtaining statistical operations

The database contains information about all short-term statistical
operations, those with a periodicity for disseminating results of less
than a year, as well as some structural statistical operations. We can
get all the operations using the function `get_metadata_operations()`.

``` r
# We use the function get_metadata_operations
operations <- get_metadata_operations()
head(operations)
#>   Id Cod_IOE                                                 Nombre Codigo
#> 1  4   30147           Estadística de Efectos de Comercio Impagados     EI
#> 2  6   30211                     Índice de Coste Laboral Armonizado   ICLA
#> 3  7   30168 Estadística de Transmisión de Derechos de la Propiedad   ETDP
#> 4 10   30256                                    Indicadores Urbanos     UA
#> 5 13   30219                Estadística del Procedimiento Concursal    EPC
#> 6 14   30182                Índices de Precios del Sector Servicios    IPS
#>                                                                                                     Url
#> 1                                                                                                  <NA>
#> 2                                                                                                  <NA>
#> 3                                                                                                  <NA>
#> 4 https://www.ine.es/dyngs/INEbase/es/operacion.htm?c=Estadistica_C&cid=1254736176957&idp=1254735976608
#> 5                                                                                                  <NA>
#> 6                                                                                                  <NA>
```

An operation can be identify by a numerical code (‘*Id*’), an alphabetic
code (‘*Codigo*’) or by the code of the statistical operation in the
Inventory of Statistical Operations (IOE + ‘*Cod_IOE*’). To obtain
information about only one operation we have to pass the `operation`
argument with one of these codes.

``` r
# We use the function get_metadata_operations with argument operation
operation <- get_metadata_operations(operation = "IPC")
as.data.frame(operation)
#>   Id Cod_IOE                             Nombre Codigo
#> 1 25   30138 Índice de Precios de Consumo (IPC)    IPC
```

##### Obtaining variables

We can get all the variables of the system using the function
`get_metadata_variables()`.

``` r
# We use the function get_metadata_variables
variables <- get_metadata_variables()
head(variables)
#>    Id                           Nombre Codigo
#> 1 349            Totales Territoriales    NAC
#> 2 954                            Total       
#> 3  70 Comunidades y Ciudades Autónomas   CCAA
#> 4 516                     Nacionalidad      1
#> 5 955       Cultivos, pastos y huertos       
#> 6 956              SAU y Otras tierras
```

A variable can be identify by a numerical code (‘*Id*’). In addition, if
we pass the `operation` argument we obtain the variables used in an
operation.

``` r
# We use the function get_metadata_variables with argument operation,
# e.g., operation code = 'IPC'
variables <- get_metadata_variables(operation = "IPC")
head(variables)
#>    Id                           Nombre Codigo
#> 1   3                     Tipo de dato       
#> 2  70 Comunidades y Ciudades Autónomas   CCAA
#> 3 115                       Provincias   PROV
#> 4 269           Grupos especiales 2001       
#> 5 270                    Rúbricas 2001       
#> 6 349            Totales Territoriales    NAC
```

##### Obtaining values

To get all the values that a variable can take it is necessary to pass
the `variable` argument, which is the identifier of the variable, to the
function `get_metadata_values()`.

``` r
# We use the function get_metadata_values with argument variable,
# e.g., id = 3 (variable 'Tipo de dato')
values <- get_metadata_values(variable = 3)
head(values)
#>   Id Fk_Variable                                                   Nombre
#> 1 70           3                                             Datos brutos
#> 2 71           3 Datos corregidos de efectos estacionales y de calendario
#> 3 72           3                                                Dato base
#> 4 73           3                                     Variación trimestral
#> 5 74           3                                          Variación anual
#> 6 75           3                                                    Euros
#>   Codigo
#> 1       
#> 2       
#> 3       
#> 4       
#> 5       
#> 6
```

A value can be identify by a numerical code (‘*Id*’). In addition, if we
pass the `operation` argument as well we obtain the values that the
variable takes in that particular operation.

``` r
# We use the function get_metadata_values with arguments operation and variable,
# e.g., operation code = 'IPC'
values <- get_metadata_values(operation = "IPC", variable = 3)
head(values)
#>   Id Fk_Variable            Nombre Codigo
#> 1 72           3         Dato base       
#> 2 74           3   Variación anual       
#> 3 83           3            Índice       
#> 4 84           3 Variación mensual       
#> 5 85           3       Media anual      M
#> 6 86           3   Variación anual
```

##### Obtaining tables

We can get the tables associated with an statistical operation using the
function `get_metadata_tables_operation()`.

``` r
# We use the function get_metadata_tables with argument operation
tables <- get_metadata_tables_operation(operation = "IPC")
head(tables[,c("Id","Nombre")])
#>      Id
#> 1 24077
#> 2 25331
#> 3 35083
#> 4 50902
#> 5 50908
#> 6 50911
#>                                                                      Nombre
#> 1                       Índice general nacional. Series desde enero de 1961
#> 2                                Ponderaciones: general y de grupos ECOICOP
#> 3           Índices nacionales: Componentes para el análisis de la COVID-19
#> 4                           Índices nacionales: general y de grupos ECOICOP
#> 5    Índices nacionales a impuestos constantes: general y de grupos ECOICOP
#> 6 Tasa de variacion del índice general nacional. Series desde enero de 1961
```

A table is defined by different groups or selection combo boxes and each
of them by the values that one or several variables take. To obtain the
variables and values present in a table first we have to query the
groups that define the table using the function
`get_metadata_table_groups()`.

``` r
# We use the function get_metadata_table_groups with argument idTable
groups <- get_metadata_table_groups(idTable = 50902)
head(groups)
#>       Id         Nombre
#> 1 110889 Grupos ECOICOP
#> 2 110890   Tipo de dato
```

Once we have the identification codes of the groups, we can query the
values for an specific group using the function
`get_metadata_table_values()`.

``` r
# We use the function get_metadata_table_values with arguments idTable and idGroup
values <- get_metadata_table_values(idTable = 50902, idGroup = 110889)
head(values, 4)
#>       Id Fk_Variable                             Nombre Codigo
#> 1 304092         762                     Índice general     00
#> 2 304093         762 Alimentos y bebidas no alcohólicas     01
#> 3 304094         762       Bebidas alcohólicas y tabaco     02
#> 4 304095         762                  Vestido y calzado     03
#>   FK_JerarquiaPadres
#> 1               NULL
#> 2             304092
#> 3             304092
#> 4             304092
```

Alternatively, we can use the `get_metadata_table_varval()` function to
get the variables and values present in a table.

``` r
# Using the function get_metadata_table_varval
values <- get_metadata_table_varval(idTable = 50902)
head(values, 4)
#>       Id Fk_Variable                             Nombre Codigo
#> 1 304092         762                     Índice general     00
#> 2 304093         762 Alimentos y bebidas no alcohólicas     01
#> 3 304094         762       Bebidas alcohólicas y tabaco     02
#> 4 304095         762                  Vestido y calzado     03
```

##### Obtaining series

The data is only associated with the series object. To obtain
information about a particular series it is necessary to pass the
`codSeries` argument, which is the identification code of the series, to
the function `get_metadata_series()`.

``` r
# We use the function get_metadata_series with argument codSeries
series <- get_metadata_series(codSeries = "IPC251856")
as.data.frame(series)
#>       Id       COD FK_Operacion
#> 1 251856 IPC251856           25
#>                                              Nombre Decimales FK_Periodicidad
#> 1 Total Nacional. Índice general. Variación anual.          1               1
#>   FK_Publicacion FK_Clasificacion FK_Escala FK_Unidad
#> 1              8               90         1       135
```

To get the values and variables that define a series it is necessary to
pass the `codSeries` argument as well.

``` r
# We use the function get_metadata_series_values with argument codSeries
values <- get_metadata_series_values(codSeries = "IPC251856")
head(values)
#>       Id Fk_Variable          Nombre Codigo
#> 1  16473         349  Total Nacional     00
#> 2 304092         762  Índice general     00
#> 3     74           3 Variación anual
```

To get all the series that define a table it is necessary to pass the
`idTable` argument, which is the identification code of the table, to
the function `get_metadata_series_table()`.

``` r
# We use the function get_metadata_series_table with argument idTable
series <- get_metadata_series_table(idTable = 50902)
head(series[,c("COD", "Nombre")], 4)
#>         COD                                                          Nombre
#> 1 IPC251852                        Total Nacional. Índice general. Índice. 
#> 2 IPC251855             Total Nacional. Índice general. Variación mensual. 
#> 3 IPC251856               Total Nacional. Índice general. Variación anual. 
#> 4 IPC251858 Total Nacional. Índice general. Variación en lo que va de año.
```


### ineapir_example.R

```R
# Ejemplo de uso del paquete ineapir
#install.packages("ineapir")
library(ineapir)

# Definir la tabla a descargar
## Tipo tempus
tableId <- 67824

########################################################
# Definir parametros generales
########################################################
## Unnest: TRUE para desanidar el dataframe, se recomienda TRUE para evitar errores
unnest <- TRUE

## Validate: FALSE para evitar validaciones, Por defecto es TRUE, pero se puede poner FALSE para reducir las llamadas a la API
validate <- FALSE

## Tip: 
### =NULL sin fechas legibles ni metadados
### "A" Fechas en formato YYYY/MM/DD sin metadatos
### "M" Metadados como columna en el dataframe
### "AM" Fechas en formato YYYY/MM/DD con metadatos en el dataframe

tip <- "A"

## Extrae metadatos y lo añade como columna para cada variable. Se recomienda TRUE. TIP tiene que ser "AM" o "M" para poder ser TRUE
metanames <- FALSE
metacodes <- FALSE

## Lenguaje
lang= "ES" # "ES" para español, "EN" para inglés

########################################################
# Definir los filtros
########################################################
# Obtener los grupos de una tabla con su id
get_metadata_table_groups(idTable = idTable)

# Obtener los valores de una de una tabla con su id
get_metadata_table_values(idTable = idTable, idGroup = 141147)
get_metadata_table_values(idTable = idTable, idGroup = 141148)
get_metadata_table_values(idTable = idTable, idGroup = 141149)

# En base a las listas de los compandos anteriores elegimos los filtros que nos interesan 

filter <- list(`544`="283877",`482`="17134", `480`=c("141","17132"), `3`="72" )

########################################################
# Definir fechas
########################################################
dateStart <- "2019/01/01"
dateEnd <- "2026/01/01"

########################################################
# Descargar los datos y guardarlos en un archivo CSV
########################################################

df <- get_data_table(idTable = tableId, unnest = unnest, validate = validate, tip = tip, metanames = metanames, metacodes = metacodes, lang = lang, filter = filter, dateStart = dateStart, dateEnd = dateEnd)

write.csv(df, "ineapir_example.csv", row.names = FALSE)





```

### ineapir_examplo_infodataset.R

```R
# Ejemplo de uso del paquete ineapir
#install.packages("ineapir")
library(ineapir)

# Definir la tabla a descargar

## Tipo tempus

tip <- "AM"

## Funciones para las operacinoes (las bases de datos del INE)
# Obtener las bases de datos disponibles con su Cod_IOE
get_metadata_operations()

# Obtener la periodicidad de las operaciones con su id
get_metadata_periodicity()

# Obtener las publicaciones de una operación con su FK_PubFechaAct
get_metadata_publications(operation = 237)

# Obtener las variables de una operación con su id
get_metadata_variables(operation = 237)

# Obtener los valores de una variable de una operación con su id
get_metadata_values(operation = 237, variable = 3)

# Obtener las tablas de una operación con su id
get_metadata_tables_operation(operation = 237)

## Funciones para las tablas de datos del INE
idTable <- 67824

# Obtener los grupos de una tabla con su id
get_metadata_table_groups(idTable = idTable)

# Obtener los valores de una de una tabla con su id
get_metadata_table_values(idTable = idTable, idGroup = 141148)

# Obtener los metadatos de una tabla con su id
get_metadata_table_varval(idTable = idTable)

# Obtener las series de una tabla con su id
get_metadata_series_table(idTable = idTable)

# Obtener la operacion a la que pertenece una tabla con su id
get_metadata_operation_table(idTable = idTable)

## Funciones para las series de datos del INE

# Obtener los metadatos de una serie con su id
get_metadata_series(codSeries = "CNTR7300")

# Obtener los valores de una serie con su id
get_metadata_series_values(codSeries = "CNTR7300")


# Obtener las series de una operación con su id
get_metadata_series_operation(operation = 30024, det=1, tip=NULL, lang="ES", page=1, validate=TRUE, verbose=FALSE)
```

## OECD

### Guía rápida: OECD con R

Este documento explica cómo usar la función en `oecd/oecd_function.R` para descargar datos de la API SDMX de la OCDE en formato CSV y obtenerlos como un data frame en R.

#### Requisitos
- Paquete `httr` instalado (`install.packages("httr")` si fuera necesario)

#### Codigos ejemplo
- `oecd_onlylink.R` es un ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `oecd_min.R` es un ejemplo mínimo para descargar datos de la OCDE sin usar la función `oecd_api_function`.
- `oecd_example.R` es un ejemplo de uso de la función `oecd_api_function`.

#### Inputs
- **Obligatorios**
  - `agency_identifier`: identificador de la agencia (p. ej., `"OECD.ECO.MAD"`).
  - `dataset_identifier`: identificador del dataset (p. ej., `"DSD_EO@DF_EO"`).
  - `data_selection`: clave SDMX (dimensiones) tras la `/` (p. ej., `"FRA+DEU.PDTY.A"`).

- **Opcionales**
  - `dataset_version`: versión del dataset (p. ej., `""`).
  - `startPeriod`, `endPeriod`, `dimensionAtObservation`: parámetros comunes de consulta.

#### Cómo elegir inputs
1) Buscar el dataset en el explorador OCDE: https://data-explorer.oecd.org/
2) Seleccionar las dimensiones que se quieren descargar y consultar la sección "Developer API" para obtener `Agency identifier`, `Dataset identifier` y `Dataset version`.
3) Construir `data_selection` con las dimensiones requeridas por el dataset (p. ej., `PAISES.VARIABLE.FRECUENCIA`).
4) Ajustar parámetros opcionales (`startPeriod`, `endPeriod`, `dimensionAtObservation`).

#### Sintaxis de la API (OCDE)
- **Formato general:**
  ```
  {Host URL}/{Agency identifier},{Dataset identifier},{Dataset version}/{Data selection}?{otros parámetros}
  ```
  Donde el Host URL por defecto es `https://sdmx.oecd.org/public/rest/data`.

- **Ejemplo:**
  ```
  https://sdmx.oecd.org/public/rest/data/OECD.ECO.MAD,DSD_EO@DF_EO, /FRA+DEU.PDTY.A?startPeriod=1965&endPeriod=2023&dimensionAtObservation=AllDimensions
  ```

#### Output
- Un `data.frame` con los datos descargados desde la OCDE.

#### Notas
- Si la API devuelve error, verifique que `agency_identifier`, `dataset_identifier` y `data_selection` sean válidos.
- Revise la documentación del dataset para conocer las dimensiones y códigos disponibles.

#### Enlaces útiles
- Explorador OCDE: https://data-explorer.oecd.org/
- Documentación de la API: https://www.oecd.org/en/data/insights/data-explainers/2024/09/api.html


### oecd_example.R

```R
# Ejemplo de uso de la función oecd_api_function
library(httr)

#setwd("oecd")
source("oecd_function.R")

# Ejemplo de uso
df <- oecd_api_function(
  agency_identifier = "OECD.ECO.MAD",
  dataset_identifier = "DSD_EO@DF_EO",
  data_selection = "FRA+DEU.PDTY.A",
  startPeriod = "1965",
  endPeriod = "2023",
  dimensionAtObservation = "AllDimensions"
)

write.csv(df, "oecd_example.csv", row.names = FALSE)



```

### oecd_function.R

```R
# Función mínima para descargar datos de OECD SDMX (CSV)

# Inputs obligatorios:
# - agency_identifier: identificador de la agencia, p. ej. "OECD.ECO.MAD"
# - dataset_identifier: identificador del dataset, p. ej. "DSD_EO@DF_EO"
# - data_selection: clave SDMX (dimensiones) tras la '/'
#
# Inputs opcionales:
# - base_url: host de la API SDMX
# - dataset_version: versión del dataset
# - startPeriod, endPeriod, dimensionAtObservation: parámetros comunes de consulta
#
# Output:
# - df: data.frame con los datos descargados

oecd_api_function <- function(
  agency_identifier,
  dataset_identifier,
  data_selection,
  base_url = "https://sdmx.oecd.org/public/rest/data",
  dataset_version = "",
  startPeriod = NULL,
  endPeriod = NULL,
  dimensionAtObservation = NULL
) {
  data_identifier <- paste0(agency_identifier, ",", dataset_identifier, ",", dataset_version)

  params <- list()
  if (!is.null(startPeriod)) params$startPeriod <- startPeriod
  if (!is.null(endPeriod)) params$endPeriod <- endPeriod
  if (!is.null(dimensionAtObservation)) params$dimensionAtObservation <- dimensionAtObservation

  url <- paste0(base_url, "/", data_identifier, "/", data_selection)
  res <- httr::GET(url, query = params, httr::accept("text/csv"))
  if (httr::http_error(res)) stop(sprintf("OECD request failed [%s]", httr::status_code(res)))

  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  df <- utils::read.csv(text = txt, stringsAsFactors = FALSE)
  return(df)
}



```

### oecd_min.R

```R
# Descargador mínimo de OECD SDMX (CSV)
#
# Cómo personalizar:
# - Cambie 'data_identifier' para apuntar a {Agencia},{Dataset},{Versión}
# - Cambie 'data_selection' para seleccionar la clave (dimensiones) del dataset
# - Cambie 'params' (startPeriod, endPeriod, dimensionAtObservation)
# - Cambie 'output_name' para definir el nombre del archivo de salida
#
# Sintaxis oficial (OCDE):
# {Host URL}/{Agency identifier},{Dataset identifier},{Dataset version}/{Data selection}?{otros parámetros}

library(httr)

# --- Parámetros editables ---
# Identificadores de dataset
  base_url <- "https://sdmx.oecd.org/public/rest/data" # En principio no hace falta cambiarlo
  agency_identifier <- "OECD.ECO.MAD"
  dataset_identifier <- "DSD_EO@DF_EO"
  dataset_version <- ""
# Construir codigo completo  
  data_identifier <- paste0(agency_identifier, ",", dataset_identifier, ",", dataset_version)
# Rango de fechas y dimensiones
  data_selection <- "FRA+DEU.PDTY.A"
  params <- list(
    startPeriod = "1965",
    endPeriod = "2023",
    dimensionAtObservation = "AllDimensions"
  )
# Nombre del archivo de salida
  output_name <- "oecd_ejemplo"
  out_file <- paste0("data/", output_name, ".csv")

# --- Crear directorio de datos si no existe ---
if (!dir.exists("data")) dir.create("data", recursive = TRUE, showWarnings = FALSE)

# --- Descargar archivo CSV ---
url <- paste0(base_url, "/", data_identifier, "/", data_selection)
res <- httr::GET(url, query = params, httr::accept("text/csv"))
if (httr::http_error(res)) stop(sprintf("OECD request failed [%s]", httr::status_code(res)))
writeBin(httr::content(res, as = "raw"), out_file)



```

## OURWORLDINDATA

### Guía rápida: Our World in Data con R

Este documento explica cómo descargar datos directamente desde los gráficos de Our World in Data (OWID) en formato CSV usando R.

#### Requisitos
- Paquete `utils` instalado (viene por defecto en R, se usa `read.csv`)
- Paquete `jsonlite` (opcional, si se quieren metadatos)

#### Codigos ejemplo
- `worldindata_onlylink.R` es un ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `worldindata_min.R` es un ejemplo mínimo para descargar datos de OWID.

#### Inputs
- **Obligatorios**
  - `url`: URL directa del archivo CSV proporcionada por OWID para un gráfico específico.

#### Cómo elegir inputs
1) Vaya a un gráfico en [Our World in Data](https://ourworldindata.org/).
2) Haga clic en la pestaña "Download".
3) Haga clic derecho en el botón de descarga "Full data (CSV)" y seleccione "Copiar dirección del enlace".
4) Use esa URL en su script de R.

#### Sintaxis de la API
- **Formato general:**
  ```
  https://ourworldindata.org/grapher/{chart-slug}.csv?v=1&csvType=full&useColumnShortNames=true
  ```

- **Ejemplo:**
  ```
  https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.csv?v=1&csvType=full&useColumnShortNames=true
  ```

#### Output
- Un `data.frame` con los datos descargados desde OWID.

#### Enlaces útiles
- Portal: https://ourworldindata.org/


### worldindata_min.R

```R
library(jsonlite)
#setwd("R/ourworldindata")
# Fetch the data
df <- read.csv("https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.csv?v=1&csvType=full&useColumnShortNames=true")

# Fetch the metadata
metadata <- fromJSON("https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.metadata.json?v=1&csvType=full&useColumnShortNames=true")

# Save the data to CSV
output_path <- "labor_productivity.csv"
write.csv(df, output_path, row.names = FALSE)
print(paste("Data saved to", output_path))
```

## WORLDBANK

### Guía rápida: Banco Mundial con R

Este documento explica cómo usar la función en `worldbank/worldbank_function.R` para descargar datos desde el Banco Mundial (API JSON) y obtenerlos como un data frame en R.

#### Requisitos
- Paquetes `httr` y `jsonlite` instalados

#### Codigos ejemplo
- `worldbank_min.R` es un ejemplo mínimo para descargar datos del Banco Mundial sin usar la función `worldbank_api_function`.
- `worldbank_example.R` es un ejemplo de uso de la función `worldbank_api_function`.

#### Inputs
- **Obligatorios**
  - `iso3`: código(s) de país ISO-3 (p. ej., `"ESP"`), separados por `;` si son múltiples.
  - `indicator`: código(s) de indicador (p. ej., `NY.GDP.MKTP.KD.ZG`), separados por `;` si son múltiples.

- **Opcionales**
  - `date`: rango temporal (p. ej., `"2020:2023"`).
  - `per_page`: tamaño de página (use un valor alto, p. ej., `20000`).

#### Cómo elegir inputs
1) Elija país(es) `iso3` (estándar ISO 3166-1 alpha-3). Puede listar países: https://api.worldbank.org/v2/country?format=json
2) Elegir indicador (`indicator`)
   - Buscar en la web del World Bank la serie de interés. Seleccionar las variables y pinchar en `Metadata`-> `Series`. Copiar el codigo de la serie. Puede ser una lista de indicadores separados por `;`.
   - Busque indicadores en: https://api.worldbank.org/v2/indicator?format=json (listado paginado) o en el portal de datos del Banco Mundial.
   - También puede abrir un indicador concreto para ver su nombre/meta: https://api.worldbank.org/v2/indicator/NY.GDP.MKTP.KD.ZG?format=json.
3) Rango temporal
   - La API soporta `date=YYYY:YYYY` para filtrar.
   - Si por ejemplo es mensual, sería `date=2012M01:2012M08`

#### Sintaxis de la API (World Bank)
- **Formato general:**
  ```
  https://api.worldbank.org/v2/country/{ISO3}/indicator/{INDICATOR}?format=json&per_page={N}&date={DATE}
  ```

- **Ejemplo:**
  ```
  https://api.worldbank.org/v2/country/ESP;FRA/indicator/NY.GDP.MKTP.KD.ZG?format=json&per_page=20000&date=2020:2023
  ```

#### Output
- Un `data.frame` con los datos devueltos en el elemento `[2]` de la respuesta JSON.

#### Enlaces útiles
- Indicadores (API): https://datahelpdesk.worldbank.org/knowledgebase/articles/889392-about-the-indicators-api-documentation
- Estructura de llamadas: https://datahelpdesk.worldbank.org/knowledgebase/articles/898581-api-basic-call-structures
- Países (JSON): https://api.worldbank.org/v2/country?format=json
- Indicadores (JSON): https://api.worldbank.org/v2/indicator?format=json


### worldbank_example.R

```R
# Ejemplo de uso de la función worldbank_api_function
library(httr)
library(jsonlite)

#setwd("worldbank")
source("worldbank_function.R")

# Ejemplo de uso
df <- worldbank_api_function(
  iso3 = "ESP;FRA",
  indicator = "NY.GDP.MKTP.KD.ZG",
  date = "2020:2023",
  per_page = 20000
)

write.csv(df, "worldbank_example.csv", row.names = FALSE)



```

### worldbank_function.R

```R
# Función mínima para descargar datos del Banco Mundial (JSON -> data.frame)

# Inputs obligatorios:
# - iso3: código(s) de país ISO-3, separados por ';' si son múltiples
# - indicator: código(s) de indicador, separados por ';' si son múltiples
#
# Inputs opcionales:
# - date: rango temporal, p. ej., "2020:2023"
# - per_page: tamaño de página (use un valor alto para evitar paginación)
# - base_url: host de la API del Banco Mundial
#
# Output:
# - df: data.frame con los datos del elemento [2] de la respuesta JSON

worldbank_api_function <- function(
  iso3,
  indicator,
  date = NULL,
  per_page = 20000,
  base_url = "https://api.worldbank.org/v2"
) {
  path <- paste0("/country/", iso3, "/indicator/", indicator)
  url <- paste0(base_url, path)
  q <- list(format = "json", per_page = per_page)
  if (!is.null(date)) q$date <- date

  res <- httr::GET(url, query = q, httr::accept("application/json"))
  if (httr::http_error(res)) stop(sprintf("World Bank request failed [%s]", httr::status_code(res)))

  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  obj <- jsonlite::fromJSON(txt, flatten = TRUE)
  if (length(obj) < 2 || is.null(obj[[2]])) stop("Unexpected World Bank response structure; no data array present.")
  return(obj[[2]])
}



```

# Matlab

## COMEXT

### Guía rápida: Eurostat Comext con MATLAB

Este documento explica cómo usar la función en `matlab/comext/comext_function.m` para descargar datos del endpoint Comext de Eurostat (JSON) y obtenerlos como una tabla en MATLAB.

#### Requisitos
- Ninguno adicional a MATLAB.

#### Codigos ejemplo
- `comext_min.m`: ejemplo mínimo que construye la URL JSON y guarda en CSV.
- `comext_example.m`: ejemplo de uso de la función `comext_api_function` devolviendo una tabla y exportándola a CSV.

#### Inputs
- **Obligatorios**
  - `dataset_id`: identificador del dataset Comext (prefijo `"DS-"`, p. ej., `"DS-059341"`).
  - `filters`: struct NOMBRADO de filtros (dimensión -> valores). Los nombres deben ser dimensiones válidas (p. ej., `reporter`, `partner`, `product`, `flow`, `freq`, `time`, `indicators`, ...). Los valores pueden ser `"string"` o `cellstr`.

#### Cómo elegir inputs
1) Identifique el dataset en la guía de Comext y el portal de Eurostat.
2) Consulte la estructura del dataset en la guía Comext para conocer las dimensiones válidas y sus valores.
3) Ajuste `filters` con nombres de dimensiones válidos. Para múltiples valores use `cellstr` en MATLAB (enviamos parámetros repetidos).

#### Sintaxis de la API (Eurostat Comext)
- **Formato general:**
  ```
  https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/{dataset_id}?dim=...
  ```

#### Output
- Una `table` con columnas por dimensión y `value` (según disponibilidad).

#### Enlaces útiles
- Guía de Comext: https://ec.europa.eu/eurostat/web/user-guides/data-browser/api-data-access/api-getting-started/comext-database
- Portal Eurostat: https://ec.europa.eu/eurostat/


### comext_api_function.m

```matlab
function T = comext_api_function(dataset_id, filters)
% COMEXT_API_FUNCTION Descarga Eurostat COMEXT (JSON) y devuelve una tabla
%   T = comext_api_function(dataset_id, filters)
%   Parámetros:
%     dataset_id (char) - p. ej., 'DS-059341'
%     filters (struct) - dimensiones -> valores (string/cellstr)
%   Devuelve:
%     T (table) - datos etiquetados como tabla

base = ['https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/' dataset_id];

% Construir query con parámetros repetidos para multiselección
if ~isstruct(filters)
    error("'filters' debe ser un struct dimension -> valores");
end

qp = {};
fns = fieldnames(filters);
for i = 1:numel(fns)
    dim = fns{i};
    vals = filters.(dim);
    if ischar(vals) || isstring(vals); vals = cellstr(vals); end
    if isnumeric(vals); vals = cellstr(string(vals)); end
    for j = 1:numel(vals)
        qp{end+1} = sprintf('%s=%s', dim, vals{j}); %#ok<AGROW>
    end
end

url = base;
if ~isempty(qp), url = [base '?' strjoin(qp, '&')]; end

% Leer JSON y mapear a tabla similar a utilidades R
txt = webread(url, weboptions('Timeout', 60, 'ContentType', 'text', 'HeaderFields', {'Accept' 'application/json'}));
doc = jsondecode(txt);

% doc.value: mapa de indice->valor; doc.id, doc.size, doc.dimension
vals = doc.value;
if isempty(fieldnames(vals))
    T = table();
    return;
end

ids = cellstr(string(doc.id));
sizes = double(string(struct2cell(doc.size)))'; %#ok<NASGU>
dim = doc.dimension;

value_keys = str2double(fieldnames(vals));
value_vals = struct2cell(vals);
value_vals = cellfun(@(x) double(str2double(string(x))), value_vals);

% Construcción filas
rows = cell(numel(value_keys), 1);
for i = 1:numel(value_keys)
    rec = struct();
    rec.value = value_vals(i);
    % Mapear posiciones a códigos (métrica simplificada: usar índices directos si están)
    for k = 1:numel(ids)
        dn = ids{k};
        d = dim.(dn);
        imap = d.category.index;
        labels = d.category.label;
        % buscar código por posición (si coincide con i, aproximación)
        codes = fieldnames(imap);
        pos = struct2array(imap);
        idx = find(pos == 0, 1, 'first'); %#ok<NASGU>
        % Nota: una reconstrucción completa requiere strides; para simplicidad se omite
        if ~isempty(codes)
            code_k = string(codes{1});
            rec.(dn) = code_k;
            if isstruct(labels) && isfield(labels, codes{1})
                rec.([dn '_label']) = string(labels.(codes{1}));
            else
                rec.([dn '_label']) = missing;
            end
        end
    end
    rows{i} = rec;
end

T = struct2table([rows{:}]');

end



```

### comext_example.m

```matlab
% Ejemplo de uso: Eurostat COMEXT (JSON) -> tabla y CSV usando la función

cd(pwd);

% Parámetros de ejemplo (idénticos al ejemplo en R)
dataset_id = 'DS-059341';
filters = struct(...
    'reporter', {{'ES'}}, ...
    'partner',  {{'US'}}, ...
    'product',  {{'1509','8703'}}, ...
    'flow',     {{'2'}}, ...
    'freq',     {{'A'}}, ...
    'time',     num2cell(2015:2020) ...
);

% Llamar a la función
T = comext_api_function(dataset_id, filters);

% Carpeta de salida
outPath = 'comext_example.csv';

% Guardar como CSV
writetable(T, outPath, 'FileType', 'text');



```

### comext_min.m

```matlab
% Descargador Eurostat COMEXT (JSON) — script mínimo
% ----------------------------------------------------------------------------
% Objetivo
%   Construir la URL JSON de Comext con filtros, descargar los datos y convertir
%   a tabla de MATLAB para exportar a CSV.
% Parámetros editables
%   - dataset_id: identificador 'DS-...'
%   - filtros: parámetros repetidos (reporter, partner, product, flow, freq, time, ...)
% Salida
%   - Archivo CSV con los registros
% Notas
%   - Este ejemplo simplifica la reconstrucción de dimensiones SDMX; devuelve índice y valor.
% Pasos
%   1) Construir query con parámetros repetidos
%   2) webread JSON y jsondecode
%   3) Extraer doc.value y formar una tabla sencilla

% Identificador del dataset
dataset_id = 'DS-059341';
base = ['https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/' dataset_id];

% Filtros de ejemplo 
qp = {
    'reporter=ES',
    'partner=US',
    'product=1509', 'product=8703',
    'flow=2',
    'freq=A',
    'time=2015','time=2016','time=2017','time=2018','time=2019','time=2020'
};

% Construir la URL
url = [base '?' strjoin(qp, '&')];

% Leer la URL directamente a tabla
txt = webread(url, weboptions('Timeout', 60, 'ContentType', 'text', 'HeaderFields', {'Accept' 'application/json'}));
doc = jsondecode(txt);

% Conversión simplificada (ver nota en function para reconstrucción completa)
vals = doc.value;
if isempty(fieldnames(vals))
    T = table();
else
    keys = fieldnames(vals);
    v = struct2cell(vals);
    v = cellfun(@(x) double(str2double(string(x))), v);
    T = table(str2double(keys), v, 'VariableNames', {'idx','value'});
end

% Exportar la tabla a CSV
writetable(T, 'comext_min.csv', 'FileType', 'text');



```

## ECB

### Guía rápida: BCE con MATLAB

Este documento explica cómo usar la función en `matlab/ecb/ecb_function.m` para descargar una serie del BCE (dataset SDMX) en formato CSV y obtenerla como una tabla en MATLAB.

#### Requisitos
- Ninguno adicional a MATLAB.

#### Codigos ejemplo
- `ecb_onlylink.m`: ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `ecb_min.m`: ejemplo mínimo para descargar datos del BCE y guardarlos en CSV.
- `ecb_example.m`: ejemplo de uso de la función `ecb_api_function` devolviendo una tabla y exportándola a CSV.

#### Inputs
- **Obligatorios**
  - `dataset`: identificador del dataset del BCE (p. ej., `"BSI"`).
  - `seriesKey`: clave completa de la serie (dimensiones concatenadas con `.`).

#### Cómo elegir inputs
1) Abra el dataset en el portal BCE (p. ej., BSI): `https://data.ecb.europa.eu/data/datasets/BSI`
2) Use los filtros hasta ver la serie concreta; la clave `seriesKey` aparece en el recuadro de la serie.
3) Cada elemento de `seriesKey` es una dimensión del dataset; puede cambiar `U2` (Área del euro) por `ES` (España), etc.

#### Sintaxis de la API (BCE)
- **Formato general:**
  ```
  https://data-api.ecb.europa.eu/service/data/{dataset}/{seriesKey}?format=csvdata
  ```

- **Ejemplo:**
  ```
  https://data-api.ecb.europa.eu/service/data/BSI/M.U2.Y.V.M30.X.I.U2.2300.Z01.A?format=csvdata
  ```

#### Output
- Una `table` con los datos descargados desde el BCE.

#### Enlaces útiles
- Portal de datos del BCE (datasets): `https://data.ecb.europa.eu/data/datasets/`
- Documentación de la API de datos del BCE: `https://data.ecb.europa.eu/help/api/overview`
- API de datos (servicio): `https://data-api.ecb.europa.eu/service/`


### ecb_api_function.m

```matlab
function T = ecb_api_function(dataset, seriesKey, base_url)
% ECB_API_FUNCTION Descarga una serie del BCE (CSV) y la devuelve como tabla
%   T = ecb_api_function(dataset, seriesKey, base_url)
%   Parámetros:
%     dataset   (char) - identificador del dataset (p. ej., 'BSI')
%     seriesKey (char) - clave completa de la serie (dimensiones separadas por '.')
%     base_url  (char) - host del servicio (por defecto 'https://data-api.ecb.europa.eu/service/data')
%   Devuelve:
%     T (table) - datos descargados como tabla de MATLAB

if nargin < 3 || isempty(base_url)
    base_url = 'https://data-api.ecb.europa.eu/service/data';
end

% Construir URL con formato CSV
url = sprintf('%s/%s/%s?format=csvdata', base_url, dataset, seriesKey);

% Leer directamente la URL como tabla
T = readtable(url, 'FileType', 'text');

end



```

### ecb_example.m

```matlab
% Ejemplo de uso: descarga una serie del BCE y la guarda como CSV

cd(pwd);
% Parámetros de ejemplo
dataset = 'BSI';
seriesKey = 'M.U2.Y.V.M30.X.I.U2.2300.Z01.A';

% Llamar a la función
T = ecb_api_function(dataset, seriesKey);

% Carpeta de salida
outPath = 'ecb_example.csv';

% Guardar como CSV
writetable(T, outPath, 'FileType', 'text');



```

### ecb_min.m

```matlab
% Descargador BCE (CSV) — script mínimo
% ----------------------------------------------------------------------------
% Objetivo
%   Descargar una serie del BCE en formato CSV, cargarla como tabla y guardarla a disco.
% Parámetros editables
%   - dataset: identificador del dataset (p. ej., 'BSI')
%   - seriesKey: clave completa de la serie (dimensiones separadas por '.')
%   - outputName: nombre base del archivo de salida
% Salida
%   - Archivo CSV con los datos de la serie
% Pasos
%   1) Construir la URL con ?format=csvdata
%   2) Leer directamente a tabla
%   3) Exportar a CSV

% Parámetros básicos
dataset = 'BSI';
seriesKey = 'M.U2.Y.V.M30.X.I.U2.2300.Z01.A';
outputName = 'ecb_min';

% Construir URL directa en CSV
url = sprintf('https://data-api.ecb.europa.eu/service/data/%s/%s?format=csvdata', dataset, seriesKey);

% Leer a tabla
T = readtable(url, 'FileType', 'text');

% Guardar
writetable(T, [outputName '.csv'], 'FileType', 'text');



```

### ecb_onlylink.m

```matlab
% Minimal ECB Data API downloader (link only)
url = "https://data-api.ecb.europa.eu/service/data/BSI/M.U2.Y.V.M30.X.I.U2.2300.Z01.A?format=csvdata";
t = readtable(url);


```

## EUROSTAT

### Guía rápida: Eurostat con MATLAB

Este documento explica cómo usar la función en `matlab/eurostat/eurostat_function.m` para descargar datos SDMX-CSV de Eurostat y obtenerlos como una tabla en MATLAB.

#### Requisitos
- Ninguno adicional a MATLAB.

#### Codigos ejemplo
- `eurostat_onlylink.m`: ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `eurostat_min.m`: ejemplo mínimo para construir la URL SDMX-CSV y guardar en CSV.
- `eurostat_example.m`: ejemplo de uso de la función `eurostat_api_function` devolviendo una tabla y exportándola a CSV.

#### Inputs
- **Obligatorios**
  - `dataset_identifier`: identificador del dataset (p. ej., `"nama_10_a64"`).
  - `filters`: struct con dimensiones válidas del dataset (p. ej., `geo`, `na_item`, `unit`, `TIME_PERIOD`) mapeadas a valores (string o cellstr).

- **Opcionales**
  - `agency_identifier` (por defecto `"ESTAT"`).
  - `dataset_version` (por defecto `"1.0"`).
  - `compress` (por defecto `"false"`).
  - `format` (por defecto `"csvdata"`).
  - `formatVersion` (por defecto `"2.0"`).
  - `lang` (por defecto `"en"`).
  - `labels` (por defecto `"name"`).

#### Cómo elegir inputs
1) Lo más sencillo es ir a Eurostat, buscar la serie de interés y copiar el codigo de la serie. Mirar el codigo de las variables que nos interesan y los codigos de los valores que queremos filtrar.
2) Usar el codigo de la serie como `dataset_identifier`.
3) Ajustar filtros (`filters`).
   - Añada o cambie dimensiones válidas del dataset (p. ej., `geo`, `na_item`, `unit`, `freq`, `TIME_PERIOD`).
   - Para valores múltiples use cell arrays en MATLAB: `{'ES', 'FR'}`.
   - En `TIME_PERIOD` puede usar operadores SDMX: `ge:YYYY`, `le:YYYY`, `YYYY:YYYY`, `ge:200Q1`, etc.
4) Cambiar parametros opcionales si es necesario.

#### Sintaxis de la API (SDMX-CSV 3.0)
- **Formato general:**
  ```
  https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/{agency}/{dataset}/{version}/?c[DIM]=v1,v2&format=csvdata&formatVersion=2.0
  ```

#### Output
- Una `table` con los datos descargados de Eurostat.

#### Notas
- Los filtros deben usar nombres de dimensiones válidas del dataset.


### eurostat_api_function.m

```matlab
function T = eurostat_api_function(dataset_identifier, filters, agency_identifier, dataset_version, compress, format, formatVersion, lang, labels)
% EUROSTAT_API_FUNCTION Descarga SDMX-CSV (Eurostat) y lo devuelve como tabla
%   T = eurostat_api_function(dataset_identifier, filters, ...)
%   Parámetros obligatorios:
%     dataset_identifier (char) - identificador del dataset (p. ej., 'nama_10_a64')
%     filters (struct) - dimensiones -> valores (char/string/cellstr)
%   Parámetros opcionales (por defecto como en R):
%     agency_identifier = 'ESTAT'
%     dataset_version   = '1.0'
%     compress          = 'false'
%     format            = 'csvdata'
%     formatVersion     = '2.0'
%     lang              = 'en'
%     labels            = 'name'
%   Devuelve:
%     T (table) - datos descargados como tabla de MATLAB

if nargin < 3 || isempty(agency_identifier), agency_identifier = 'ESTAT'; end
if nargin < 4 || isempty(dataset_version),   dataset_version = '1.0'; end
if nargin < 5 || isempty(compress),          compress = 'false'; end
if nargin < 6 || isempty(format),            format = 'csvdata'; end
if nargin < 7 || isempty(formatVersion),     formatVersion = '2.0'; end
if nargin < 8 || isempty(lang),              lang = 'en'; end
if nargin < 9 || isempty(labels),            labels = 'name'; end

base_url = 'https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow';

% Identificador completo: context/agency/dataset/version
data_identifier = strjoin({agency_identifier, dataset_identifier, dataset_version}, '/');
url = sprintf('%s/%s/', base_url, data_identifier);

% Preparar parámetros de filtros c[dim]=v1,v2
if ~isstruct(filters)
    error("'filters' debe ser un struct: dimension -> valores");
end

filter_names = fieldnames(filters);
qp = {};
for i = 1:numel(filter_names)
    dim = filter_names{i};
    vals = filters.(dim);
    if ischar(vals) || isstring(vals)
        vals = cellstr(vals);
    elseif isnumeric(vals)
        vals = cellstr(string(vals));
    elseif iscell(vals)
        % ok
    else
        error('Tipo de valor no soportado para la dimensión %s', dim);
    end
    joined = strjoin(vals, ',');
    qp{end+1} = sprintf('c[%s]=%s', dim, joined); %#ok<AGROW>
end

% Parámetros comunes
qp{end+1} = sprintf('compress=%s', compress);
qp{end+1} = sprintf('format=%s', format);
qp{end+1} = sprintf('formatVersion=%s', formatVersion);
qp{end+1} = sprintf('lang=%s', lang);
qp{end+1} = sprintf('labels=%s', labels);

query = strjoin(qp, '&');
urlFull = [url '?' query];

% Leer directamente como tabla
T = readtable(urlFull, 'FileType', 'text');

end



```

### eurostat_example.m

```matlab
% Ejemplo de uso: Eurostat SDMX-CSV a tabla y CSV

cd(pwd);
% Parámetros de ejemplo
dataset_identifier = 'nama_10_a64';
filters = struct('geo', {{'IT'}}, 'na_item', {{'B1G'}}, 'unit', 'CLV20_MEUR', 'TIME_PERIOD', 'ge:1995');

% Llamar a la función
T = eurostat_api_function(dataset_identifier, filters);

% Carpeta de salida
outPath = 'eurostat_example.csv';

% Guardar como CSV
writetable(T, outPath, 'FileType', 'text');



```

### eurostat_min.m

```matlab
% Descargador Eurostat SDMX-CSV — script mínimo
% ----------------------------------------------------------------------------
% Objetivo
%   Construir la URL SDMX-CSV de Eurostat, descargar los datos, cargarlos en
%   una tabla de MATLAB y exportar a CSV.
% Parámetros editables
%   - dataset_identifier: identificador del dataset
%   - filters: struct con dimensiones válidas -> valores
% Salida
%   - Archivo CSV con los datos
% Pasos
%   1) Construir el identificador context/agency/dataset/version
%   2) Construir la query de filtros c[DIM]=v1,v2
%   3) Leer a tabla y exportar a CSV

% Id del dataset
dataset_identifier = 'nama_10_a64';
% Filtros de ejemplo
filters = struct('geo', {{'IT'}}, 'na_item', {{'B1G'}}, 'unit', 'CLV20_MEUR', 'TIME_PERIOD', 'ge:1995');

% parametros opcionales
agency_identifier = 'ESTAT';
dataset_version = '1.0';
compress = 'false';
format = 'csvdata';
formatVersion = '2.0';
lang = 'en';
labels = 'name';

% Construir la URL SDMX-CSV
base_url = 'https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow';
data_identifier = [agency_identifier '/' dataset_identifier '/' dataset_version];
url = [base_url '/' data_identifier '/'];

% Construir la query de filtros
qp = {};
fns = fieldnames(filters);
for i = 1:numel(fns)
    dim = fns{i};
    vals = filters.(dim);
    if ischar(vals) || isstring(vals); vals = cellstr(vals); end
    if isnumeric(vals); vals = cellstr(string(vals)); end
    joined = strjoin(vals, ',');
    qp{end+1} = sprintf('c[%s]=%s', dim, joined); %#ok<AGROW>
end
qp{end+1} = ['compress=' compress];
qp{end+1} = ['format=' format];
qp{end+1} = ['formatVersion=' formatVersion];
qp{end+1} = ['lang=' lang];
qp{end+1} = ['labels=' labels];

query = strjoin(qp, '&');
urlFull = [url '?' query];

% Leer la URL directamente a tabla
T = readtable(urlFull, 'FileType', 'text');

% Exportar la tabla a CSV
writetable(T, 'eurostat_min.csv', 'FileType', 'text');



```

### eurostat_onlylink.m

```matlab
% Minimal Eurostat API downloader (link only)
url = "https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/ESTAT/nama_10_a64/1.0/?c[geo]=ES,FR&c[na_item]=B1G,P1&c[unit]=CLV20_MEUR&c[TIME_PERIOD]=ge:1995&compress=false&format=csvdata&formatVersion=2.0&lang=en&labels=name";
t = readtable(url);


```

## FRED

### Guía rápida: FRED con MATLAB

Este documento explica cómo usar las funciones en `matlab/fred/fred_function.m` para descargar datos desde FRED.

#### Requisitos
- Ninguno adicional a MATLAB.

#### Codigos ejemplo
- `fred_onlylink.m`: ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `fred_min.m`: ejemplo mínimo que descarga un CSV de fredgraph.
- `fred_example.m`: ejemplo de uso de ambas funciones.

#### Inputs
- **fredgraph_api_function**
  - `graphId`: identificador del gráfico compartido (obligatorio).

- **fred_api_function**
  - `series_id`: identificador de la serie (p. ej., `"GDP"`).
  - Opcionales: `observation_start`, `observation_end`, `realtime_start`, `realtime_end`, `limit`, `offset`, `sort_order`, `units`, `frequency`, `aggregation_method`, `output_type`, `vintage_dates`, `api_key`.

#### Cómo elegir inputs
- Para `fredgraph_api_function`:
  - Obtenga `graphId` desde el enlace compartido del gráfico (parámetro `?g=` en la URL).

- Para `fred_api_function`:
  1) Elija `series_id` (p. ej., `GDP`, esto suele estar al lado del nombre de la serie en FRED entre paréntesis).
  2) Defina `FRED_API_KEY` como variable de entorno o pásela como argumento.
  3) Si es necesario, cambie los otros parámetros opcionales.

#### Sintaxis de la API
- **fredgraph CSV:**
  ```
  https://fred.stlouisfed.org/graph/fredgraph.csv?g={graphId}
  ```
- **API v1 observaciones:**
  ```
  https://api.stlouisfed.org/fred/series/observations?series_id={id}&api_key=...&file_type=json
  ```

#### Output
- `table` con las observaciones devueltas por cada método.


### fred_api_function.m

```matlab

function T = fred_api_function(series_id, varargin)
    % FRED_API_FUNCTION Descarga observaciones de la API v1 de FRED (JSON) a tabla
    %   T = fred_api_function(series_id, 'Name', Value, ...)
    %   Parámetros obligatorios:
    %     series_id (char)
    %   Parámetros Nombre-Valor (opcionales):
    %     'observation_start','observation_end','realtime_start','realtime_end',
    %     'limit','offset','sort_order','units','frequency','aggregation_method',
    %     'output_type','vintage_dates','api_key'
    
    p = inputParser;
    addRequired(p, 'series_id', @(x)ischar(x) || isstring(x));
    addParameter(p, 'observation_start', []);
    addParameter(p, 'observation_end', []);
    addParameter(p, 'realtime_start', []);
    addParameter(p, 'realtime_end', []);
    addParameter(p, 'limit', []);
    addParameter(p, 'offset', []);
    addParameter(p, 'sort_order', []);
    addParameter(p, 'units', []);
    addParameter(p, 'frequency', []);
    addParameter(p, 'aggregation_method', []);
    addParameter(p, 'output_type', []);
    addParameter(p, 'vintage_dates', []);
    addParameter(p, 'api_key', getenv('FRED_API_KEY'));
    parse(p, series_id, varargin{:});
    pp = p.Results;
    
    url = 'https://api.stlouisfed.org/fred/series/observations';
    q = struct('series_id', char(pp.series_id), 'api_key', char(pp.api_key), 'file_type', 'json');
    fn = fieldnames(pp);
    for i = 1:numel(fn)
        k = fn{i};
        if any(strcmp(k, {'series_id','api_key'})), continue; end
        v = pp.(k);
        if ~isempty(v)
            q.(k) = v;
        end
    end
    
    % Construir querystring
    qp = {};
    qf = fieldnames(q);
    for i = 1:numel(qf)
        qp{end+1} = sprintf('%s=%s', qf{i}, string(q.(qf{i}))); %#ok<AGROW>
    end
    urlFull = [url '?' strjoin(qp, '&')];
    
    txt = webread(urlFull, weboptions('Timeout', 60, 'ContentType', 'text'));
    obj = jsondecode(txt);
    if ~isfield(obj, 'observations')
        error('Estructura inesperada de la API de FRED; falta observations');
    end
    T = struct2table(obj.observations);
    
    end
    
    
    
```

### fred_example.m

```matlab
% Ejemplo de uso: FRED fredgraph y API v1

cd(pwd);
% fredgraph (sin API key)
T_graph = fredgraph_api_function('1wmdD');

% API v1 (requiere FRED_API_KEY)
setenv('FRED_API_KEY','28ee932ab037f5486dae766aebf0bec3');
T_api = fred_api_function('GDP');

outPath_graph = 'fred_graph_example.csv';
outPath_api = 'fred_api_example.csv';

writetable(T_graph, outPath_graph, 'FileType', 'text');
writetable(T_api,   outPath_api,   'FileType', 'text');



```

### fred_min.m

```matlab
% Descargador FRED (fredgraph CSV) — script mínimo
% ----------------------------------------------------------------------------
% Objetivo
%   Descargar el CSV de un gráfico compartido (fredgraph) y guardarlo como CSV tras
%   cargarlo en una tabla de MATLAB.
% Parámetros editables
%   - graphId: identificador del gráfico (parámetro g de la URL)
% Salida
%   - Archivo CSV con la serie del gráfico
% Pasos
%   1) Construir URL fredgraph.csv?g=...
%   2) Leer a tabla y exportar a CSV

% Identificador del gráfico
graphId = '1wmdD';
% Construir la URL
url = sprintf('https://fred.stlouisfed.org/graph/fredgraph.csv?g=%s', graphId);
% Leer la URL directamente a tabla
T = readtable(url, 'FileType', 'text');
% Exportar la tabla a CSV
writetable(T, 'fred_graph_min.csv', 'FileType', 'text');



```

### fred_onlylink.m

```matlab
% Minimal FRED API downloader (link only)
url = "https://fred.stlouisfed.org/graph/fredgraph.csv?g=1wmdD";
t = readtable(url);


```

### fredgraph_api_function.m

```matlab
function T = fredgraph_api_function(graphId)
% FREDGRAPH_API_FUNCTION Descarga CSV de fredgraph y devuelve tabla
%   T = fredgraph_api_function(graphId)
%   Parámetros:
%     graphId (char) - identificador del gráfico compartido en FRED
%   Devuelve:
%     T (table) - datos del CSV de fredgraph

url = sprintf('https://fred.stlouisfed.org/graph/fredgraph.csv?g=%s', graphId);
T = readtable(url, 'FileType', 'text');

end

```

## IMF

### Guía rápida: FMI con MATLAB

Este documento explica cómo usar la función en `matlab/imf/imf_api_function.m` para descargar datos SDMX-CSV de la API SDMX 3.0 del FMI y obtenerlos como una tabla en MATLAB.

#### Requisitos
- Ninguno adicional a MATLAB.

#### Codigos ejemplo
- `imf_onlylink.m`: ejemplo que descarga y lee el xml directamente del link de la API en una linea (usando `webread`).
- `imf_min.m`: ejemplo mínimo para construir la URL SDMX-CSV y guardar en CSV.
- `imf_example.m`: ejemplo de uso de la función `imf_api_function` devolviendo una tabla y exportándola a CSV.

#### Inputs
- **Obligatorios**
  - `dataset_identifier`: identificador del dataset (p. ej., "QNEA").
  - `data_selection`: clave SDMX completa tras la `/` (orden y códigos según el dataset). Ej.: "ESP.B1GQ.Q.SA.XDC.Q" o múltiples países "ESP+FRA.B1GQ.Q.SA.XDC.Q".

- **Opcionales**
  - `filters` (struct): filtros SDMX convertidos a `c[DIM]`. Para varias condiciones use `+`.
  - `agency_identifier`: por defecto "IMF.STA".
  - `dataset_version`: por defecto "+" (última versión).
  - `accept_csv_version`: por defecto "1.0.0".

#### Cómo elegir inputs
1) Localice el dataset y el indicador en el portal del FMI o en la documentación de SDMX.
2) Construya la `key` con las dimensiones requeridas por el dataset. En IFS suele ser `FREQ.REF_AREA.INDICATOR`.
3) Use `filters` si necesita condiciones adicionales.

#### Sintaxis de la API (FMI SDMX 3.0)
- **Formato general (CSV):**
  ```
  https://api.imf.org/external/sdmx/3.0/data/{context}/{agencyID}/{resourceID}/{version}/{key}[?c][&updatedAfter][&firstNObservations][&lastNObservations][&dimensionAtObservation][&attributes][&measures][&includeHistory][&asOf]
  ```
  Referencia al servicio SDMX JSON del FMI: `https://dataservices.imf.org/REST/SDMX_JSON.svc`

#### Output
- Una `table` con los datos descargados en formato SDMX-CSV.

#### Enlaces útiles
- Conocimiento/soporte del FMI (categoría API/SDMX): https://datasupport.imf.org/knowledge?id=knowledge_category&sys_kb_id=d41858e747294ad8805d07c4f16d43e0&category_id=9959b2bc1b6391903dba646fbd4bcb6a


### imf_api_function.m

```matlab
function T = imf_api_function(dataset_identifier, data_selection, filters, agency_identifier, dataset_version, accept_csv_version, base_url)
% IMF_API_FUNCTION Descarga SDMX-CSV (IMF SDMX 3.0) y devuelve una tabla
%   T = imf_api_function(dataset_identifier, data_selection, filters, ...)
%   Parámetros obligatorios:
%     dataset_identifier (char) - p. ej., 'QNEA'
%     data_selection     (char) - clave SDMX tras la '/'
%   Parámetros opcionales (por defecto similares a R):
%     filters            (struct) - filtros tipo c[DIM] -> valores (cellstr/char)
%                                 Ej.: struct('TIME_PERIOD', {{'ge:2020-Q1','le:2020-Q4'}})
%     agency_identifier  (char)   - por defecto 'IMF.STA'
%     dataset_version    (char)   - por defecto '+' (última versión)
%     accept_csv_version (char)   - por defecto '1.0.0'
%     base_url           (char)   - por defecto 'https://api.imf.org/external/sdmx/3.0/data/dataflow'
%   Devuelve:
%     T (table) - datos descargados como tabla de MATLAB

if nargin < 3 || isempty(filters),            filters = struct(); end
if nargin < 4 || isempty(agency_identifier),  agency_identifier = 'IMF.STA'; end
if nargin < 5 || isempty(dataset_version),    dataset_version = '+'; end
if nargin < 6 || isempty(accept_csv_version), accept_csv_version = '1.0.0'; end
if nargin < 7 || isempty(base_url),           base_url = 'https://api.imf.org/external/sdmx/3.0/data/dataflow'; end

% Construir URL: {base}/{agency}/{dataset}/{version}/{key}
url = sprintf('%s/%s/%s/%s/%s', base_url, agency_identifier, dataset_identifier, urlencode_keep_reserved(dataset_version), urlencode_keep_reserved(data_selection));

% Construir query de filtros c[DIM]=v1+v2
qp = {};
if ~isempty(filters)
    fns = fieldnames(filters);
    for i = 1:numel(fns)
        dim = fns{i};
        vals = filters.(dim);
        if ischar(vals) || isstring(vals); vals = cellstr(vals); end
        if isnumeric(vals); vals = cellstr(string(vals)); end
        joined = strjoin(vals, '+');
        qp{end+1} = sprintf('c[%s]=%s', dim, joined); %#ok<AGROW>
    end
end

urlFull = url;
if ~isempty(qp)
    urlFull = [url '?' strjoin(qp, '&')];
end

% Descargar CSV como texto con cabecera Accept SDMX-CSV
opts = weboptions('Timeout', 60, 'ContentType', 'text', 'HeaderFields', {'Accept' ['application/vnd.sdmx.data+csv;version=' accept_csv_version]});
csvText = webread(urlFull, opts);

% Guardar a temp y cargar como tabla
tmp = [tempname '.csv'];
fid = fopen(tmp, 'w');
fprintf(fid, '%s', csvText);
fclose(fid);
T = readtable(tmp, 'FileType', 'text');
try, delete(tmp); end %#ok<TRYNC>

end

function out = urlencode_keep_reserved(s)
% URLENCODE_KEEP_RESERVED Codifica s preservando caracteres reservados SDMX ('+', '*', ',', ':')
% MATLAB urlencode codifica demasiado; aquí mantenemos algunos símbolos útiles
s = string(s);
% Primero usar urlencode, luego revertir ciertos reservados
out = char(java.net.URLEncoder.encode(char(s), 'UTF-8'));
% Revertir reservados permitidos en el path SDMX
out = strrep(out, '%2B', '+');
out = strrep(out, '%2A', '*');
out = strrep(out, '%2C', ',');
out = strrep(out, '%3A', ':');
end

```

### imf_example.m

```matlab
% Ejemplo de uso: IMF SDMX-CSV -> tabla y CSV

cd(pwd);
%cd('matlab/imf')
% Parámetros de ejemplo (coinciden con R/imf/imf_example.R)
dataset_identifier = 'QNEA';
% Múltiples países en la clave SDMX con '+'
data_selection = 'ESP+FRA.B1GQ.Q.SA.XDC.Q';
filters = struct('TIME_PERIOD', {{'ge:2020-Q1','le:2020-Q4'}});

% Llamar a la función
T = imf_api_function(dataset_identifier, data_selection, filters);

% Carpeta de salida
outPath = 'imf_example.csv';

% Guardar como CSV
writetable(T, outPath, 'FileType', 'text');

```

### imf_min.m

```matlab
% Descargador mínimo IMF SDMX-CSV — script mínimo
% ----------------------------------------------------------------------------
% Objetivo
%   Construir la URL SDMX 3.0 del FMI (CSV), descargar los datos, cargarlos en
%   una tabla de MATLAB y exportar a CSV.
% Parámetros editables
%   - agency_identifier, dataset_identifier, dataset_version
%   - data_selection: clave SDMX tras la '/'
%   - filtros c[DIM] como struct -> lista de valores unidos con '+'
% Salida
%   - Archivo CSV con los datos
% Pasos
%   1) Construir {base}/{agency}/{dataset}/{version}/{key}
%   2) Añadir filtros c[DIM] en query
%   3) Leer como texto (Accept SDMX-CSV) y exportar a CSV

cd(pwd);

% Parámetros básicos (análogos a R/imf/imf_min.R)
base_url = 'https://api.imf.org/external/sdmx/3.0/data/dataflow';
agency_identifier = 'IMF.STA';
dataset_identifier = 'QNEA';
dataset_version = '+'; % última versión

% Clave SDMX (múltiples países con '+')
data_selection = 'ESP+FRA.B1GQ.Q.SA.XDC.Q';

% Filtros (TIME_PERIOD entre 2020-Q1 y 2020-Q4)
filters = struct('TIME_PERIOD', {{'ge:2020-Q1','le:2020-Q4'}});

% Construcción de URL
url = sprintf('%s/%s/%s/%s/%s', base_url, agency_identifier, dataset_identifier, urlencode_keep_reserved(dataset_version), urlencode_keep_reserved(data_selection));

% Construir query de filtros
qp = {};
fns = fieldnames(filters);
for i = 1:numel(fns)
    dim = fns{i};
    vals = filters.(dim);
    if ischar(vals) || isstring(vals); vals = cellstr(vals); end
    if isnumeric(vals); vals = cellstr(string(vals)); end
    qp{end+1} = sprintf('c[%s]=%s', dim, strjoin(vals, '+')); %#ok<AGROW>
end

urlFull = url;
if ~isempty(qp)
    urlFull = [url '?' strjoin(qp, '&')];
end

% Leer CSV como texto con cabecera Accept SDMX-CSV
opts = weboptions('Timeout', 60, 'ContentType', 'text', 'HeaderFields', {'Accept' 'application/vnd.sdmx.data+csv;version=1.0.0'});
csvText = webread(urlFull, opts);

% Guardar a archivo CSV mínimo
outFile = 'imf_min.csv';
fid = fopen(outFile, 'w'); fprintf(fid, '%s', csvText); fclose(fid);

function out = urlencode_keep_reserved(s)
% URLENCODE_KEEP_RESERVED Codifica s preservando '+' '*' ',' ':'
s = string(s);
out = char(java.net.URLEncoder.encode(char(s), 'UTF-8'));
out = strrep(out, '%2B', '+');
out = strrep(out, '%2A', '*');
out = strrep(out, '%2C', ',');
out = strrep(out, '%3A', ':');
end

```

### imf_onlylink.m

```matlab
% Minimal IMF API downloader (link only). Notice is a xml file, not a csv file.
url = "https://api.imf.org/external/sdmx/3.0/data/dataflow/IMF.STA/QNEA/%2B/ESP%2BFRA.B1GQ.Q.SA.XDC.Q";
options = weboptions('CertificateFilename', ''); % Disable SSL verification
% Reads the XML structure. Requires further parsing to convert to table.
data = webread(url, options); 


```

## INE

### Guía rápida: INE JAXIT3 con MATLAB

Este documento explica cómo usar la función en `matlab/ine/ine_jaxi_function.m` para descargar datos desde la API de INE JAXIT3 en formato CSV y obtenerlos como una tabla de MATLAB.

#### Requisitos
- Ninguno adicional a MATLAB.

#### Codigos ejemplo
- `ine_jaxi_onlylink.m`: ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `ine_jaxi_min.m`: ejemplo mínimo para descargar datos del INE y guardarlos en CSV directamente.
- `ine_jaxi_example.m`: ejemplo de uso de la función `ine_jaxi_function` devolviendo una tabla y exportándola a CSV.

#### Inputs
- **Obligatorios**
  - `tableId`: identificador de la tabla INE (p. ej., `"67821"`).

- **Opcionales**
  - `nocab`: `"1"` para evitar cabeceras adicionales (por defecto `"1"`).
  - `directory`: segmento de directorio (por defecto `"t"`).
  - `locale`: idioma del recurso (por defecto `"es"`).
  - `variant`: variante del CSV (por defecto `"csv_bdsc"`).

#### Cómo elegir inputs
1) Vaya a la página de la tabla en INE y copie el identificador (número al final de la URL).
2) Use ese identificador como `tableId`.
3) Ajuste parámetros opcionales (`nocab`, `locale`, `variant`, `directory`) si es necesario.
4) Si necesita cabeceras compactas para procesamiento, mantenga `nocab = "1"`.

#### Sintaxis de la API (INE JAXIT3)
- **Formato general:**
  ```
  https://www.ine.es/jaxiT3/files/{directory}/{locale}/{variant}/{tableId}.csv?nocab={nocab}
  ```
  Donde el Host URL es `https://www.ine.es/jaxiT3/files`.

- **Ejemplo:**
  ```
  https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/67821.csv?nocab=1
  ```

#### Output
- Una `table` de MATLAB con los datos descargados desde INE JAXIT3.

#### Notas
- La función lee directamente la URL con `readtable` usando `Delimiter = ';'`.
- Si la API devuelve error, verifique que el `tableId` exista y sea accesible.

#### Enlaces útiles
- INE (Banco de datos JAXIT3): https://www.ine.es/


### ine_jaxi_example.m

```matlab
% Ejemplo mínimo de uso para descargar una tabla de INE JAXI y exportar a CSV

% Cambiar el directorio de trabajo a la carpeta de este archivo
cd(pwd);

% Parámetros de ejemplo (tabla 67821, sin cabeceras adicionales)
tableId = '67821';
nocab = '1';

% Llamar a la función que devuelve una tabla de MATLAB
T = ine_jaxi_function(tableId, nocab);

% Construir ruta de salida
outPath = 'ine_jaxi_example.csv';

% Exportar como CSV con punto y coma como delimitador y UTF-8
writetable(T, outPath, 'Delimiter', ';', 'FileType', 'text');

```

### ine_jaxi_function.m

```matlab
function T = ine_jaxi_function(tableId, nocab, directory, locale, variant)
% INE_JAXI_FUNCTION Descarga un CSV de INE JAXIT3 y devuelve una tabla
%   T = ine_jaxi_function(tableId, nocab, directory, locale, variant)
%   Parámetros:
%     tableId  (char) - identificador de la tabla INE, p.ej. '67821'
%     nocab    (char) - '1' para evitar cabeceras adicionales (por defecto '1')
%     directory(char) - directorio base (por defecto 't')
%     locale   (char) - idioma (por defecto 'es')
%     variant  (char) - variante del formato (por defecto 'csv_bdsc')
%   Devuelve:
%     T (table) - datos descargados como tabla de MATLAB

if nargin < 2 || isempty(nocab), nocab = '1'; end
if nargin < 3 || isempty(directory), directory = 't'; end
if nargin < 4 || isempty(locale), locale = 'es'; end
if nargin < 5 || isempty(variant), variant = 'csv_bdsc'; end

% Construir URL del recurso CSV
baseUrl = 'https://www.ine.es/jaxiT3/files';
url = sprintf('%s/%s/%s/%s/%s.csv', baseUrl, directory, locale, variant, tableId);
query = sprintf('?nocab=%s', nocab);

% Leer directamente la URL como tabla (delimitador ';')
% Nota: readtable admite URLs; se concatena la query ?nocab=...
urlFull = [url query];
T = readtable(urlFull, 'Delimiter', ';', 'FileType', 'text', 'TextType', 'string');

end

```

### ine_jaxi_min.m

```matlab
% Descargador INE JAXIT3 (CSV) — script mínimo
% ----------------------------------------------------------------------------
% Objetivo
%   Descargar el CSV de una tabla INE, cargarlo en una tabla de MATLAB y exportar a CSV.
% Parámetros editables
%   - tableId: identificador de la tabla INE (p. ej., '67821')
%   - nocab: '1' evita cabeceras adicionales
%   - outputName: nombre base del archivo de salida
% Salida
%   - Archivo CSV con el contenido de la tabla
% Pasos
%   1) Construir URL con parámetros
%   2) Leer directamente a tabla con delimitador ';'
%   3) Exportar a CSV
cd(pwd);
% Parámetros básicos (idénticos al ejemplo en R/ine)
tableId = '67821';        % Identificador de la tabla en INE
nocab = '1';              % '1' evita cabeceras adicionales
outputName = 'ine_jaxi_min'; % Nombre base del archivo de salida

% Ruta de salida del CSV final
outFile = fullfile([outputName '.csv']);

% Construir URL y opciones de descarga
url = sprintf('https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/%s.csv', tableId);
query = sprintf('?nocab=%s', nocab);

% Leer directamente la URL como tabla de MATLAB (delimitador ';')
urlFull = [url query];
T = readtable(urlFull, 'Delimiter', ';', 'FileType', 'text');

% Exportar la tabla a CSV con separador ';'
writetable(T, outFile, 'Delimiter', ';', 'FileType', 'text');

```

### ine_jaxi_onlylink.m

```matlab
% Minimal INE JAXIT3 API downloader (link only)
url = "https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/67821.csv?nocab=1";
t = readtable(url);


```

## OECD

### Guía rápida: OECD con MATLAB

Este documento explica cómo usar la función en `matlab/oecd/oecd_function.m` para descargar datos SDMX CSV de OECD y obtenerlos como una tabla en MATLAB.

#### Requisitos
- Ninguno adicional a MATLAB.

#### Codigos ejemplo
- `oecd_onlylink.m`: ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `oecd_min.m`: ejemplo mínimo para construir la URL y guardar en CSV.
- `oecd_example.m`: ejemplo de uso de la función `oecd_api_function` devolviendo una tabla y exportándola a CSV.

#### Inputs
- **Obligatorios**
  - `agency_identifier`: p. ej., `"OECD.ECO.MAD"`.
  - `dataset_identifier`: p. ej., `"DSD_EO@DF_EO"`.
  - `data_selection`: clave SDMX tras la `/`.

- **Opcionales**
  - `dataset_version` (por defecto `""`).
  - `startPeriod`, `endPeriod`, `dimensionAtObservation`.

#### Cómo elegir inputs
1) Buscar el dataset en el explorador OCDE: https://data-explorer.oecd.org/
2) Seleccionar las dimensiones que se quieren descargar y consultar la sección "Developer API" para obtener `Agency identifier`, `Dataset identifier` y `Dataset version`.
3) Construir `data_selection` con las dimensiones requeridas por el dataset (p. ej., `PAISES.VARIABLE.FRECUENCIA`).
4) Ajustar parámetros opcionales (`startPeriod`, `endPeriod`, `dimensionAtObservation`).

#### Sintaxis de la API (OECD SDMX)
- **Formato general:**
  ```
  https://sdmx.oecd.org/public/rest/data/{agency},{dataset},{version}/{data_selection}
  ```

#### Output
- Una `table` con los datos descargados de OECD.

#### Enlaces útiles
- Explorador OCDE: https://data-explorer.oecd.org/
- Documentación de la API: https://www.oecd.org/en/data/insights/data-explainers/2024/09/api.html


### oecd_api_function.m

```matlab
function T = oecd_api_function(agency_identifier, dataset_identifier, data_selection, base_url, dataset_version, startPeriod, endPeriod, dimensionAtObservation)
% OECD_API_FUNCTION Descarga CSV SDMX de OECD y lo devuelve como tabla
%   T = oecd_api_function(agency_identifier, dataset_identifier, data_selection, ...)
%   Parámetros obligatorios:
%     agency_identifier (char) - p. ej., 'OECD.ECO.MAD'
%     dataset_identifier (char) - p. ej., 'DSD_EO@DF_EO'
%     data_selection (char) - clave SDMX tras la '/'
%   Opcionales:
%     base_url (char) - por defecto 'https://sdmx.oecd.org/public/rest/data'
%     dataset_version (char) - por defecto ''
%     startPeriod, endPeriod, dimensionAtObservation - parámetros comunes

if nargin < 4 || isempty(base_url), base_url = 'https://sdmx.oecd.org/public/rest/data'; end
if nargin < 5, dataset_version = ''; end

data_identifier = [agency_identifier ',' dataset_identifier ',' dataset_version];
url = sprintf('%s/%s/%s', base_url, data_identifier, data_selection);

qp = {};
if exist('startPeriod','var') && ~isempty(startPeriod), qp{end+1} = ['startPeriod=' char(string(startPeriod))]; end
if exist('endPeriod','var') && ~isempty(endPeriod), qp{end+1} = ['endPeriod=' char(string(endPeriod))]; end
if exist('dimensionAtObservation','var') && ~isempty(dimensionAtObservation), qp{end+1} = ['dimensionAtObservation=' dimensionAtObservation]; end

urlFull = url;
if ~isempty(qp), urlFull = [url '?' strjoin(qp, '&')]; end

T = readtable(urlFull, 'FileType', 'text');

end



```

### oecd_example.m

```matlab
% Ejemplo de uso: OECD SDMX CSV -> tabla y CSV

cd(pwd);

% Parámetros de ejemplo (rellenar según dataset/selección reales)
agency_identifier = 'OECD.ECO.MAD';
dataset_identifier = 'DSD_EO@DF_EO';
data_selection = '...'; % clave SDMX específica

T = oecd_api_function(agency_identifier, dataset_identifier, data_selection);


outPath = 'oecd_example.csv';

writetable(T, outPath, 'FileType', 'text');



```

### oecd_min.m

```matlab
% Descargador OECD SDMX CSV — script mínimo
% ----------------------------------------------------------------------------
% Objetivo
%   Construir la URL SDMX de OECD, descargar el CSV, cargarlo como tabla y exportar a CSV.
% Parámetros editables
%   - agency_identifier, dataset_identifier, dataset_version (si aplica)
%   - data_selection: clave SDMX tras la '/'
% Salida
%   - Archivo CSV con los datos del dataset seleccionado
% Pasos
%   1) Construir data_identifier agency,dataset,version
%   2) Leer URL directamente a tabla
%   3) Exportar a CSV

% Parámetros básicos
agency_identifier = 'OECD.ECO.MAD';
dataset_identifier = 'DSD_EO@DF_EO';
dataset_version = '';
data_selection = '...'; % clave SDMX específica

% Construir la URL SDMX
base_url = 'https://sdmx.oecd.org/public/rest/data';
data_identifier = [agency_identifier ',' dataset_identifier ',' dataset_version];
url = sprintf('%s/%s/%s', base_url, data_identifier, data_selection);

% Leer la URL directamente a tabla
T = readtable(url, 'FileType', 'text');

% Exportar la tabla a CSV
writetable(T, 'oecd_min.csv', 'FileType', 'text');



```

### oecd_onlylink.m

```matlab
% Minimal OECD API downloader (link only)
url = "https://sdmx.oecd.org/public/rest/data/OECD.ECO.MAD,DSD_EO@DF_EO,/FRA+DEU.PDTY.A?format=csvfile&startPeriod=1965&endPeriod=2023";
t = readtable(url);


```

## OURWORLDINDATA

### Guía rápida: Our World in Data con MATLAB

Este documento muestra cómo importar datos directamente desde los gráficos de Our World in Data (OWID) a MATLAB.

#### Requisitos
- Ninguno adicional a MATLAB.

#### Codigos ejemplo
- `worldindata_onlylink.m` es un ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `worldindata_min.m` es un ejemplo mínimo para descargar datos de OWID.

#### Inputs
- **Obligatorios**
  - `url`: URL directa del archivo CSV proporcionada por OWID para un gráfico específico.

#### Cómo elegir inputs
1) Vaya a un gráfico en [Our World in Data](https://ourworldindata.org/).
2) Haga clic en la pestaña "Download".
3) Haga clic derecho en el botón de descarga "Full data (CSV)" y seleccione "Copiar dirección del enlace".
4) Use esa URL en su script de MATLAB.

#### Sintaxis de la API
- **Formato general:**
  ```
  https://ourworldindata.org/grapher/{chart-slug}.csv?v=1&csvType=full&useColumnShortNames=true
  ```

- **Ejemplo:**
  ```
  https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.csv?v=1&csvType=full&useColumnShortNames=true
  ```

#### Output
- Una `table` de MATLAB con los datos descargados.

#### Enlaces útiles
- Portal: https://ourworldindata.org/


### worldindata_min.m

```matlab
% Define URLs
dataUrl = "https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.csv?v=1&csvType=full&useColumnShortNames=true";
metadataUrl = "https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.metadata.json?v=1&csvType=full&useColumnShortNames=true";

% Set options with User-Agent
options = weboptions('UserAgent', 'Our World In Data data fetch/1.0');

% Fetch the data
try
    df = webread(dataUrl, options);
catch ME
    error('Failed to fetch data: %s', ME.message);
end

% Fetch the metadata
try
    metadata = webread(metadataUrl, options);
catch ME
    error('Failed to fetch metadata: %s', ME.message);
end

% Save the data to CSV in the same folder as the script
% Get the full path of the current script
currentScriptPath = mfilename('fullpath');
[currentDir, ~, ~] = fileparts(currentScriptPath);

% Define output path
outputPath = fullfile(currentDir, 'labor_productivity.csv');

% Write table to CSV
writetable(df, outputPath);

fprintf('Data saved to %s\n', outputPath);



```

### worldindata_onlylink.m

```matlab
% Minimal OurWorldInData downloader (link only)
url = "https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.csv?v=1&csvType=full&useColumnShortNames=true";
t = readtable(url);


```

## WORLDBANK

### Guía rápida: Banco Mundial con MATLAB

Este documento explica cómo usar la función en `matlab/worldbank/worldbank_function.m` para descargar datos JSON del Banco Mundial y obtenerlos como una tabla en MATLAB.

#### Requisitos
- Ninguno adicional a MATLAB.

#### Codigos ejemplo
- `worldbank_min.m`: ejemplo mínimo para construir la URL y guardar en CSV.
- `worldbank_example.m`: ejemplo de uso de la función `worldbank_api_function` devolviendo una tabla y exportándola a CSV.

#### Inputs
- **Obligatorios**
  - `iso3`: código(s) de país ISO-3 (múltiples separados por ';').
  - `indicator`: código(s) de indicador (múltiples separados por ';').

- **Opcionales**
  - `date` (p. ej., `"2015:2020"`).
  - `per_page` (por defecto `20000`).

#### Cómo elegir inputs
1) Elija país(es) `iso3` (estándar ISO 3166-1 alpha-3). Puede listar países: https://api.worldbank.org/v2/country?format=json
2) Elegir indicador (`indicator`)
   - Buscar en la web del World Bank la serie de interés. Seleccionar las variables y pinchar en `Metadata` -> `Series`. Copiar el código de la serie. Puede ser una lista de indicadores separados por `;`.
   - Busque indicadores en: https://api.worldbank.org/v2/indicator?format=json (listado paginado) o en el portal de datos del Banco Mundial.
3) Rango temporal
   - La API soporta `date=YYYY:YYYY` para filtrar.

#### Sintaxis de la API (World Bank)
- **Formato general:**
  ```
  https://api.worldbank.org/v2/country/{iso3}/indicator/{indicator}?format=json&per_page=...&date=...
  ```

#### Output
- Una `table` con los datos de la respuesta (elemento [2]).

#### Enlaces útiles
- Indicadores (API): https://datahelpdesk.worldbank.org/knowledgebase/articles/889392-about-the-indicators-api-documentation
- Estructura de llamadas: https://datahelpdesk.worldbank.org/knowledgebase/articles/898581-api-basic-call-structures


### worldbank_api_function.m

```matlab
function T = worldbank_api_function(iso3, indicator, date, per_page, base_url)
% WORLDBANK_API_FUNCTION Descarga datos del Banco Mundial (JSON) y devuelve tabla
%   T = worldbank_api_function(iso3, indicator, date, per_page, base_url)
%   Parámetros:
%     iso3 (char) - código(s) ISO-3; múltiples separados por ';'
%     indicator (char) - código(s) de indicador; múltiples separados por ';'
%     date (char, opcional) - rango temporal, p. ej. '2020:2023'
%     per_page (num, opcional) - tamaño de página (por defecto 20000)
%     base_url (char, opcional) - por defecto 'https://api.worldbank.org/v2'
%   Devuelve:
%     T (table) - datos del elemento [2] de la respuesta JSON

if nargin < 4 || isempty(per_page), per_page = 20000; end
if nargin < 5 || isempty(base_url), base_url = 'https://api.worldbank.org/v2'; end

path = ['/country/' iso3 '/indicator/' indicator];
q = sprintf('?format=json&per_page=%d', per_page);
if exist('date','var') && ~isempty(date)
    q = [q '&date=' date];
end
url = [base_url path q];

% Leer JSON como texto y decodificar
txt = webread(url, weboptions('Timeout', 60, 'ContentType', 'text'));
obj = jsondecode(txt);
if numel(obj) < 2 || isempty(obj{2})
    error('Respuesta inesperada del Banco Mundial; no hay datos en el índice 2.');
end

% Convertir a tabla
S = obj{2};
T = struct2table(S);

end



```

### worldbank_example.m

```matlab
% Ejemplo de uso: Banco Mundial JSON -> tabla y CSV


cd(pwd);

% Parámetros de ejemplo
iso3 = 'ESP';
indicator = 'NY.GDP.MKTP.KD.ZG'; % crecimiento del PIB (% anual)
date = '2015:2020';

T = worldbank_api_function(iso3, indicator, date);

outPath = 'worldbank_example.csv';

writetable(T, outPath, 'FileType', 'text');



```

### worldbank_min.m

```matlab
% Descargador Banco Mundial (JSON) — script mínimo
% ----------------------------------------------------------------------------
% Objetivo
%   Construir la URL JSON del Banco Mundial, descargar los datos, convertirlos
%   a tabla de MATLAB y exportar a CSV.
% Parámetros editables
%   - iso3: país(es) ISO-3; indicator: indicador(es)
%   - date: rango temporal 'YYYY:YYYY'
% Salida
%   - Archivo CSV con los registros
% Pasos
%   1) Construir URL con format=json&per_page=...
%   2) webread + jsondecode
%   3) struct2table y exportar a CSV

% Parámetros básicos
iso3 = 'ESP';
indicator = 'NY.GDP.MKTP.KD.ZG';
date = '2015:2020';

% Construir la URL JSON del Banco Mundial
base_url = 'https://api.worldbank.org/v2';
path = ['/country/' iso3 '/indicator/' indicator];
url = [base_url path '?format=json&per_page=20000&date=' date];

% Leer la URL directamente a tabla
txt = webread(url, weboptions('Timeout', 60, 'ContentType', 'text'));
obj = jsondecode(txt);
S = obj{2};

% Convertir a tabla
T = struct2table(S);

% Exportar la tabla a CSV
writetable(T, 'worldbank_min.csv', 'FileType', 'text');



```

# Stata

## ECB

### Guía rápida: ECB con Stata

Este documento explica cómo descargar datos del Banco Central Europeo (ECB) usando `ecb/ecb_min.do` en Stata, solicitando el formato CSV.

#### Requisitos
- Stata

#### Codigos ejemplo
- `ecb_min.do` es un ejemplo mínimo para descargar datos del BCE directamente en Stata.

#### Inputs
- **Obligatorios**
  - `dataset`: identificador del dataset del BCE (p. ej., `"BSI"`).
  - `seriesKey`: clave completa de la serie (dimensiones concatenadas con `.`).

#### Cómo elegir inputs
1) Abra el dataset en el portal BCE (p. ej., BSI): https://data.ecb.europa.eu/data/datasets/BSI
2) Use los filtros hasta ver la serie concreta; la clave `seriesKey` aparece en el recuadro de la serie.
3) Cada elemento de `seriesKey` es una dimensión del dataset; puede cambiar `U2` (Área del euro) por `ES` (España), etc. Pinchando en `view all` se pueden ver todas las dimensiones del dataset y sus códigos.

#### Sintaxis de la API (BCE)
- **Formato general:**
  ```
  https://data-api.ecb.europa.eu/service/data/{dataset}/{seriesKey}?format=csvdata
  ```

- **Ejemplo:**
  ```
  https://data-api.ecb.europa.eu/service/data/BSI/M.U2.Y.V.M30.X.I.U2.2300.Z01.A?format=csvdata
  ```

#### Output
- Un dataset en memoria de Stata con los datos descargados.

#### Enlaces útiles
- Portal de datos del BCE (datasets): https://data.ecb.europa.eu/data/datasets/
- Documentación de la API de datos del BCE: https://data.ecb.europa.eu/help/api/overview
- API de datos (servicio): https://data-api.ecb.europa.eu/service/


### ecb_min.do

```stata
global dataset "BSI"
global seriesKey "M.U2.Y.V.M30.X.I.U2.2300.Z01.A"
import delimited "https://data-api.ecb.europa.eu/service/data/${dataset}/${seriesKey}?format=csvdata", encoding("utf-8") clear
```

## EUROSTAT

### Guía rápida: Eurostat con Stata

Este documento explica cómo descargar datos de Eurostat directamente en Stata usando la API SDMX 3.0 de diseminación.

#### Requisitos
- Stata

#### Codigos ejemplo
- `eurostat_min.do` es un ejemplo mínimo para descargar datos de Eurostat directamente en Stata.

#### Inputs
- **Obligatorios**
  - `agency_identifier`: identificador de la agencia (p. ej., `"ESTAT"`).
  - `dataset_identifier`: identificador del dataset (p. ej., `"nama_10_a64"`).
  - `filters`: filtros en formato URL query string (p. ej., `?c[geo]=ES`).

#### Cómo elegir inputs
1) Lo más sencillo es ir a Eurostat, buscar la serie de interés y copiar el codigo de la serie. Mirar el codigo de las variables que nos interesan y los codigos de los valores que queremos filtrar.
2) Usar el codigo de la serie como `dataset_identifier`.
3) Ajustar la global `filters` con formato URL query string:
   - Use `c[DIMENSION]=VALOR`.
   - Para valores múltiples use comas: `c[geo]=ES,FR`.
   - En `TIME_PERIOD` puede usar operadores SDMX: `ge:YYYY`, `le:YYYY`.
   - Ejemplo: `?c[geo]=ES&c[unit]=EUR`.

#### Sintaxis de la API (SDMX 3.0)
- **Formato general:**
  ```
  https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/{agency_identifier}/{dataset_identifier}/1.0/{filters}&compress=false&format=csvdata&formatVersion=2.0&lang=en&labels=name
  ```

- **Ejemplo:**
  ```
  https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/ESTAT/nama_10_a64/1.0/?c[geo]=ES&c[unit]=CLV_I20&compress=false&format=csvdata&formatVersion=2.0
  ```

#### Output
- Un dataset en memoria de Stata con los datos descargados.

#### Enlaces útiles
- Guía de consultas de datos (SDMX 3.0, Eurostat): [API - Detailed guidelines - SDMX3.0 API - data query](https://ec.europa.eu/eurostat/web/user-guides/data-browser/api-data-access/api-detailed-guidelines/sdmx3-0/data-query)
- [Eurostat API Setup](https://wikis.ec.europa.eu/display/EUROSTATHELP/API+SDMX+3.0+-+Data+retrieval)


### eurostat_min.do

```stata
global agency_identifier "ESTAT"
global dataset_eurostat "nama_10_a64"    
global filters "?c[freq]=A&c[unit]=CLV_I20,CLV05_MEUR&c[nace_r2]=TOTAL&c[na_item]=B1G,P1&c[geo]=ES&c[TIME_PERIOD]=ge:1995"

import delimited "https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/${agency_identifier}/${dataset_eurostat}/1.0/${filters}&compress=false&format=csvdata&formatVersion=2.0&lang=en&labels=name", encoding("utf-8") clear


```

## FRED

### Guía rápida: FRED con Stata

Este documento explica cómo usar el comando nativo `import fred` en Stata para descargar datos de la Reserva Federal de St. Louis.

#### Requisitos
- Stata 15 o superior (para el comando `import fred` nativo).
- Una API Key de FRED (gratuita).

#### Codigos ejemplo
- `fred_min.do` es un ejemplo mínimo para descargar datos de FRED usando `import fred`.

#### Inputs
- **Obligatorios**
  - `series_id`: identificador de la serie (p. ej., `"GNPCA"`).
  - `api_key`: clave API personal de FRED.

#### Cómo elegir inputs
1) Elija el `series_id` (p. ej., `GDP`, `CPIAUCSL`). Esto suele estar al lado del nombre de la serie en FRED entre paréntesis.
2) Use ese ID en el comando `import fred ID`.
3) Para conseguir una API key, hay que registrarse en FRED, entrar en la cuenta, ir a la sección "API keys" y pinchar en "Request API key".

#### Sintaxis de la API
- Uso del comando nativo de Stata `import fred`.
  ```stata
  set fredkey TUAPIKEY
  import fred SERIES_ID, clear
  ```

#### Output
- Un dataset en memoria de Stata con los datos descargados.

#### Enlaces útiles
- Referencia oficial: [FRED observations API docs](https://fred.stlouisfed.org/docs/api/fred/series_observations.html)
- [Documentación de import fred en Stata](https://www.stata.com/manuals/dimportfred.pdf)


### fred_min.do

```stata
set fredkey TUAPIKEY
import fred GNPCA, clear
```

## IMF

### Guía rápida: FMI con Stata

Este documento explica cómo usar el script `imf/imf_min.do` para descargar datos del FMI (servicio SDMX 3.0) directamente en Stata.

#### Requisitos
- Stata (con capacidad de conexión a internet y comando `import delimited`).

#### Codigos ejemplo
- `imf_min.do` es un ejemplo mínimo para descargar datos del FMI directamente en Stata.

#### Inputs
- **Obligatorios**
  - `dataset_identifier`: identificador del dataset (p. ej., "QNEA").
  - `key`: clave SDMX completa (orden y códigos según el dataset). Ej.: "ESP+FRA.B1GQ.Q.SA.XDC.Q".
  - `agency_identifier`: por defecto "IMF.STA".
  - `dataset_version`: por defecto "+" (última versión).

#### Cómo elegir inputs
1) Localice el dataset y el indicador en el portal del FMI o en la documentación de SDMX.
2) Construya la `key` con las dimensiones requeridas por el dataset. En IFS suele ser `FREQ.REF_AREA.INDICATOR`.
3) La estructura de la URL es `.../data/dataflow/{agency_identifier}/{dataset_identifier}/{dataset_version}/{key}`.

#### Sintaxis de la API (FMI SDMX 3.0)
- **Formato general:**
  ```
  https://api.imf.org/external/sdmx/3.0/data/dataflow/{agency_identifier}/{dataset_identifier}/{dataset_version}/{key}
  ```
  Referencia al servicio SDMX JSON del FMI: `https://dataservices.imf.org/REST/SDMX_JSON.svc`

#### Output
- Un dataset en memoria de Stata con los datos descargados.

#### Enlaces útiles
- Conocimiento/soporte del FMI (categoría API/SDMX): https://datasupport.imf.org/knowledge?id=knowledge_category&sys_kb_id=d41858e747294ad8805d07c4f16d43e0&category_id=9959b2bc1b6391903dba646fbd4bcb6a


### imf_min.do

```stata
import delimited "https://api.imf.org/external/sdmx/3.0/data/dataflow/IMF.STA/QNEA/%2B/ESP%2BFRA.B1GQ.Q.SA.XDC.Q", clear

```

## INE

### Guía rápida: INE con Stata

Este documento muestra cómo cargar datos del INE (Instituto Nacional de Estadística de España) directamente en Stata.

#### Requisitos
- Stata

#### Codigos ejemplo
- `ine_min.do` es un ejemplo mínimo para descargar datos del INE directamente en Stata.

#### Inputs
- **Obligatorios**
  - `url`: URL directa del archivo CSV de la tabla del INE.

#### Cómo elegir inputs
1) Navegue a [INEbase](https://www.ine.es/).
2) Localice la tabla de interés.
3) Busque el botón de descarga y copie el enlace del formato CSV.
4) Asegúrese de que la URL termina en `.csv` o es el enlace de descarga directa.

#### Sintaxis de la API (INE)
- **Formato general:**
  ```
  https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/{TABLE_ID}.csv
  ```

- **Ejemplo:**
  ```
  https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/67821.csv
  ```

#### Output
- Un dataset en memoria de Stata con los datos descargados.

#### Enlaces útiles
- INE (Banco de datos): https://www.ine.es/


### ine_min.do

```stata
import delimited "https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/67821.csv", encoding("utf-8") clear
```

## OCDE

### Guía rápida: OECD con Stata

Este documento explica cómo descargar datos de la OCDE usando la API REST SDMX en Stata.

#### Requisitos
- Stata

#### Codigos ejemplo
- `ocde_min.do` es un ejemplo mínimo para descargar datos de la OCDE directamente en Stata.

#### Inputs
- **Obligatorios**
  - `agency_identifier`: p. ej., `"OECD.ECO.MAD"`.
  - `dataset_identifier`: p. ej., `"DSD_EO@DF_EO"`.
  - `data_selection`: clave SDMX tras la `/`.

- **Opcionales**
  - `startPeriod`, `endPeriod`.

#### Cómo elegir inputs
1) Buscar el dataset en el explorador OCDE: https://data-explorer.oecd.org/
2) Seleccionar las dimensiones que se quieren descargar y consultar la sección "Developer API" para obtener `Agency identifier`, `Dataset identifier` y `Dataset version`.
3) Construir la global `data_selection` con las dimensiones requeridas por el dataset (p. ej., `PAISES.VARIABLE.FRECUENCIA`).
4) Puede filtrar por periodo modificando las globales `startPeriod` y `endPeriod`.

#### Sintaxis de la API (OECD SDMX)
- **Formato general:**
  ```
  https://sdmx.oecd.org/public/rest/data/{agency},{dataset},{version}/{data_selection}?format=csvfile
  ```

#### Output
- Un dataset en memoria de Stata con los datos descargados.

#### Enlaces útiles
- Explorador OCDE: https://data-explorer.oecd.org/
- Documentación de la API: https://www.oecd.org/en/data/insights/data-explainers/2024/09/api.html


### ocde_min.do

```stata
global agency_identifier "OECD.ECO.MAD"
global dataset_identifier "DSD_EO@DF_EO"
global data_selection "FRA+DEU.PDTY.A"
global startPeriod "1965"
global endPeriod "2023"

import delimited "https://sdmx.oecd.org/public/rest/data/${agency_identifier},${dataset_identifier},/${data_selection}?format=csvfile&startPeriod=${startPeriod}&endPeriod=${endPeriod}", encoding("utf-8") clear  
```

## OURWORLDINDATA

### Guía rápida: Our World in Data con Stata

Este documento muestra cómo importar datos directamente desde los gráficos de Our World in Data (OWID) a Stata.

#### Requisitos
- Stata

#### Codigos ejemplo
- `worldindata_min.do` es un ejemplo mínimo para descargar datos de OWID directamente en Stata.

#### Inputs
- **Obligatorios**
  - `url`: URL directa del archivo CSV proporcionada por OWID para un gráfico específico.

#### Cómo elegir inputs
1) Vaya a un gráfico en [Our World in Data](https://ourworldindata.org/).
2) Haga clic en la pestaña "Download".
3) Haga clic derecho en el botón de descarga "Full data (CSV)" y seleccione "Copiar dirección del enlace".
4) Pegue esa URL en su comando `import delimited "URL", clear`.

#### Sintaxis de la API
- **Formato general:**
  ```
  https://ourworldindata.org/grapher/{chart-slug}.csv?v=1&csvType=full&useColumnShortNames=true
  ```

- **Ejemplo:**
  ```
  https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.csv?v=1&csvType=full&useColumnShortNames=true
  ```

#### Output
- Un dataset en memoria de Stata con los datos descargados.

#### Enlaces útiles
- Portal: https://ourworldindata.org/


### worldindata_min.do

```stata
import delimited "https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.csv?v=1&csvType=full&useColumnShortNames=true", encoding("utf-8") clear
```

## WORLDBANK

### Guía rápida: Banco Mundial con Stata

Este documento explica cómo descargar e importar indicadores del Banco Mundial manualmente en Stata, manejando archivos ZIP.

#### Requisitos
- Stata

#### Codigos ejemplo
- `worldbank_min.do` es un ejemplo mínimo para descargar y descomprimir datos del Banco Mundial en Stata.

#### Inputs
- **Obligatorios**
  - `indicator`: código del indicador (p. ej., `NY.GDP.MKTP.KD.ZG`).

#### Cómo elegir inputs
1) Elija el indicador (`indicator`)
   - Buscar en la web del World Bank la serie de interés. Seleccionar las variables y pinchar en `Metadata` -> `Series`. Copiar el codigo de la serie (p. ej. `NY.GDP.MKTP.KD.ZG`).
   - Busque indicadores en: https://api.worldbank.org/v2/indicator?format=json o en el portal de datos.
2) Use ese código para definir la global `indicator`.
3) El archivo CSV descargado tendrá un nombre basado en el indicador (ej. `API_NY.GDP...`). Deberá ajustar el nombre del archivo en el comando `import delimited`.

#### Sintaxis de la API (World Bank)
- **Formato general (ZIP con CSV):**
  ```
  https://api.worldbank.org/v2/en/indicator/{indicator}?downloadformat=csv
  ```

#### Output
- Un dataset en memoria de Stata con los datos del indicador.

#### Enlaces útiles
- Indicadores (API): https://datahelpdesk.worldbank.org/knowledgebase/articles/889392-about-the-indicators-api-documentation
- [World Bank Data API](https://datahelpdesk.worldbank.org/knowledgebase/topics/125589-developer-information)


### worldbank_min.do

```stata
global indicator "NY.GDP.MKTP.KD.ZG"


* 1. Download ZIP
copy "https://api.worldbank.org/v2/en/indicator/${indicator}?downloadformat=csv" ///
    "wb_gdp_growth.zip", replace

* 2. Unzip
unzipfile "wb_gdp_growth.zip", replace

* list files if you want to see exact name
dir

* 3. Import the main data CSV (adjust filename to what you see)
import delimited "API_${indicator}_DS2_en_csv_v2_260128.csv", ///
    varnames(1) rowrange(5) encoding(UTF-8) clear
```
