# Guía rápida: World Bank (ZIP/CSV) — `worldbank/worldbank_min.do`

Este documento explica cómo descargar e importar indicadores del Banco Mundial manualmente en Stata, manejando archivos ZIP.

## Requisitos
- Stata.

## Descripción
A diferencia de una descarga CSV directa simple, la API del Banco Mundial a menudo sirve archivos ZIP que contienen el CSV de datos y metadatos. Este script automatiza la descarga, descompresión e importación.

Nota: También existe el comando de la comunidad `wbopendata` (`ssc install wbopendata`) que facilita este proceso, pero este script muestra el método manual sin dependencias externas.

## Ejemplo de uso (`worldbank_min.do`)

```stata
global indicator "NY.GDP.MKTP.KD.ZG"

* 1. Descargar ZIP
copy "https://api.worldbank.org/v2/en/indicator/${indicator}?downloadformat=csv" "wb_gdp_growth.zip", replace

* 2. Descomprimir
unzipfile "wb_gdp_growth.zip", replace

* 3. Importar (ajuste el nombre del archivo CSV resultante si es necesario)
* El CSV del Banco Mundial suele tener 4 filas de encabezado antes de los datos reales
import delimited "API_${indicator}_DS2_en_csv_v2_260128.csv", varnames(1) rowrange(5) encoding(UTF-8) clear
```

## Detalles
- `copy`: Descarga el archivo a disco.
- `unzipfile`: Extrae el contenido.
- `import delimited ... rowrange(5)`: Omite las filas de metadatos iniciales típicas de los CSV del Banco Mundial.

## Cómo elegir inputs
1) Elija el indicador (`indicator`)
   - Buscar en la web del World Bank la serie de interés. Seleccionar las variables y pinchar en `Metadata` -> `Series`. Copiar el codigo de la serie (p. ej. `NY.GDP.MKTP.KD.ZG`).
   - Busque indicadores en: https://api.worldbank.org/v2/indicator?format=json o en el portal de datos.
2) Use ese código para definir la global `indicator`.
3) El archivo CSV descargado tendrá un nombre basado en el indicador (ej. `API_NY.GDP...`). Deberá ajustar el nombre del archivo en el comando `import delimited` si cambia de indicador (use `dir` en Stata para ver el nombre exacto tras descomprimir).

## Enlaces útiles
- [World Bank Data API](https://datahelpdesk.worldbank.org/knowledgebase/topics/125589-developer-information)
