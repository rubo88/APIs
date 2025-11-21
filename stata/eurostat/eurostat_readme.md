# Guía rápida: Eurostat API (CSV) — `eurostat/eurostat_min.do`

Este documento explica cómo descargar datos de Eurostat directamente en Stata usando la API SDMX 3.0 de diseminación.

## Requisitos
- Stata.

## Descripción
El script `eurostat_min.do` construye una consulta a la API de Eurostat especificando el dataset y los filtros, y solicita el formato CSV (`format=csvdata`).

## Ejemplo de uso (`eurostat_min.do`)

```stata
global agency_identifier "ESTAT"
global dataset_eurostat "nama_10_a64"    
* Filtros en formato URL query string
global filters "?c[freq]=A&c[unit]=CLV_I20,CLV05_MEUR&c[nace_r2]=TOTAL&c[na_item]=B1G,P1&c[geo]=ES&c[TIME_PERIOD]=ge:1995"

import delimited "https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/${agency_identifier}/${dataset_eurostat}/1.0/${filters}&compress=false&format=csvdata&formatVersion=2.0&lang=en&labels=name", encoding("utf-8") clear
```

## Personalización
1. Identifique el código del dataset (p. ej. `nama_10_a64`).
2. Construya los filtros en la variable `filters`. Note el uso de `c[dimension]=valor`.

## Cómo elegir inputs
1) Lo más sencillo es ir a Eurostat, buscar la serie de interés y copiar el codigo de la serie. Mirar el codigo de las variables que nos interesan y los codigos de los valores que queremos filtrar.
2) Usar el codigo de la serie como `dataset_eurostat`.
3) Ajustar la global `filters` con formato URL query string:
   - Use `c[DIMENSION]=VALOR`.
   - Para valores múltiples use comas: `c[geo]=ES,FR`.
   - En `TIME_PERIOD` puede usar operadores SDMX: `ge:YYYY`, `le:YYYY`.
   - Ejemplo: `?c[geo]=ES&c[unit]=EUR`

## Enlaces útiles
- [Eurostat API Setup](https://wikis.ec.europa.eu/display/EUROSTATHELP/API+SDMX+3.0+-+Data+retrieval)
