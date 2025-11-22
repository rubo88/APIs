# Guía rápida: OECD SDMX (CSV) — `oecd/oecd_function.R`

Este documento explica cómo usar la función en `oecd/oecd_function.R` para descargar datos de la API SDMX de la OCDE en formato CSV y obtenerlos como un data frame en R.

## Requisitos
- R (≥ 4.0 recomendado)
- Paquete `httr` instalado (`install.packages("httr")` si fuera necesario)


## Inputs
- **Obligatorios**
  - `agency_identifier`: identificador de la agencia (p. ej., `"OECD.ECO.MAD"`).
  - `dataset_identifier`: identificador del dataset (p. ej., `"DSD_EO@DF_EO"`).
  - `data_selection`: clave SDMX (dimensiones) tras la `/` (p. ej., `"FRA+DEU.PDTY.A"`).

- **Opcionales**
  - `base_url`: host de la API SDMX (por defecto `"https://sdmx.oecd.org/public/rest/data"`).
  - `dataset_version`: versión del dataset (p. ej., `""`).
  - `startPeriod`, `endPeriod`, `dimensionAtObservation`: parámetros comunes de consulta.

## Output
- Un `data.frame` con los datos descargados desde la OCDE.


## Ejemplo de uso
```r
# 1) Cargar la función
source("oecd/oecd_function.R")

# 2) Ejecutar la consulta
df <- oecd_api_function(
  agency_identifier = "OECD.ECO.MAD",
  dataset_identifier = "DSD_EO@DF_EO",
  data_selection = "FRA+DEU.PDTY.A",
  startPeriod = "1965",
  endPeriod = "2023",
  dimensionAtObservation = "AllDimensions"
)

str(df)
```
## Codigos ejemplo 
El código `oecd_onlylink.R` es un ejemplo que descarga y lee el csv directamente del link de la API en una linea.
El código `oecd_min.R` es un ejemplo mínimo para descargar datos de la OCDE sin usar la función `oecd_api_function`.
El código `oecd_example.R` es un ejemplo de uso de la función `oecd_api_function`.

## Cómo elegir inputs
1) Buscar el dataset en el explorador OCDE: https://data-explorer.oecd.org/
2) Seleccionar las dimensiones que se quieren descargar y consultar la sección "Developer API" para obtener `Agency identifier`, `Dataset identifier` y `Dataset version`.
3) Construir `data_selection` con las dimensiones requeridas por el dataset (p. ej., `PAISES.VARIABLE.FRECUENCIA`).
4) Ajustar parámetros opcionales (`startPeriod`, `endPeriod`, `dimensionAtObservation`).

## Sintaxis de la URL de la API (OCDE)
Formato general:
```
{Host URL}/{Agency identifier},{Dataset identifier},{Dataset version}/{Data selection}?{otros parámetros}
```
Donde `base_url` por defecto es `https://sdmx.oecd.org/public/rest/data`.

Ejemplo equivalente:
```
https://sdmx.oecd.org/public/rest/data/OECD.ECO.MAD,DSD_EO@DF_EO, /FRA+DEU.PDTY.A?startPeriod=1965&endPeriod=2023&dimensionAtObservation=AllDimensions
```

## Notas
- Si la API devuelve error, verifique que `agency_identifier`, `dataset_identifier` y `data_selection` sean válidos.
- Revise la documentación del dataset para conocer las dimensiones y códigos disponibles.

## Enlaces útiles
- Explorador OCDE: https://data-explorer.oecd.org/
- Documentación de la API: https://www.oecd.org/en/data/insights/data-explainers/2024/09/api.html


