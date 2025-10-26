# Guía rápida: FMI SDMX-CSV — `matlab/imf/imf_api_function.m`

Este documento explica cómo usar la función en `matlab/imf/imf_api_function.m` para descargar datos SDMX-CSV de la API SDMX 3.0 del FMI y obtenerlos como una tabla en MATLAB.

## Requisitos
- MATLAB (R2019b o superior recomendado)

## Inputs
- **Obligatorios**
  - `dataset_identifier`: identificador del dataset (p. ej., "QNEA").
  - `data_selection`: clave SDMX completa tras la `/` (orden y códigos según el dataset). Ej.: "ESP.B1GQ.Q.SA.XDC.Q" o múltiples países "ESP+FRA.B1GQ.Q.SA.XDC.Q".

- **Opcionales**
  - `filters` (struct): filtros SDMX convertidos a `c[DIM]`. Para varias condiciones use `+`:
    - `struct('TIME_PERIOD', {'ge:2020-Q1','le:2020-Q4'})` → `c[TIME_PERIOD]=ge:2020-Q1+le:2020-Q4`
  - `agency_identifier`: por defecto "IMF.STA".
  - `dataset_version`: por defecto "+" (última versión).
  - `accept_csv_version`: por defecto "1.0.0".
  - `base_url`: por defecto "https://api.imf.org/external/sdmx/3.0/data/dataflow".

## Output
- Una `table` con los datos descargados en formato SDMX-CSV.

## Ejemplo de uso
```matlab
addpath('matlab');
T = imf_api_function(
    'QNEA', ...                                % dataset_identifier
    'ESP+FRA.B1GQ.Q.SA.XDC.Q', ...             % data_selection (clave SDMX)
    struct('TIME_PERIOD', {'ge:2020-Q1','le:2020-Q4'}) ... % filtros c[DIM]
);
writetable(T, 'matlab/imf/imf_example.csv', 'FileType', 'text');
```

## Códigos ejemplo 
- `imf_min.m`: ejemplo mínimo para construir la URL SDMX-CSV y guardar en CSV.
- `imf_example.m`: ejemplo de uso de la función `imf_api_function` devolviendo una tabla y exportándola a CSV.


## Cómo elegir inputs
1) Localice el dataset y el indicador en el portal del FMI o en la documentación de SDMX.
2) Construya la `key` con las dimensiones requeridas por el dataset. En IFS suele ser `FREQ.REF_AREA.INDICATOR`.
3) Use `startPeriod` y `endPeriod` para acotar el periodo temporal si lo necesita.


## Sintaxis del endpoint (FMI SDMX 3.0)
Formato general (CSV):
```
https://api.imf.org/external/sdmx/3.0/data/{context}/{agencyID}/{resourceID}/{version}/{key}[?c][&updatedAfter][&firstNObservations][&lastNObservations][&dimensionAtObservation][&attributes][&measures][&includeHistory][&asOf]
```

## Enlaces útiles
- Conocimiento/soporte del FMI (categoría API/SDMX): https://datasupport.imf.org/knowledge?id=knowledge_category&sys_kb_id=d41858e747294ad8805d07c4f16d43e0&category_id=9959b2bc1b6391903dba646fbd4bcb6a
- Servicio SDMX JSON del FMI: `https://dataservices.imf.org/REST/SDMX_JSON.svc`
