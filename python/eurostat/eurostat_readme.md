# Guía rápida: Eurostat SDMX 3.0 (CSV) — `python/eurostat/eurostat_function.py`
Este documento explica cómo usar `python/eurostat/eurostat_function.py` para descargar datos Eurostat en formato SDMX-CSV 2.0 y obtener un `pandas.DataFrame`.

## Requisitos
- Python ≥ 3.8
- Paquetes: `requests`, `pandas`

```bash
pip install requests pandas
```

## Inputs
- **Obligatorios**
  - `dataset_identifier`: identificador del dataset.
  - `filters`: diccionario de filtros (c[dim] en R), por ejemplo `{"geo": ["IT"], ...}`.

- **Opcionales**
  - `agency_identifier` (por defecto `"ESTAT"`), `dataset_version` (`"1.0"`), `compress`, `format`, `formatVersion`, `lang`, `labels`.

## Output
- Un `pandas.DataFrame` con los datos descargados.

## Ejemplo de uso
```python
from eurostat_function import eurostat_api_function

df = eurostat_api_function(
    dataset_identifier="nama_10_a64",
    filters={
        "geo": ["IT"],
        "na_item": ["B1G"],
        "unit": "CLV20_MEUR",
        "TIME_PERIOD": "ge:1995",
    },
)
df.to_csv("eurostat_ejemplo.csv", index=False)
```

## Notas
- Se usa el encabezado `Accept: application/vnd.sdmx.data+csv; version=2.0.0`.

## Códigos ejemplo 
- `eurostat_min.py` es un ejemplo mínimo para descargar datos de Eurostat sin usar la función `eurostat_api_function`.
- `eurostat_example.py` es un ejemplo de uso de la función `eurostat_api_function`.

## Cómo elegir inputs
1) Lo más sencillo es ir a Eurostat, buscar la serie de interés y copiar el código de la serie. Mire el código de las variables y los valores a filtrar.
2) Use el código de la serie como `dataset_identifier`.
3) Ajuste filtros (`filters`):
   - Añada o cambie dimensiones válidas del dataset (p. ej., `geo`, `na_item`, `unit`, `freq`, `TIME_PERIOD`).
   - Para valores múltiples use listas en Python: `["ES", "FR"]`.
   - En `TIME_PERIOD` puede usar operadores SDMX: `ge:YYYY`, `le:YYYY`, `YYYY:YYYY`, `ge:200Q1`, etc.
4) Cambie parámetros opcionales si es necesario.

## Sintaxis de la URL de la API (SDMX 3.0)
Formato general:
```
{base_url}/{agency_identifier}/{dataset_identifier}/{dataset_version}/?{filters_params}&{common_params}
```
Donde `base_url` es `https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow`.

Ejemplo equivalente:
```
https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/ESTAT/nama_10_a64/1.0/?c[geo]=ES,FR&c[na_item]=B1G,P1&c[freq]=A&c[unit]=CLV20_MEUR&c[TIME_PERIOD]=ge:1995&compress=false&format=csvdata&formatVersion=2.0&lang=en&labels=name
```


