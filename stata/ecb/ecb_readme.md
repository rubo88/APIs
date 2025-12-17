# Guía rápida: ECB con Stata

Este documento explica cómo descargar datos del Banco Central Europeo (ECB) usando `ecb/ecb_min.do` en Stata, solicitando el formato CSV.

## Requisitos
- Stata

## Codigos ejemplo
- `ecb_min.do` es un ejemplo mínimo para descargar datos del BCE directamente en Stata.

## Inputs
- **Obligatorios**
  - `dataset`: identificador del dataset del BCE (p. ej., `"BSI"`).
  - `seriesKey`: clave completa de la serie (dimensiones concatenadas con `.`).

## Cómo elegir inputs
1) Abra el dataset en el portal BCE (p. ej., BSI): https://data.ecb.europa.eu/data/datasets/BSI
2) Use los filtros hasta ver la serie concreta; la clave `seriesKey` aparece en el recuadro de la serie.
3) Cada elemento de `seriesKey` es una dimensión del dataset; puede cambiar `U2` (Área del euro) por `ES` (España), etc. Pinchando en `view all` se pueden ver todas las dimensiones del dataset y sus códigos.

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
- Un dataset en memoria de Stata con los datos descargados.

## Enlaces útiles
- Portal de datos del BCE (datasets): https://data.ecb.europa.eu/data/datasets/
- Documentación de la API de datos del BCE: https://data.ecb.europa.eu/help/api/overview
- API de datos (servicio): https://data-api.ecb.europa.eu/service/
