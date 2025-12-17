# Guía rápida: FMI con Python

Este documento explica cómo usar la función en `python/imf/imf_function.py` para descargar datos SDMX-CSV de la API SDMX 3.0 del FMI y obtenerlos como un `pandas.DataFrame`.

## Requisitos
- Paquetes: `requests`, `pandas`

## Codigos ejemplo
- `imf_onlylink.py`: ejemplo que descarga y lee el csv directamente del link de la API en una linea (usando `pandasdmx`).
- `imf_min.py`: ejemplo mínimo para construir la URL SDMX-CSV y guardar en CSV.
- `imf_example.py`: ejemplo de uso de la función `imf_api_function` devolviendo un DataFrame y exportándolo a CSV.

## Inputs
- **Obligatorios**
  - `dataset_identifier`: identificador del dataset (p. ej., "QNEA").
  - `data_selection`: clave SDMX completa tras la `/` (orden y códigos según el dataset). Ej.: "ESP.B1GQ.Q.SA.XDC.Q" o múltiples países "ESP+FRA.B1GQ.Q.SA.XDC.Q".

- **Opcionales**
  - `filters` (dict): filtros SDMX convertidos a `c[DIM]`. Para varias condiciones use `+`.
  - `agency_identifier`: por defecto "IMF.STA".
  - `dataset_version`: por defecto "+" (última versión).
  - `accept_csv_version`: por defecto "1.0.0".

## Cómo elegir inputs
1) Localice el dataset y el indicador en el portal del FMI o en la documentación de SDMX.
2) Construya la `key` con las dimensiones requeridas por el dataset.
3) Use `filters` para condiciones adicionales.

## Sintaxis de la API (FMI SDMX 3.0)
- **Formato general (CSV):**
  ```
  https://api.imf.org/external/sdmx/3.0/data/dataflow/{agency}/{dataset}/{version}/{key}?c[DIM]=...
  ```
  Referencia al servicio SDMX JSON del FMI: `https://dataservices.imf.org/REST/SDMX_JSON.svc`

- **Ejemplo:**
  ```
  https://api.imf.org/external/sdmx/3.0/data/dataflow/IMF.STA/QNEA/+/ESP+FRA.B1GQ.Q.SA.XDC.Q?c[TIME_PERIOD]=ge:2020-Q1
  ```

## Output
- Un `pandas.DataFrame` con los datos descargados en formato SDMX-CSV.

## Notas
- Los filtros `c[DIM]` solo aplican a dimensiones que queden comodín en la clave; si fija `COUNTRY` en la clave, `c[COUNTRY]` no surtirá efecto.
- Para seleccionar múltiples países, una forma robusta es ponerlos en la clave con `+` (p. ej., `ESP+FRA....`).

## Enlaces útiles
- Conocimiento/soporte del FMI (categoría API/SDMX): https://datasupport.imf.org/knowledge?id=knowledge_category&sys_kb_id=d41858e747294ad8805d07c4f16d43e0&category_id=9959b2bc1b6391903dba646fbd4bcb6a
