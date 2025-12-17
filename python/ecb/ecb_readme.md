# Guía rápida: BCE con Python

Este documento explica cómo usar `python/ecb/ecb_function.py` para descargar series del BCE en formato CSV y obtener un `pandas.DataFrame`.

## Requisitos
- Paquetes: `requests`, `pandas`

## Codigos ejemplo
- `ecb_onlylink.py`: ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `ecb_min.py`: ejemplo mínimo para descargar datos del BCE sin usar la función `ecb_api_function`.
- `ecb_example.py`: ejemplo de uso de la función `ecb_api_function`.

## Inputs
- **Obligatorios**
  - `dataset`: identificador del dataset (p. ej., `"BSI"`).
  - `series_key`: clave completa de la serie (dimensiones separadas por `.`).

## Cómo elegir inputs
1) Abra el dataset en el portal BCE (p. ej., BSI): https://data.ecb.europa.eu/data/datasets/BSI
2) Use los filtros hasta ver la serie concreta; la clave `series_key` aparece en el recuadro de la serie.
3) Cada elemento de `series_key` es una dimensión del dataset; puede cambiar `U2` (Área del euro) por `ES` (España), etc. Pinchando en `view all` se pueden ver todas las dimensiones del dataset y sus códigos. Para conocer qué valores puede tomar una dimensión, vea un dataset concreto con `.../structure`.

## Sintaxis de la API (BCE)
- **Formato general:**
  ```
  https://data-api.ecb.europa.eu/service/data/{dataset}/{seriesKey}?format=csvdata
  ```

- **Ejemplo:**
  ```
  https://data-api.ecb.europa.eu/service/data/BSI/M.U2.Y.V.M30.X.I.U2.2300.Z01.A?format=csvdata
  ```

## Output
- Un `pandas.DataFrame` con los datos descargados.

## Notas
- El parámetro `format=csvdata` se añade automáticamente.

## Enlaces útiles
- Portal de datos del BCE (datasets): https://data.ecb.europa.eu/data/datasets/
- Documentación de la API de datos del BCE: https://data.ecb.europa.eu/help/api/overview
- API de datos (servicio): https://data-api.ecb.europa.eu/service/
