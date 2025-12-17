# Guía rápida: Eurostat con MATLAB

Este documento explica cómo usar la función en `matlab/eurostat/eurostat_function.m` para descargar datos SDMX-CSV de Eurostat y obtenerlos como una tabla en MATLAB.

## Requisitos
- Ninguno adicional a MATLAB.

## Codigos ejemplo
- `eurostat_onlylink.m`: ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `eurostat_min.m`: ejemplo mínimo para construir la URL SDMX-CSV y guardar en CSV.
- `eurostat_example.m`: ejemplo de uso de la función `eurostat_api_function` devolviendo una tabla y exportándola a CSV.

## Inputs
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

## Cómo elegir inputs
1) Lo más sencillo es ir a Eurostat, buscar la serie de interés y copiar el codigo de la serie. Mirar el codigo de las variables que nos interesan y los codigos de los valores que queremos filtrar.
2) Usar el codigo de la serie como `dataset_identifier`.
3) Ajustar filtros (`filters`).
   - Añada o cambie dimensiones válidas del dataset (p. ej., `geo`, `na_item`, `unit`, `freq`, `TIME_PERIOD`).
   - Para valores múltiples use cell arrays en MATLAB: `{'ES', 'FR'}`.
   - En `TIME_PERIOD` puede usar operadores SDMX: `ge:YYYY`, `le:YYYY`, `YYYY:YYYY`, `ge:200Q1`, etc.
4) Cambiar parametros opcionales si es necesario.

## Sintaxis de la API (SDMX-CSV 3.0)
- **Formato general:**
  ```
  https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/{agency}/{dataset}/{version}/?c[DIM]=v1,v2&format=csvdata&formatVersion=2.0
  ```

## Output
- Una `table` con los datos descargados de Eurostat.

## Notas
- Los filtros deben usar nombres de dimensiones válidas del dataset.
