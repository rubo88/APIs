# Guía rápida: Banco Mundial con Stata

Este documento explica cómo descargar e importar indicadores del Banco Mundial manualmente en Stata, manejando archivos ZIP.

## Requisitos
- Stata

## Codigos ejemplo
- `worldbank_min.do` es un ejemplo mínimo para descargar y descomprimir datos del Banco Mundial en Stata.

## Inputs
- **Obligatorios**
  - `indicator`: código del indicador (p. ej., `NY.GDP.MKTP.KD.ZG`).

## Cómo elegir inputs
1) Elija el indicador (`indicator`)
   - Buscar en la web del World Bank la serie de interés. Seleccionar las variables y pinchar en `Metadata` -> `Series`. Copiar el codigo de la serie (p. ej. `NY.GDP.MKTP.KD.ZG`).
   - Busque indicadores en: https://api.worldbank.org/v2/indicator?format=json o en el portal de datos.
2) Use ese código para definir la global `indicator`.
3) El archivo CSV descargado tendrá un nombre basado en el indicador (ej. `API_NY.GDP...`). Deberá ajustar el nombre del archivo en el comando `import delimited`.

## Sintaxis de la API (World Bank)
- **Formato general (ZIP con CSV):**
  ```
  https://api.worldbank.org/v2/en/indicator/{indicator}?downloadformat=csv
  ```

## Output
- Un dataset en memoria de Stata con los datos del indicador.

## Enlaces útiles
- Indicadores (API): https://datahelpdesk.worldbank.org/knowledgebase/articles/889392-about-the-indicators-api-documentation
- [World Bank Data API](https://datahelpdesk.worldbank.org/knowledgebase/topics/125589-developer-information)
