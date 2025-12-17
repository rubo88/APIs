# Guía rápida: FRED con R

Este documento explica cómo usar las funciones en `fred_function.R` para descargar datos desde FRED.

## Requisitos
- Paquetes `httr` y `jsonlite` instalados

## Codigos ejemplo
- `fred_onlylink.R` es un ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `fred_min.R` es un ejemplo mínimo que descarga un CSV de fredgraph sin usar la función.
- `fred_example.R` es un ejemplo de uso de ambas funciones (`fredgraph_api_function` y `fred_api_function`).

## Inputs
- **fredgraph_api_function**
  - `graphId` (Obligatorio): identificador del gráfico compartido en FRED.

- **fred_api_function**
  - `series_id` (Obligatorio): identificador de la serie (p. ej., `"GDP"`).
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
- `data.frame` con las observaciones devueltas por cada método.

## Parámetros detallados (fred_api_function)
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

## Como conseguir una API key
- Regístrese en FRED, vaya a "API keys" y solicite una key.
- Alternativa: use `fredgraph_api_function` que no requiere key.

## Enlaces útiles
- Referencia oficial: [FRED observations API docs](https://fred.stlouisfed.org/docs/api/fred/series_observations.html)
