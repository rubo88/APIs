## Guía rápida: OECD SDMX (CSV) — oecd/oecd_min.R

Este script descarga datos de la API SDMX de la OCDE en formato CSV y los guarda en `data/`.
Separa explícitamente el identificador del dataset (data identifier) de la selección de datos (data selection) según la sintaxis oficial.

### Requisitos
- R (≥ 4.0 recomendado)
- Paquete `httr` instalado (`install.packages("httr")` si fuera necesario)

### Archivo
- Script: `oecd/oecd_min.R`
- Salida por defecto (editable): `data/oecd_ejemplo.csv` (según `output_name`)

### Sintaxis oficial (OCDE)
{Host URL}/{Agency identifier},{Dataset identifier},{Dataset version}/{Data selection}?{otros parámetros}


### Parámetros editables (al inicio del script)
- `base_url`: base de la API SDMX. Por defecto `https://sdmx.oecd.org/public/rest/data`. En principio no hace falta cambiarlo.
- `agency_identifier`: identificador de la agencia. Ejemplo: `"OECD.ECO.MAD"`.
- `dataset_identifier`: identificador del dataset. Ejemplo: `"DSD_EO@DF_EO"`.
- `dataset_version`: versión del dataset. Ejemplo: `""`.
- `data_selection`: clave SDMX (dimensiones) tras la `/`. Ejemplo: `"FRA+DEU.PDTY.A"`. Aqui la primera dimensión son los países a seleccionar, la segunda es la variable y la tercera es la frecuencia (anual).
- `params`: parámetros de consulta (p. ej. `startPeriod`, `endPeriod`, `dimensionAtObservation`).
- `output_name`: nombre base del archivo de salida (sin extensión).
- `out_file`: ruta/nombre del CSV de salida.


### Cómo cambiar la consulta 
1) Buscar el dataset en el explorador OCDE: [https://data-explorer.oecd.org/](https://data-explorer.oecd.org/)
2) Seleccionar las dimensiones que se quieren descargar.
3) Lo más fácil es ir a `Developer API` y copiar de `Data query` el Agency identifier, el Dataset identifier y el Dataset version.


### Enlaces útiles
- Explorador OCDE: [https://data-explorer.oecd.org/](https://data-explorer.oecd.org/)
- Documentación de la API: [https://www.oecd.org/en/data/insights/data-explainers/2024/09/api.html](https://www.oecd.org/en/data/insights/data-explainers/2024/09/api.html)


