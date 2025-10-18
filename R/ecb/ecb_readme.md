# Guía rápida: BCE Data API (CSV) — `ecb/ecb_function.R`

Este documento explica cómo usar la función en `ecb/ecb_function.R` para descargar una serie del BCE (dataset SDMX) en formato CSV y obtenerla como un data frame en R.

## Requisitos
- R (≥ 4.0 recomendado)
- Paquete `httr` instalado (`install.packages("httr")` si fuera necesario)


## Inputs
- **Obligatorios**
  - `dataset`: identificador del dataset del BCE (p. ej., `"BSI"`). Vease los datasets disponibles en https://data.ecb.europa.eu/data/datasets/
  - `seriesKey`: clave completa de la serie (dimensiones concatenadas con `.`).

- **Opcionales**
  - `base_url`: host del servicio de datos del BCE (por defecto `"https://data-api.ecb.europa.eu/service/data"`).

## Output
- Un `data.frame` con los datos descargados desde el BCE.


## Ejemplo de uso
```r
# 1) Cargar la función
source("ecb/ecb_function.R")

# 2) Ejecutar la consulta
df <- ecb_api_function(
  dataset = "BSI",
  seriesKey = "M.U2.Y.V.M30.X.I.U2.2300.Z01.A"
)

str(df)
```
## Codigos ejemplo 
El código `ecb_min.R` es un ejemplo mínimo para descargar datos del BCE sin usar la función `ecb_api_function`.
El código `ecb_example.R` es un ejemplo de uso de la función `ecb_api_function`.

## Cómo elegir inputs
1) Abra el dataset en el portal BCE (p. ej., BSI): https://data.ecb.europa.eu/data/datasets/BSI
2) Use los filtros hasta ver la serie concreta; la clave `seriesKey` aparece en el recuadro de la serie.
3) Cada elemento de `seriesKey` es una dimensión del dataset; puede cambiar `U2` (Área del euro) por `ES` (España), etc. Pinchando en `view all` se pueden ver todas las dimensiones del dataset y sus codigos. Para conocer que valores puede tomar una dimensión, vease https://data.ecb.europa.eu/data/datasets/PAY/structure

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
- Portal de datos del BCE (datasets): https://data.ecb.europa.eu/data/datasets/
- Documentación de la API de datos del BCE: https://data.ecb.europa.eu/help/api/overview
- Estructura de los codigos de las dimensiones: https://data.ecb.europa.eu/data/datasets/PAY/structure
- API de datos (servicio): https://data-api.ecb.europa.eu/service/


