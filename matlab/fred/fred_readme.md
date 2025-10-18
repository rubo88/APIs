# Guía rápida: FRED — `matlab/fred/fred_function.m`

Este documento explica cómo usar las funciones en `matlab/fred/fred_function.m` para descargar datos desde FRED, tanto con el método "fredgraph" (CSV de un gráfico compartido, sin API key) como con la API v1 (JSON, requiere API key) y obtenerlos como tablas en MATLAB.

## Requisitos
- MATLAB (R2019b o superior recomendado)

## Inputs
- **fredgraph_api_function**
  - Obligatorio: `graphId` (identificador del gráfico compartido)

- **fred_api_function**
  - Obligatorio: `series_id` (p. ej., `"GDP"`)
  - Opcionales: `observation_start`, `observation_end`, `realtime_start`, `realtime_end`, `limit`, `offset`, `sort_order`, `units`, `frequency`, `aggregation_method`, `output_type`, `vintage_dates`, `api_key`.

## Output
- `table` con las observaciones devueltas por cada método.

## Ejemplo de uso
```matlab
addpath('matlab');
T_graph = fredgraph_api_function('1wmdD');
% setenv('FRED_API_KEY','SU_API_KEY');
T_api = fred_api_function('GDP');
writetable(T_graph, 'matlab/fred/fred_graph_example.csv', 'FileType', 'text');
writetable(T_api,   'matlab/fred/fred_api_example.csv',   'FileType', 'text');
```

## Códigos ejemplo 
- `fred_min.m`: ejemplo mínimo que descarga un CSV de fredgraph.
- `fred_example.m`: ejemplo de uso de ambas funciones.

## Endpoints
- fredgraph CSV: `https://fred.stlouisfed.org/graph/fredgraph.csv?g={graphId}`
- API v1 observaciones: `https://api.stlouisfed.org/fred/series/observations?series_id={id}&api_key=...&file_type=json`


