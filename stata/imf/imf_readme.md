# Guía rápida: FMI con Stata

Este documento explica cómo usar el script `imf/imf_min.do` para descargar datos del FMI (servicio SDMX 3.0) directamente en Stata.

## Requisitos
- Stata (con capacidad de conexión a internet y comando `import delimited`).

## Codigos ejemplo
- `imf_min.do` es un ejemplo mínimo para descargar datos del FMI directamente en Stata.

## Inputs
- **Obligatorios**
  - `dataset_identifier`: identificador del dataset (p. ej., "QNEA").
  - `key`: clave SDMX completa (orden y códigos según el dataset). Ej.: "ESP+FRA.B1GQ.Q.SA.XDC.Q".
  - `agency_identifier`: por defecto "IMF.STA".
  - `dataset_version`: por defecto "+" (última versión).

## Cómo elegir inputs
1) Localice el dataset y el indicador en el portal del FMI o en la documentación de SDMX.
2) Construya la `key` con las dimensiones requeridas por el dataset. En IFS suele ser `FREQ.REF_AREA.INDICATOR`.
3) La estructura de la URL es `.../data/dataflow/{agency_identifier}/{dataset_identifier}/{dataset_version}/{key}`.

## Sintaxis de la API (FMI SDMX 3.0)
- **Formato general:**
  ```
  https://api.imf.org/external/sdmx/3.0/data/dataflow/{agency_identifier}/{dataset_identifier}/{dataset_version}/{key}
  ```
  Referencia al servicio SDMX JSON del FMI: `https://dataservices.imf.org/REST/SDMX_JSON.svc`

## Output
- Un dataset en memoria de Stata con los datos descargados.

## Enlaces útiles
- Conocimiento/soporte del FMI (categoría API/SDMX): https://datasupport.imf.org/knowledge?id=knowledge_category&sys_kb_id=d41858e747294ad8805d07c4f16d43e0&category_id=9959b2bc1b6391903dba646fbd4bcb6a
