# Guía rápida: OECD con Stata

Este documento explica cómo descargar datos de la OCDE usando la API REST SDMX en Stata.

## Requisitos
- Stata

## Codigos ejemplo
- `ocde_min.do` es un ejemplo mínimo para descargar datos de la OCDE directamente en Stata.

## Inputs
- **Obligatorios**
  - `agency_identifier`: p. ej., `"OECD.ECO.MAD"`.
  - `dataset_identifier`: p. ej., `"DSD_EO@DF_EO"`.
  - `data_selection`: clave SDMX tras la `/`.

- **Opcionales**
  - `startPeriod`, `endPeriod`.

## Cómo elegir inputs
1) Buscar el dataset en el explorador OCDE: https://data-explorer.oecd.org/
2) Seleccionar las dimensiones que se quieren descargar y consultar la sección "Developer API" para obtener `Agency identifier`, `Dataset identifier` y `Dataset version`.
3) Construir la global `data_selection` con las dimensiones requeridas por el dataset (p. ej., `PAISES.VARIABLE.FRECUENCIA`).
4) Puede filtrar por periodo modificando las globales `startPeriod` y `endPeriod`.

## Sintaxis de la API (OECD SDMX)
- **Formato general:**
  ```
  https://sdmx.oecd.org/public/rest/data/{agency},{dataset},{version}/{data_selection}?format=csvfile
  ```

## Output
- Un dataset en memoria de Stata con los datos descargados.

## Enlaces útiles
- Explorador OCDE: https://data-explorer.oecd.org/
- Documentación de la API: https://www.oecd.org/en/data/insights/data-explainers/2024/09/api.html
