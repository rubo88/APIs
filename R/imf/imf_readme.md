# Guía rápida: FMI SDMX (JSON) — `imf/imf_function.R`

Este documento explica cómo usar la función en `imf/imf_function.R` para descargar datos del FMI (servicio SDMX-JSON CompactData) y obtenerlos como un data frame en R.

## Requisitos
- R (≥ 4.0 recomendado)
- Paquetes `httr` y `jsonlite` instalados

## Inputs
- **Obligatorios**
  - `dataset`: identificador del dataset SDMX del FMI, p. ej., "IFS" (International Financial Statistics).
  - `key`: clave SDMX con dimensiones concatenadas por punto `.`. El patrón típico en IFS es `Frecuencia.País.Indicador` (p. ej., "M.ES.PCPI_IX").

- **Opcionales**
  - `startPeriod`, `endPeriod`: límites de periodo (p. ej., "2018", "2023").
  - `base_url`: host del servicio SDMX del FMI (por defecto "https://dataservices.imf.org/REST/SDMX_JSON.svc").

## Output
- Un `data.frame` con columnas de dimensiones devueltas por la serie (por ejemplo `FREQ`, `REF_AREA`, `INDICATOR` si están presentes en la respuesta), más `TIME_PERIOD` y `OBS_VALUE`.

## Ejemplo de uso
```r
# 1) Cargar la función
source("imf/imf_function.R")

# 2) Ejecutar la consulta (IPC mensual de España, 2018–2023)
df <- imf_api_function(
  dataset = "IFS",
  key = "M.ES.PCPI_IX",
  startPeriod = "2018",
  endPeriod = "2023"
)

str(df)
```

## Códigos ejemplo
- `imf_onlylink.R`: ejemplo que descarga y lee el csv directamente del link de la API en una linea (usando `rsdmx`).
- `imf_min.R`: ejemplo mínimo que descarga y guarda CSV sin usar la función `imf_api_function`.
- `imf_example.R`: ejemplo de uso de la función `imf_api_function` y guardado de CSV.

## Cómo elegir inputs
1) Localice el dataset y el indicador en el portal del FMI o en la documentación de SDMX.
2) Construya la `key` con las dimensiones requeridas por el dataset. En IFS suele ser `FREQ.REF_AREA.INDICATOR`.
3) Use `startPeriod` y `endPeriod` para acotar el periodo temporal si lo necesita.

## Sintaxis de la API (FMI SDMX CompactData)
Formato general:
```
https://api.imf.org/external/sdmx/3.0/data/{context}/{agencyID}/{resourceID}/{version}/{key}[?c][&updatedAfter][&firstNObservations][&lastNObservations][&dimensionAtObservation][&attributes][&measures][&includeHistory][&asOf]
```


## Enlaces útiles
- Conocimiento/soporte del FMI (categoría API/SDMX): https://datasupport.imf.org/knowledge?id=knowledge_category&sys_kb_id=d41858e747294ad8805d07c4f16d43e0&category_id=9959b2bc1b6391903dba646fbd4bcb6a
- Servicio SDMX JSON del FMI: `https://dataservices.imf.org/REST/SDMX_JSON.svc`
