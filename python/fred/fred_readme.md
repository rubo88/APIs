# Guía rápida: FRED con Python

Este documento explica cómo usar las funciones en `python/fred/fred_function.py` para descargar datos desde FRED.

## Requisitos
- Paquetes: `requests`, `pandas`

## Codigos ejemplo
- `fred_onlylink.py` es un ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `fred_min.py` es un ejemplo mínimo para descargar datos de FRED sin usar la función.
- `fred_example.py` es un ejemplo de uso de la función `fred_api_function`.

## Inputs
- **fredgraph_api_function**
  - `graph_id` (Obligatorio): identificador del gráfico compartido en FRED.

- **fred_api_function**
  - `series_id` (Obligatorio): identificador de la serie (p. ej., `"GDP"`).
  - Opcionales: `observation_start`, `observation_end`, `realtime_start`, `realtime_end`, `limit`, `offset`, `sort_order`, `units`, `frequency`, `aggregation_method`, `output_type`, `vintage_dates`, `api_key`.

## Cómo elegir inputs
- Para `fredgraph_api_function`:
  - Obtenga `graph_id` desde el enlace compartido del gráfico (parámetro `?g=` en la URL).

- Para `fred_api_function`:
  1) Elija `series_id` (p. ej., `GDP`, esto suele estar al lado del nombre de la serie en FRED entre paréntesis).
  2) Defina `FRED_API_KEY` como variable de entorno o pásela como argumento.
  3) Si es necesario, cambie los otros parámetros opcionales.

## Sintaxis de la API
- **fredgraph CSV:**
  ```
  https://fred.stlouisfed.org/graph/fredgraph.csv?g={graphId}
  ```
- **API v1 observaciones:**
  ```
  https://api.stlouisfed.org/fred/series/observations?series_id={id}&api_key=...&file_type=json
  ```

## Output
- `pandas.DataFrame` con las observaciones devueltas por cada método.

## Notas
- La API v1 admite parámetros como `units`, `frequency`, `aggregation_method`, etc. con validación básica.

## Enlaces útiles
- Referencia oficial: [FRED observations API docs](https://fred.stlouisfed.org/docs/api/fred/series_observations.html)
