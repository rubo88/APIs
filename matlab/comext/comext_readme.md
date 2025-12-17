# Guía rápida: Eurostat Comext con MATLAB

Este documento explica cómo usar la función en `matlab/comext/comext_function.m` para descargar datos del endpoint Comext de Eurostat (JSON) y obtenerlos como una tabla en MATLAB.

## Requisitos
- Ninguno adicional a MATLAB.

## Codigos ejemplo
- `comext_min.m`: ejemplo mínimo que construye la URL JSON y guarda en CSV.
- `comext_example.m`: ejemplo de uso de la función `comext_api_function` devolviendo una tabla y exportándola a CSV.

## Inputs
- **Obligatorios**
  - `dataset_id`: identificador del dataset Comext (prefijo `"DS-"`, p. ej., `"DS-059341"`).
  - `filters`: struct NOMBRADO de filtros (dimensión -> valores). Los nombres deben ser dimensiones válidas (p. ej., `reporter`, `partner`, `product`, `flow`, `freq`, `time`, `indicators`, ...). Los valores pueden ser `"string"` o `cellstr`.

## Cómo elegir inputs
1) Identifique el dataset en la guía de Comext y el portal de Eurostat.
2) Consulte la estructura del dataset en la guía Comext para conocer las dimensiones válidas y sus valores.
3) Ajuste `filters` con nombres de dimensiones válidos. Para múltiples valores use `cellstr` en MATLAB (enviamos parámetros repetidos).

## Sintaxis de la API (Eurostat Comext)
- **Formato general:**
  ```
  https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/{dataset_id}?dim=...
  ```

## Output
- Una `table` con columnas por dimensión y `value` (según disponibilidad).

## Enlaces útiles
- Guía de Comext: https://ec.europa.eu/eurostat/web/user-guides/data-browser/api-data-access/api-getting-started/comext-database
- Portal Eurostat: https://ec.europa.eu/eurostat/
