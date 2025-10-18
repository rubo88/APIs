# Guía rápida: Banco Mundial — `worldbank/worldbank_function.R`

Este documento explica cómo usar la función en `worldbank/worldbank_function.R` para descargar datos desde el Banco Mundial (API JSON) y obtenerlos como un data frame en R.

## Requisitos
- R (≥ 4.0 recomendado)
- Paquetes `httr` y `jsonlite` instalados


## Inputs
- **Obligatorios**
  - `iso3`: código(s) de país ISO-3 (p. ej., `"ESP"`), separados por `;` si son múltiples.
  - `indicator`: código(s) de indicador (p. ej., `NY.GDP.MKTP.KD.ZG`), separados por `;` si son múltiples.

- **Opcionales**
  - `date`: rango temporal (p. ej., `"2020:2023"`).
  - `per_page`: tamaño de página (use un valor alto, p. ej., `20000`).
  - `base_url`: host de la API (por defecto `"https://api.worldbank.org/v2"`).

## Output
- Un `data.frame` con los datos devueltos en el elemento `[2]` de la respuesta JSON.


## Ejemplo de uso
```r
# 1) Cargar la función
source("worldbank/worldbank_function.R")

# 2) Ejecutar la consulta
df <- worldbank_api_function(
  iso3 = "ESP;FRA",
  indicator = "NY.GDP.MKTP.KD.ZG",
  date = "2020:2023",
  per_page = 20000
)

str(df)
```
## Codigos ejemplo 
El código `worldbank_min.R` es un ejemplo mínimo para descargar datos del Banco Mundial sin usar la función `worldbank_api_function`.
El código `worldbank_example.R` es un ejemplo de uso de la función `worldbank_api_function`.

## Cómo elegir inputs
1) Elija país(es) `iso3` (estándar ISO 3166-1 alpha-3). Puede listar países: https://api.worldbank.org/v2/country?format=json

2) Elegir indicador (`indicator`)
   - Buscar en la web del World Bank la serie de interés. Seleccionar las variables y pinchar en `Metadata`-> `Series`. Copiar el codigo de la serie. Puede ser una lista de indicadores separados por `;`.
   - Busque indicadores en: https://api.worldbank.org/v2/indicator?format=json (listado paginado) o en el portal de datos del Banco Mundial.
   - También puede abrir un indicador concreto para ver su nombre/meta: https://api.worldbank.org/v2/indicator/NY.GDP.MKTP.KD.ZG?format=json.

3) Rango temporal 
   - La API soporta `date=YYYY:YYYY` para filtrar. 
   - Si por ejemplo es mensual, sería `date=2012M01:2012M08`
   

## Sintaxis de la URL de la API (World Bank)
Formato general:
```
https://api.worldbank.org/v2/country/{ISO3}/indicator/{INDICATOR}?format=json&per_page={N}&date={DATE}
```

Ejemplo equivalente:
```
https://api.worldbank.org/v2/country/ESP;FRA/indicator/NY.GDP.MKTP.KD.ZG?format=json&per_page=20000&date=2020:2023
```

## Enlaces útiles
- Indicadores (API): https://datahelpdesk.worldbank.org/knowledgebase/articles/889392-about-the-indicators-api-documentation
- Estructura de llamadas: https://datahelpdesk.worldbank.org/knowledgebase/articles/898581-api-basic-call-structures
- Países (JSON): https://api.worldbank.org/v2/country?format=json
- Indicadores (JSON): https://api.worldbank.org/v2/indicator?format=json


