# Guía rápida: Eurostat con Stata

Este documento explica cómo descargar datos de Eurostat directamente en Stata usando la API SDMX 3.0 de diseminación.

## Requisitos
- Stata

## Codigos ejemplo
- `eurostat_min.do` es un ejemplo mínimo para descargar datos de Eurostat directamente en Stata.

## Inputs
- **Obligatorios**
  - `agency_identifier`: identificador de la agencia (p. ej., `"ESTAT"`).
  - `dataset_identifier`: identificador del dataset (p. ej., `"nama_10_a64"`).
  - `filters`: filtros en formato URL query string (p. ej., `?c[geo]=ES`).

## Cómo elegir inputs
1) Lo más sencillo es ir a Eurostat, buscar la serie de interés y copiar el codigo de la serie. Mirar el codigo de las variables que nos interesan y los codigos de los valores que queremos filtrar.
2) Usar el codigo de la serie como `dataset_identifier`.
3) Ajustar la global `filters` con formato URL query string:
   - Use `c[DIMENSION]=VALOR`.
   - Para valores múltiples use comas: `c[geo]=ES,FR`.
   - En `TIME_PERIOD` puede usar operadores SDMX: `ge:YYYY`, `le:YYYY`.
   - Ejemplo: `?c[geo]=ES&c[unit]=EUR`.

## Sintaxis de la API (SDMX 3.0)
- **Formato general:**
  ```
  https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/{agency_identifier}/{dataset_identifier}/1.0/{filters}&compress=false&format=csvdata&formatVersion=2.0&lang=en&labels=name
  ```

- **Ejemplo:**
  ```
  https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/ESTAT/nama_10_a64/1.0/?c[geo]=ES&c[unit]=CLV_I20&compress=false&format=csvdata&formatVersion=2.0
  ```

## Output
- Un dataset en memoria de Stata con los datos descargados.

## Enlaces útiles
- Guía de consultas de datos (SDMX 3.0, Eurostat): [API - Detailed guidelines - SDMX3.0 API - data query](https://ec.europa.eu/eurostat/web/user-guides/data-browser/api-data-access/api-detailed-guidelines/sdmx3-0/data-query)
- [Eurostat API Setup](https://wikis.ec.europa.eu/display/EUROSTATHELP/API+SDMX+3.0+-+Data+retrieval)
