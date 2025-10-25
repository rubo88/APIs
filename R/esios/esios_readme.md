# Guía rápida: REE e·sios — `esios/esios_function.R`

Este documento explica cómo usar la función en `esios/esios_function.R` para descargar valores de indicadores del portal e·sios de Red Eléctrica (REE) y obtenerlos como un data frame en R.

## Requisitos
- R (≥ 4.0 recomendado)
- Paquetes `httr` y `jsonlite` instalados
- Token personal de e·sios en la variable de entorno `ESIOS_TOKEN`

## Inputs
- **Obligatorios**
  - `indicator_id`: id numérico del indicador (p. ej., `10211`).
  - `start_date`, `end_date`: fechas en ISO8601 con zona Z (ej.: `2025-01-01T00:00:00Z`).

- **Opcionales**
  - `time_agg`: agregación temporal ("sum" o "avg").
  - `time_trunc`: recorte temporal ("five_minutes", "ten_minutes", "fifteen_minutes", "hour", "day", "month", "year").
  - `geo_agg`: agregación por geografía ("sum" o "avg").
  - `geo_trunc`: nivel geográfico ("country", "electric_system", "autonomous_community", "province", "electric_subsystem", "town", "drainage_basin").
  - `geo_ids`: vector de ids geográficos (se envía como parámetros repetidos `geo_ids[]`).
  - `locale`: idioma de respuesta ("es" o "en").
  - `token`: API key (por defecto lee `Sys.getenv("ESIOS_TOKEN")`).

## Output
- Un `data.frame` con los valores del indicador. La función normaliza la respuesta leyendo `indicator$values` (o `values`) y convierte la columna `value` a numérica cuando procede.

## Ejemplo de uso
```r
# 1) Cargar la función
source("esios/esios_function.R")

# 2) Definir periodo: último mes (UTC)
end_date_date <- Sys.Date()
start_date_date <- end_date_date - 30
start_date <- paste0(format(start_date_date, "%Y-%m-%d"), "T00:00:00Z")
end_date   <- paste0(format(end_date_date, "%Y-%m-%d"), "T23:59:59Z")

# 3) Ejecutar la consulta: promedio nacional diario (id 10211)
df <- esios_api_function(
  indicator_id = 10211,
  start_date = start_date,
  end_date = end_date,
  time_agg = "avg",
  time_trunc = "day",
  geo_agg = "avg",
  geo_trunc = "country",
  locale = "es"
)

str(df)
```

## Ejemplos incluidos
- `esios_min.R`: script mínimo que guarda CSV usando parámetros básicos.
- `esios_example.R`: ejemplo práctico con promedio diario nacional del último mes.
- `esios_list_indicators.R`: listado completo de indicadores y metadatos.

## Cómo elegir el id
Hay dos opciones:
1) Descargandose el listado de indicadores y metadatos con `esios_list_indicators.R`
2) Buscando en la web con la herramienta interactiva. Una vez seleccionada la serie, puedes descargar el CSV y el id está en la primera columna.

## Como elegir los otros parámetros
Ver arriba en la sección "Inputs" de este documento. Si hay dudas, buscar en la documentación oficial de la API: https://api.esios.ree.es/. Indicator section.

## Clave API
- Para conseguir la API hay que escribir un mail a consultasios@ree.es solicitando un token. 

- Una vez obtenida la clave, debes establecerla como variable de entorno `ESIOS_TOKEN` antes de ejecutar. Ejemplo en R:
```r
Sys.setenv(ESIOS_TOKEN = "SU_TOKEN_AQUI")
```

## Documentación oficial
- Portal y catálogo de endpoints: https://api.esios.ree.es/
- Ejemplo de parámetros/aggregaciones de indicadores: https://api.esios.ree.es/doc/indicator/getting_a_disaggregated_indicator_filtering_values_by_a_date_range_and_geo_ids,_grouped_by_geo_id_and_month,_using_avg_aggregation_for_geo_and_avg_for_time_without_time_trunc.html
