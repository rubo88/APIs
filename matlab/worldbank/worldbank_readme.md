# Guía rápida: Banco Mundial con MATLAB

Este documento explica cómo usar la función en `matlab/worldbank/worldbank_function.m` para descargar datos JSON del Banco Mundial y obtenerlos como una tabla en MATLAB.

## Requisitos
- Ninguno adicional a MATLAB.

## Codigos ejemplo
- `worldbank_min.m`: ejemplo mínimo para construir la URL y guardar en CSV.
- `worldbank_example.m`: ejemplo de uso de la función `worldbank_api_function` devolviendo una tabla y exportándola a CSV.

## Inputs
- **Obligatorios**
  - `iso3`: código(s) de país ISO-3 (múltiples separados por ';').
  - `indicator`: código(s) de indicador (múltiples separados por ';').

- **Opcionales**
  - `date` (p. ej., `"2015:2020"`).
  - `per_page` (por defecto `20000`).

## Cómo elegir inputs
1) Elija país(es) `iso3` (estándar ISO 3166-1 alpha-3). Puede listar países: https://api.worldbank.org/v2/country?format=json
2) Elegir indicador (`indicator`)
   - Buscar en la web del World Bank la serie de interés. Seleccionar las variables y pinchar en `Metadata` -> `Series`. Copiar el código de la serie. Puede ser una lista de indicadores separados por `;`.
   - Busque indicadores en: https://api.worldbank.org/v2/indicator?format=json (listado paginado) o en el portal de datos del Banco Mundial.
3) Rango temporal
   - La API soporta `date=YYYY:YYYY` para filtrar.

## Sintaxis de la API (World Bank)
- **Formato general:**
  ```
  https://api.worldbank.org/v2/country/{iso3}/indicator/{indicator}?format=json&per_page=...&date=...
  ```

## Output
- Una `table` con los datos de la respuesta (elemento [2]).

## Enlaces útiles
- Indicadores (API): https://datahelpdesk.worldbank.org/knowledgebase/articles/889392-about-the-indicators-api-documentation
- Estructura de llamadas: https://datahelpdesk.worldbank.org/knowledgebase/articles/898581-api-basic-call-structures
