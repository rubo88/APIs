# Guía rápida: Banco Mundial — `matlab/worldbank/worldbank_function.m`

Este documento explica cómo usar la función en `matlab/worldbank/worldbank_function.m` para descargar datos JSON del Banco Mundial y obtenerlos como una tabla en MATLAB.

## Requisitos
- MATLAB (R2019b o superior recomendado)

## Inputs
- **Obligatorios**
  - `iso3`: código(s) de país ISO-3 (múltiples separados por ';').
  - `indicator`: código(s) de indicador (múltiples separados por ';').

- **Opcionales**
  - `date` (p. ej., `"2015:2020"`)
  - `per_page` (por defecto `20000`)
  - `base_url` (por defecto `"https://api.worldbank.org/v2"`)

## Output
- Una `table` con los datos de la respuesta (elemento [2]).

## Ejemplo de uso
```matlab
addpath('matlab');
T = worldbank_api_function('ESP', 'NY.GDP.MKTP.KD.ZG', '2015:2020');
writetable(T, 'matlab/worldbank/worldbank_example.csv', 'FileType', 'text');
```

## Códigos ejemplo 
- `worldbank_min.m`: ejemplo mínimo para construir la URL y guardar en CSV.
- `worldbank_example.m`: ejemplo de uso de la función `worldbank_api_function` devolviendo una tabla y exportándola a CSV.

## Endpoints
- Formato general: `https://api.worldbank.org/v2/country/{iso3}/indicator/{indicator}?format=json&per_page=...&date=...`


