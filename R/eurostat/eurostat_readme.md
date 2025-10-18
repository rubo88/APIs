# Guía rápida: Eurostat SDMX 3.0 (CSV) — `eurostat/eurostat_function.R`

Este documento explica cómo usar la función en `eurostat/eurostat_function.R` para descargar datos de la API SDMX 3.0 de Eurostat en formato CSV (SDMX-CSV 2.0) y obtenerlos como un data frame en R.

## Requisitos
- R (≥ 4.0 recomendado)
- Paquete `httr` instalado (`install.packages("httr")` si fuera necesario)


## Inputs
- **Obligatorios**
  - `dataset_identifier`: identificador del dataset (p. ej., `"nama_10_a64"`).
  - `filters`: lista nombrada de filtros SDMX. Tiene que tener formato `list(dim1 = c("val1", "val2"), dim2 = "val3", ...)`. Cada dim es una dimensión del dataset (p. ej., `geo`, `na_item`, `unit`, `freq`, `TIME_PERIOD`) y cada valor puede ser un string o un vector de strings (p. ej., `c("ES", "FR")` → `ES,FR`).

- **Opcionales**
  - `agency_identifier`: agencia mantenedora (por defecto `"ESTAT"`).
  - `dataset_version`: versión del dataset (por defecto `"1.0"`).
  - `compress`: `"false"` para CSV legible; `"true"` para respuesta comprimida.
  - `format`/`formatVersion`: para SDMX-CSV 2.0 use `"csvdata"` + `"2.0"` (valores por defecto).
  - `lang`: idioma de etiquetas (`"en"`, etc.).
  - `labels`: `"id"` (solo codigos), `"name"` (descripciones y codigos en columnas separadas), `"both"` (codigos y descripciones en una sola columna).

## Output
- Un `data.frame` con los datos descargados desde Eurostat.


## Ejemplo de uso
```r
# 1) Cargar la función
source("eurostat/eurostat_function.R")

# 2) Ejecutar la consulta
df <- eurostat_api_function(
  dataset_identifier = "nama_10_a64",
  filters = list(
    geo = c("ES", "FR"),
    na_item = c("B1G", "P1"),
    freq = "A",
    unit = "CLV20_MEUR",
    TIME_PERIOD = "ge:1995"
  ),
  # Opcionales (usando por defecto, pueden omitirse)
  agency_identifier = "ESTAT",
  dataset_version = "1.0",
  compress = "false",
  format = "csvdata",
  formatVersion = "2.0",
  lang = "en",
  labels = "name"
)

str(df)
```
## Codigos ejemplo 
El código `eurostat_min.R` es un ejemplo minimo para descargar datos de Eurostat sin usar la función `eurostat_api_function`.
El código `eurostat_example.R` es un ejemplo de uso de la función `eurostat_api_function`.

## Cómo elegir inputs
1) Lo más sencillo es ir a Eurostat, buscar la serie de interés y copiar el codigo de la serie. Mirar el codigo de las variables que nos interesan y los codigos de los valores que queremos filtrar. 
2) Usar el codigo de la serie como `dataset_identifier`.
3) Ajustar filtros (`filters`)
   - Añada o cambie dimensiones válidas del dataset (p. ej., `geo`, `na_item`, `unit`, `freq`, `TIME_PERIOD`).
   - Para valores múltiples use vectores en R: `c("ES", "FR")` 
   - En `TIME_PERIOD` puede usar operadores SDMX: `ge:YYYY`, `le:YYYY`, `YYYY:YYYY`, `ge:200Q1`, etc.
4) Cambiar parametros opcionales si es necesario.

## Sintaxis de la URL de la API (SDMX 3.0)
Formato general:
```
{base_url}/{agency_identifier}/{dataset_identifier}/{dataset_version}/?{filters_params}&{common_params}
```
Donde `base_url` es `https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow`.

Ejemplo equivalente:
```
https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/ESTAT/nama_10_a64/1.0/?c[geo]=ES,FR&c[na_item]=B1G,P1&c[freq]=A&c[unit]=CLV20_MEUR&c[TIME_PERIOD]=ge:1995&compress=false&format=csvdata&formatVersion=2.0&lang=en&labels=name
```

## Notas
- Si la API devuelve error, verifique que los códigos de dimensiones/valores sean válidos para el dataset escogido.
- `labels = "id"` devuelve códigos; `labels = "name"` devuelve descripciones legibles; `"both"` incluye ambos.
- `compress = "true"` puede reducir tamaño de respuesta, pero normalmente no es necesario para CSV pequeños.

## Enlaces útiles
- Guía de consultas de datos (SDMX 3.0, Eurostat): [API - Detailed guidelines - SDMX3.0 API - data query](https://ec.europa.eu/eurostat/web/user-guides/data-browser/api-data-access/api-detailed-guidelines/sdmx3-0/data-query)


