# Guía rápida: FRED con MATLAB

Este documento explica cómo usar las funciones en `matlab/fred/fred_function.m` para descargar datos desde FRED.

## Requisitos
- Ninguno adicional a MATLAB.

## Codigos ejemplo
- `fred_onlylink.m`: ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `fred_min.m`: ejemplo mínimo que descarga un CSV de fredgraph.
- `fred_example.m`: ejemplo de uso de ambas funciones.

## Inputs
- **fredgraph_api_function**
  - `graphId`: identificador del gráfico compartido (obligatorio).

- **fred_api_function**
  - `series_id`: identificador de la serie (p. ej., `"GDP"`).
  - Opcionales: `observation_start`, `observation_end`, `realtime_start`, `realtime_end`, `limit`, `offset`, `sort_order`, `units`, `frequency`, `aggregation_method`, `output_type`, `vintage_dates`, `api_key`.

## Cómo elegir inputs
- Para `fredgraph_api_function`:
  - Obtenga `graphId` desde el enlace compartido del gráfico (parámetro `?g=` en la URL).

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
- `table` con las observaciones devueltas por cada método.
