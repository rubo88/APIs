# Guía rápida: ECB Data Portal (CSV) — `ecb/ecb_min.do`

Este documento explica cómo descargar datos del Banco Central Europeo (ECB) usando `ecb/ecb_min.do` en Stata, solicitando el formato CSV.

## Requisitos
- Stata.

## Descripción
El script define variables globales para el dataset y la clave de la serie (seriesKey) y construye una URL que solicita explícitamente `format=csvdata`.

## Ejemplo de uso (`ecb_min.do`)

```stata
global dataset "BSI"
global seriesKey "M.U2.Y.V.M30.X.I.U2.2300.Z01.A"

* La URL incluye ?format=csvdata para asegurar compatibilidad con import delimited
import delimited "https://data-api.ecb.europa.eu/service/data/${dataset}/${seriesKey}?format=csvdata", encoding("utf-8") clear
```
 
## Personalización
Cambie las globales `dataset` y `seriesKey` por los valores deseados. Puede encontrar estos códigos en el [ECB Data Portal](https://data.ecb.europa.eu/).

## Cómo elegir inputs
1) Abra el dataset en el portal BCE (p. ej., BSI): https://data.ecb.europa.eu/data/datasets/BSI
2) Use los filtros hasta ver la serie concreta; la clave `seriesKey` aparece en el recuadro de la serie.
3) Use esa clave para definir la global `seriesKey`.
4) Cada elemento de `seriesKey` es una dimensión del dataset; puede cambiar `U2` (Área del euro) por `ES` (España), etc. Pinchando en `view all` se pueden ver todas las dimensiones del dataset y sus codigos.

## Enlaces útiles
- [ECB Data Portal API](https://data.ecb.europa.eu/help/api/overview)
