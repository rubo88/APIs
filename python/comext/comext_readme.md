# Guía rápida: Eurostat Comext con Python

Este documento explica cómo usar la función en `python/comext/comext_function.py` para descargar datos desde el endpoint Eurostat COMEXT en JSON y convertirlos a un `pandas.DataFrame` etiquetado.

## Requisitos
- Paquetes: `requests`, `pandas`

## Codigos ejemplo
- `comext_min.py`: ejemplo mínimo que descarga y guarda `comext_min.csv`.
- `comext_example.py`: ejemplo de uso de la función `comext_api_function` (implícito en la descripción).

## Inputs
- **Obligatorios**
  - `dataset_id`: id del dataset Comext (p. ej., `"DS-059341"`).
  - `filters`: diccionario nombrado dimensión -> lista de valores. Para multiselección se envían parámetros repetidos.

## Cómo elegir inputs
1) Identifique el dataset en la guía de Comext y el portal de Eurostat.
2) Consulte la estructura del dataset en la guía Comext para conocer las dimensiones válidas y sus valores.
3) Ajuste `filters` con nombres de dimensiones válidos. Para múltiples valores use listas (enviamos parámetros repetidos).

## Sintaxis de la API (COMEXT)
- **Formato general:**
  ```
  https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/{dataset_id}?{dim}={val}&{dim}={val}...
  ```

- **Ejemplo:**
  ```
  https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/DS-059341?reporter=ES&partner=US&product=1509&product=8703&flow=2&freq=A&time=2015&time=2016
  ```

## Output
- Un `pandas.DataFrame` con códigos por dimensión, columnas de etiquetas `*_label` y la columna numérica `value`.

## Notas
- Si la API devuelve error, verifique el `dataset_id` y las dimensiones en la documentación de Comext.

## Función auxiliar para convertir JSON a DataFrame
La función `comext_json_to_labeled_df` convierte el JSON en un DataFrame con columnas por dimensión (códigos y `*_label`) y la columna `value` (numérica cuando procede).

## Enlaces útiles
- Guía de Comext: https://ec.europa.eu/eurostat/web/user-guides/data-browser/api-data-access/api-getting-started/comext-database
- Portal Eurostat: https://ec.europa.eu/eurostat/
