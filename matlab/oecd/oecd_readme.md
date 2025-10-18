# Guía rápida: OECD SDMX CSV — `matlab/oecd/oecd_function.m`

Este documento explica cómo usar la función en `matlab/oecd/oecd_function.m` para descargar datos SDMX CSV de OECD y obtenerlos como una tabla en MATLAB.

## Requisitos
- MATLAB (R2019b o superior recomendado)

## Inputs
- **Obligatorios**
  - `agency_identifier`: p. ej., `"OECD.ECO.MAD"`.
  - `dataset_identifier`: p. ej., `"DSD_EO@DF_EO"`.
  - `data_selection`: clave SDMX tras la `/`.

- **Opcionales**
  - `base_url` (por defecto `"https://sdmx.oecd.org/public/rest/data"`)
  - `dataset_version` (por defecto `""`)
  - `startPeriod`, `endPeriod`, `dimensionAtObservation`

## Output
- Una `table` con los datos descargados de OECD.

## Ejemplo de uso
```matlab
addpath('matlab');
T = oecd_api_function('OECD.ECO.MAD', 'DSD_EO@DF_EO', '...');
writetable(T, 'matlab/oecd/oecd_example.csv', 'FileType', 'text');
```

## Códigos ejemplo 
- `oecd_min.m`: ejemplo mínimo para construir la URL y guardar en CSV.
- `oecd_example.m`: ejemplo de uso de la función `oecd_api_function` devolviendo una tabla y exportándola a CSV.

## Sintaxis del endpoint (OECD SDMX)
Formato general:
```
https://sdmx.oecd.org/public/rest/data/{agency},{dataset},{version}/{data_selection}
```


