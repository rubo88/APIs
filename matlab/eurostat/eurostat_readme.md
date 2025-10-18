# Guía rápida: Eurostat SDMX-CSV — `matlab/eurostat/eurostat_function.m`

Este documento explica cómo usar la función en `matlab/eurostat/eurostat_function.m` para descargar datos SDMX-CSV de Eurostat y obtenerlos como una tabla en MATLAB.

## Requisitos
- MATLAB (R2019b o superior recomendado)

## Inputs
- **Obligatorios**
  - `dataset_identifier`: identificador del dataset (p. ej., `"nama_10_a64"`).
  - `filters`: struct con dimensiones válidas del dataset (p. ej., `geo`, `na_item`, `unit`, `TIME_PERIOD`) mapeadas a valores (string o cellstr).

- **Opcionales**
  - `agency_identifier` (por defecto `"ESTAT"`)
  - `dataset_version` (por defecto `"1.0"`)
  - `compress` (por defecto `"false"`)
  - `format` (por defecto `"csvdata"`)
  - `formatVersion` (por defecto `"2.0"`)
  - `lang` (por defecto `"en"`)
  - `labels` (por defecto `"name"`)

## Output
- Una `table` con los datos descargados de Eurostat.

## Ejemplo de uso
```matlab
addpath('matlab');
filters = struct('geo', {{'IT'}}, 'na_item', {{'B1G'}}, 'unit', 'CLV20_MEUR', 'TIME_PERIOD', 'ge:1995');
T = eurostat_api_function('nama_10_a64', filters);
writetable(T, 'matlab/eurostat/eurostat_example.csv', 'FileType', 'text');
```

## Códigos ejemplo 
- `eurostat_min.m`: ejemplo mínimo para construir la URL SDMX-CSV y guardar en CSV.
- `eurostat_example.m`: ejemplo de uso de la función `eurostat_api_function` devolviendo una tabla y exportándola a CSV.

## Sintaxis del endpoint (SDMX-CSV 3.0)
Formato general:
```
https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/{agency}/{dataset}/{version}/?c[DIM]=v1,v2&format=csvdata&formatVersion=2.0
```

## Notas
- Los filtros deben usar nombres de dimensiones válidas del dataset.


