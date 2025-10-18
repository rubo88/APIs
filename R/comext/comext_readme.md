# Guía rápida: Eurostat Comext — `comext/comext_function.R`

Este documento explica cómo usar la función en `comext/comext_function.R` para descargar datos del endpoint Comext de Eurostat (SDMX‑JSON) y obtenerlos como un data frame etiquetado en R.

## Requisitos
- R (≥ 4.0 recomendado)
- Paquetes `httr` y `jsonlite` instalados


## Inputs
- **Obligatorios**
  - `dataset_id`: identificador del dataset Comext (prefijo `"DS-"`, p. ej., `"DS-059341"`).
  - `filters`: lista NOMBRADA de filtros (dimensión -> valores). Los nombres deben ser las dimensiones válidas del dataset (p. ej., `reporter`, `partner`, `product`, `flow`, `freq`, `time`, `indicators`, ...). Los valores pueden ser `"string"` o vectores `c("...","...")`.

## Output
- Un `data.frame` con columnas por dimensión (códigos y `*_label`) y la columna `value`.


## Ejemplo de uso
```r
# 1) Cargar la función
source("comext/comext_function.R")

# 2) Ejecutar la consulta
df <- comext_api_function(
  dataset_id = "DS-059341",
  filters = list(
    reporter = c("ES"),
    partner  = c("US"),
    product  = c("1509", "8703"),
    flow     = c("2"),
    freq     = c("A"),
    time     = 2015:2020
  )
)

str(df)
```
## Codigos ejemplo 
El código `comext_min.R` es un ejemplo mínimo para descargar datos de Comext y convertirlos a CSV sin usar la función `comext_api_function`.
El código `comext_example.R` es un ejemplo de uso de la función `comext_api_function`.

## Cómo elegir inputs
1) Identifique el dataset en la guía de Comext y el portal de Eurostat.
2) Consulte la estructura del dataset en la guía Comext para conocer las dimensiones válidas y sus valores.
3) Ajuste `filters` con nombres de dimensiones válidos. Para múltiples valores use vectores.

## Funcion auxiliar para convertir JSON a data frame
La funcion `comext_json_to_labeled_df` es una funcion auxiliar para convertir el JSON a un data frame con columnas por dimensión (códigos y `*_label`) y la columna `value`.

## Sintaxis del endpoint (Comext statistics)
Formato general:
```
https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/{dataset_id}?reporter=...&partner=...&product=...&flow=...&freq=...&time=...
```

Ejemplo equivalente:
```
https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/DS-059341?reporter=ES&partner=US&product=1509&product=8703&flow=2&freq=A&time=2015&time=2016&...&time=2020
```

## Enlaces útiles
- Guía de Comext: https://ec.europa.eu/eurostat/web/user-guides/data-browser/api-data-access/api-getting-started/comext-database
- Portal Eurostat: https://ec.europa.eu/eurostat/


