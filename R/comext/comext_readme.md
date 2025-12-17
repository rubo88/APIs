# Guía rápida: Eurostat Comext con R

Este documento explica cómo usar la función en `comext/comext_function.R` para descargar datos del endpoint Comext de Eurostat (SDMX‑JSON) y obtenerlos como un data frame etiquetado en R.

## Requisitos
- Paquetes `httr` y `jsonlite` instalados

## Codigos ejemplo
- `comext_min.R` es un ejemplo mínimo para descargar datos de Comext y convertirlos a CSV sin usar la función `comext_api_function`.
- `comext_example.R` es un ejemplo de uso de la función `comext_api_function`.

## Inputs
- **Obligatorios**
  - `dataset_id`: identificador del dataset Comext (prefijo `"DS-"`, p. ej., `"DS-059341"`).
  - `filters`: lista NOMBRADA de filtros (dimensión -> valores). Los nombres deben ser las dimensiones válidas del dataset (p. ej., `reporter`, `partner`, `product`, `flow`, `freq`, `time`, `indicators`, ...). Los valores pueden ser `"string"` o vectores `c("...","...")`.

## Cómo elegir inputs
1) Identifique el dataset en la guía de Comext y el portal de Eurostat.
2) Consulte la estructura del dataset en la guía Comext para conocer las dimensiones válidas y sus valores.
3) Ajuste `filters` con nombres de dimensiones válidos. Para múltiples valores use vectores.

## Sintaxis de la API (Comext statistics)
- **Formato general:**
  ```
  https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/{dataset_id}?reporter=...&partner=...&product=...&flow=...&freq=...&time=...
  ```

- **Ejemplo:**
  ```
  https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/DS-059341?reporter=ES&partner=US&product=1509&product=8703&flow=2&freq=A&time=2015&time=2016&...&time=2020
  ```

## Output
- Un `data.frame` con columnas por dimensión (códigos y `*_label`) y la columna `value`.

## Funcion auxiliar para convertir JSON a data frame
La funcion `comext_json_to_labeled_df` es una funcion auxiliar para convertir el JSON a un data frame con columnas por dimensión (códigos y `*_label`) y la columna `value`.

## Enlaces útiles
- Guía de Comext: https://ec.europa.eu/eurostat/web/user-guides/data-browser/api-data-access/api-getting-started/comext-database
- Portal Eurostat: https://ec.europa.eu/eurostat/
