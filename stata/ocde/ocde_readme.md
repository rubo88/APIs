# Guía rápida: OECD Data Explorer (CSV) — `ocde/ocde_min.do`

Este documento explica cómo descargar datos de la OCDE usando la API REST SDMX en Stata.

## Requisitos
- Stata.

## Descripción
El script construye una URL para la API de la OCDE especificando la agencia, el dataset, la selección de datos y el periodo, solicitando el formato `csvfile`.

## Ejemplo de uso (`ocde_min.do`)

```stata
global agency_identifier "OECD.ECO.MAD"
global dataset_identifier "DSD_EO@DF_EO"
global data_selection "FRA+DEU.PDTY.A"
global startPeriod "1965"
global endPeriod "2023"

import delimited "https://sdmx.oecd.org/public/rest/data/${agency_identifier},${dataset_identifier},/${data_selection}?format=csvfile&startPeriod=${startPeriod}&endPeriod=${endPeriod}", encoding("utf-8") clear
```

## Personalización
La clave de selección (`data_selection`) sigue la estructura de dimensiones del dataset (ej. `Pais.Indicador.Frecuencia`). Puede explorar los identificadores en el [OECD Data Explorer](https://data-explorer.oecd.org/).

## Cómo elegir inputs
1) Buscar el dataset en el explorador OCDE: https://data-explorer.oecd.org/
2) Seleccionar las dimensiones que se quieren descargar y consultar la sección "Developer API" para obtener `Agency identifier`, `Dataset identifier` y `Dataset version`.
3) Construir la global `data_selection` con las dimensiones requeridas por el dataset (p. ej., `PAISES.VARIABLE.FRECUENCIA`).
4) Puede filtrar por periodo modificando las globales `startPeriod` y `endPeriod`.

## Enlaces útiles
- [OECD Data API Documentation](https://data.oecd.org/api/sdmx-json-documentation/)
