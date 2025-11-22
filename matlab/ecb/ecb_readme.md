# Guía rápida: BCE Data API (CSV) — `matlab/ecb/ecb_function.m`

Este documento explica cómo usar la función en `matlab/ecb/ecb_function.m` para descargar una serie del BCE (dataset SDMX) en formato CSV y obtenerla como una tabla en MATLAB.

## Requisitos
- MATLAB (R2019b o superior recomendado)

## Inputs
- **Obligatorios**
  - `dataset`: identificador del dataset del BCE (p. ej., `"BSI"`).
  - `seriesKey`: clave completa de la serie (dimensiones concatenadas con `.`).

- **Opcionales**
  - `base_url`: host del servicio de datos del BCE (por defecto `"https://data-api.ecb.europa.eu/service/data"`).

## Output
- Una `table` con los datos descargados desde el BCE.

## Ejemplo de uso
```matlab
addpath('matlab');
T = ecb_api_function('BSI', 'M.U2.Y.V.M30.X.I.U2.2300.Z01.A');
writetable(T, 'matlab/ecb/ecb_example.csv', 'FileType', 'text'); 
```

## Códigos ejemplo 
- `ecb_onlylink.m`: ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `ecb_min.m`: ejemplo mínimo para descargar datos del BCE y guardarlos en CSV.
- `ecb_example.m`: ejemplo de uso de la función `ecb_api_function` devolviendo una tabla y exportándola a CSV.

## Cómo elegir inputs
1) Abra el dataset en el portal BCE (p. ej., BSI): `https://data.ecb.europa.eu/data/datasets/BSI`
2) Use los filtros hasta ver la serie concreta; la clave `seriesKey` aparece en el recuadro de la serie.
3) Cada elemento de `seriesKey` es una dimensión del dataset; puede cambiar `U2` (Área del euro) por `ES` (España), etc. 

## Sintaxis de la URL de la API (BCE)
Formato general:
```
https://data-api.ecb.europa.eu/service/data/{dataset}/{seriesKey}?format=csvdata
```

Ejemplo equivalente:
```
https://data-api.ecb.europa.eu/service/data/BSI/M.U2.Y.V.M30.X.I.U2.2300.Z01.A?format=csvdata
```

## Enlaces útiles
- Portal de datos del BCE (datasets): `https://data.ecb.europa.eu/data/datasets/`
- Documentación de la API de datos del BCE: `https://data.ecb.europa.eu/help/api/overview`
- API de datos (servicio): `https://data-api.ecb.europa.eu/service/`


