# Guía rápida: Eurostat COMEXT — `matlab/comext/comext_function.m`

Este documento explica cómo usar la función en `matlab/comext/comext_function.m` para descargar datos del endpoint Comext de Eurostat (JSON) y obtenerlos como una tabla en MATLAB.

## Requisitos
- MATLAB (R2019b o superior recomendado)

## Inputs
- **Obligatorios**
  - `dataset_id`: identificador del dataset Comext (prefijo `"DS-"`, p. ej., `"DS-059341"`).
  - `filters`: struct NOMBRADO de filtros (dimensión -> valores). Los nombres deben ser dimensiones válidas (p. ej., `reporter`, `partner`, `product`, `flow`, `freq`, `time`, `indicators`, ...). Los valores pueden ser `"string"` o `cellstr`.

## Output
- Una `table` con columnas por dimensión y `value` (según disponibilidad). Nota: la reconstrucción completa de dimensiones requiere strides; el ejemplo simplificado devuelve columnas básicas.

## Ejemplo de uso
```matlab
addpath('matlab');
T = comext_api_function('DS-059341', struct('reporter', {{'ES'}}, 'partner', {{'US'}}, 'product', {{'1509','8703'}}, 'flow', {{'2'}}, 'freq', {{'A'}}, 'time', num2cell(2015:2020)));
writetable(T, 'matlab/comext/comext_example.csv', 'FileType', 'text');
```

## Códigos ejemplo 
- `comext_min.m`: ejemplo mínimo que construye la URL JSON y guarda en CSV.
- `comext_example.m`: ejemplo de uso de la función `comext_api_function` devolviendo una tabla y exportándola a CSV.

## Endpoints
- Formato general: `https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/{dataset_id}?dim=...`


