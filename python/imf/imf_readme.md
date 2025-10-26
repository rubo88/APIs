# Guía rápida: FMI SDMX-CSV — `python/imf_function.py`

Este documento explica cómo usar la función en `python/imf_function.py` para descargar datos SDMX-CSV de la API SDMX 3.0 del FMI y obtenerlos como un `pandas.DataFrame`.

## Requisitos
- Python 3.9+
- Paquetes: `requests`, `pandas`

## Inputs
- **Obligatorios**
  - `dataset_identifier`: identificador del dataset (p. ej., "QNEA").
  - `data_selection`: clave SDMX completa tras la `/` (orden y códigos según el dataset). Ej.: "ESP.B1GQ.Q.SA.XDC.Q" o múltiples países "ESP+FRA.B1GQ.Q.SA.XDC.Q".

- **Opcionales**
  - `filters` (dict): filtros SDMX convertidos a `c[DIM]`. Para varias condiciones use `+`:
    - `{ 'TIME_PERIOD': ['ge:2020-Q1','le:2020-Q4'] }` → `c[TIME_PERIOD]=ge:2020-Q1+le:2020-Q4`
  - `agency_identifier`: por defecto "IMF.STA".
  - `dataset_version`: por defecto "+" (última versión).
  - `accept_csv_version`: por defecto "1.0.0".
  - `base_url`: por defecto "https://api.imf.org/external/sdmx/3.0/data/dataflow".

## Output
- Un `pandas.DataFrame` con los datos descargados en formato SDMX-CSV.

## Ejemplo de uso
```python
from imf_function import imf_api_function

df = imf_api_function(
    dataset_identifier="QNEA",
    data_selection="ESP+FRA.B1GQ.Q.SA.XDC.Q",
    filters={"TIME_PERIOD": ["ge:2020-Q1", "le:2020-Q4"]},
)

df.to_csv("python/imf_example.csv", index=False)
```

## Códigos ejemplo 
- `imf_min.py`: ejemplo mínimo para construir la URL SDMX-CSV y guardar en CSV.
- `imf_example.py`: ejemplo de uso de la función `imf_api_function` devolviendo un DataFrame y exportándolo a CSV.

## Sintaxis del endpoint (FMI SDMX 3.0)
Formato general (CSV):
```
https://api.imf.org/external/sdmx/3.0/data/dataflow/{agency}/{dataset}/{version}/{key}?c[DIM]=...
```
- Acepte CSV con la cabecera `Accept: application/vnd.sdmx.data+csv;version=1.0.0`.
- Use `+` para unir múltiples valores o condiciones en un mismo `c[DIM]`.

## Notas
- Los filtros `c[DIM]` solo aplican a dimensiones que queden comodín en la clave; si fija `COUNTRY` en la clave, `c[COUNTRY]` no surtirá efecto.
- Para seleccionar múltiples países, una forma robusta es ponerlos en la clave con `+` (p. ej., `ESP+FRA....`).
