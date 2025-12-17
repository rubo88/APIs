# Guía rápida: FMI con MATLAB

Este documento explica cómo usar la función en `matlab/imf/imf_api_function.m` para descargar datos SDMX-CSV de la API SDMX 3.0 del FMI y obtenerlos como una tabla en MATLAB.

## Requisitos
- Ninguno adicional a MATLAB.

## Codigos ejemplo
- `imf_onlylink.m`: ejemplo que descarga y lee el xml directamente del link de la API en una linea (usando `webread`).
- `imf_min.m`: ejemplo mínimo para construir la URL SDMX-CSV y guardar en CSV.
- `imf_example.m`: ejemplo de uso de la función `imf_api_function` devolviendo una tabla y exportándola a CSV.

## Inputs
- **Obligatorios**
  - `dataset_identifier`: identificador del dataset (p. ej., "QNEA").
  - `data_selection`: clave SDMX completa tras la `/` (orden y códigos según el dataset). Ej.: "ESP.B1GQ.Q.SA.XDC.Q" o múltiples países "ESP+FRA.B1GQ.Q.SA.XDC.Q".

- **Opcionales**
  - `filters` (struct): filtros SDMX convertidos a `c[DIM]`. Para varias condiciones use `+`.
  - `agency_identifier`: por defecto "IMF.STA".
  - `dataset_version`: por defecto "+" (última versión).
  - `accept_csv_version`: por defecto "1.0.0".

## Cómo elegir inputs
1) Localice el dataset y el indicador en el portal del FMI o en la documentación de SDMX.
2) Construya la `key` con las dimensiones requeridas por el dataset. En IFS suele ser `FREQ.REF_AREA.INDICATOR`.
3) Use `filters` si necesita condiciones adicionales.

## Sintaxis de la API (FMI SDMX 3.0)
- **Formato general (CSV):**
  ```
  https://api.imf.org/external/sdmx/3.0/data/{context}/{agencyID}/{resourceID}/{version}/{key}[?c][&updatedAfter][&firstNObservations][&lastNObservations][&dimensionAtObservation][&attributes][&measures][&includeHistory][&asOf]
  ```
  Referencia al servicio SDMX JSON del FMI: `https://dataservices.imf.org/REST/SDMX_JSON.svc`

## Output
- Una `table` con los datos descargados en formato SDMX-CSV.

## Enlaces útiles
- Conocimiento/soporte del FMI (categoría API/SDMX): https://datasupport.imf.org/knowledge?id=knowledge_category&sys_kb_id=d41858e747294ad8805d07c4f16d43e0&category_id=9959b2bc1b6391903dba646fbd4bcb6a
