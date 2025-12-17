# Guía rápida: OECD con MATLAB

Este documento explica cómo usar la función en `matlab/oecd/oecd_function.m` para descargar datos SDMX CSV de OECD y obtenerlos como una tabla en MATLAB.

## Requisitos
- Ninguno adicional a MATLAB.

## Codigos ejemplo
- `oecd_onlylink.m`: ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `oecd_min.m`: ejemplo mínimo para construir la URL y guardar en CSV.
- `oecd_example.m`: ejemplo de uso de la función `oecd_api_function` devolviendo una tabla y exportándola a CSV.

## Inputs
- **Obligatorios**
  - `agency_identifier`: p. ej., `"OECD.ECO.MAD"`.
  - `dataset_identifier`: p. ej., `"DSD_EO@DF_EO"`.
  - `data_selection`: clave SDMX tras la `/`.

- **Opcionales**
  - `dataset_version` (por defecto `""`).
  - `startPeriod`, `endPeriod`, `dimensionAtObservation`.

## Cómo elegir inputs
1) Buscar el dataset en el explorador OCDE: https://data-explorer.oecd.org/
2) Seleccionar las dimensiones que se quieren descargar y consultar la sección "Developer API" para obtener `Agency identifier`, `Dataset identifier` y `Dataset version`.
3) Construir `data_selection` con las dimensiones requeridas por el dataset (p. ej., `PAISES.VARIABLE.FRECUENCIA`).
4) Ajustar parámetros opcionales (`startPeriod`, `endPeriod`, `dimensionAtObservation`).

## Sintaxis de la API (OECD SDMX)
- **Formato general:**
  ```
  https://sdmx.oecd.org/public/rest/data/{agency},{dataset},{version}/{data_selection}
  ```

## Output
- Una `table` con los datos descargados de OECD.

## Enlaces útiles
- Explorador OCDE: https://data-explorer.oecd.org/
- Documentación de la API: https://www.oecd.org/en/data/insights/data-explainers/2024/09/api.html
