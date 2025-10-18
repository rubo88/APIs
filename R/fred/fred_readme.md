# Guía rápida: FRED — `fred_function.R`

Este documento explica cómo usar las funciones en `fred_function.R` para descargar datos desde FRED, tanto con el método "fredgraph" (CSV de un gráfico compartido, sin API key) como con la API v1 (JSON, requiere API key) y obtenerlos como data frames en R.

## Requisitos
- R (≥ 4.0 recomendado)
- Paquetes `httr` y `jsonlite` instalados


## Inputs
- **fredgraph_api_function**
  - Obligatorio: `graphId` (identificador del gráfico compartido en FRED)

- **fred_api_function**
  - Obligatorio: `series_id` (p. ej., `"GDP"`)
  - Opcionales: `observation_start`, `observation_end`, `realtime_start`, `realtime_end`, `limit`, `offset`, `sort_order` ("asc"|"desc"), `units` (ver opciones abajo), `frequency` (ver opciones abajo), `aggregation_method` ("avg"|"sum"|"eop"), `output_type` (1–4), `vintage_dates`, `api_key` (por defecto toma `Sys.getenv("FRED_API_KEY")`).

## Output
- `data.frame` con las observaciones devueltas por cada método.

## Parámetros detallados — solo para `fred_api_function`
- **series_id**: identificador de la serie (p. ej., `GDP`, `CPIAUCSL`). Esto suele estar al lado del nombre de la serie en FRED entre parentesis.
- **observation_start / observation_end**: límites del periodo de observación en formato `YYYY-MM-DD`.
- **realtime_start / realtime_end**: ventana de tiempo real para las revisiones (formato `YYYY-MM-DD`).
- **limit**: número máximo de filas a devolver (p. ej., `100`).
- **offset**: desplazamiento para paginación (p. ej., `100` salta las 100 primeras filas).
- **sort_order**: orden del resultado por fecha de observación — `"asc"` o `"desc"`.
- **units**: transformación de valores.
  - Valores válidos: `"lin"` (niveles), `"chg"` (cambio), `"ch1"` (cambio interanual), `"pch"` (% cambio), `"pc1"` (% interanual), `"pca"` (tasa anual compuesta), `"cch"` (tasa compuesta continua), `"cca"` (tasa anual compuesta continua), `"log"` (log natural).
- **frequency**: agregación a menor frecuencia.
  - Valores válidos: `"d"`, `"w"`, `"bw"`, `"m"`, `"q"`, `"sa"`, `"a"`, `"wef"`, `"weth"`, `"wew"`, `"wetu"`, `"wem"`, `"wesu"`, `"wesa"`, `"bwew"`, `"bwem"`.
  - Nota: solo permite convertir de mayor a menor frecuencia (p. ej., mensual → anual). Requiere `file_type=json` (ya establecido por la función).
- **aggregation_method**: método de agregación cuando se usa `frequency` — `"avg"` (promedio), `"sum"` (suma), `"eop"` (fin de periodo).
- **output_type**: entero que controla la forma de salida — `1` (por periodo en tiempo real), `2` (por fecha de vintage, todas), `3` (solo nuevas/revisadas), `4` (solo release inicial).
- **vintage_dates**: fechas separadas por comas `YYYY-MM-DD,YYYY-MM-DD` para extraer datos de vintages específicos (alternativa a `realtime_start/end`).
- **api_key**: por defecto toma `Sys.getenv("FRED_API_KEY")`. Puede pasarse explícitamente.

Validaciones: la función valida `units`, `frequency`, `aggregation_method` y `output_type` y lanzará error si el valor no es admitido.

## Ejemplo de uso
```r
# 1) Cargar funciones
source("fred/fred_function.R")

# 2) fredgraph (no API key)
df_graph <- fredgraph_api_function(graphId = "1wmdD")
str(df_graph)

# 3) API v1 (requiere FRED_API_KEY)
# Sys.setenv(FRED_API_KEY = "SU_API_KEY")
df_api <- fred_api_function(series_id = "GDP")
str(df_api)
```

### Ejemplos con parámetros
```r
# Porcentaje interanual de IPC, mensual, últimos años, 5 observaciones más recientes
df_cpi <- fred_api_function(
  series_id = "CPIAUCSL",
  observation_start = "2015-01-01",
  units = "pc1",
  frequency = "m",
  aggregation_method = "avg",
  sort_order = "desc",
  limit = 5
)
str(df_cpi)

# Ventana de tiempo real y selección de vintage específico
df_gdp_vintage <- fred_api_function(
  series_id = "GDP",
  realtime_start = "2020-01-01",
  realtime_end   = "2020-12-31",
  output_type = 2
)

df_gdp_vdate <- fred_api_function(
  series_id = "GDP",
  vintage_dates = "2020-07-01,2020-10-01",
  output_type = 2
)
```
## Codigos ejemplo 
El código `fred_min.R` es un ejemplo mínimo que descarga un CSV de fredgraph sin usar la función.
El código `fred_example.R` es un ejemplo de uso de ambas funciones.

## Cómo elegir inputs
- Para `fredgraph_api_function`, obtenga `graphId` desde el enlace compartido del gráfico (parámetro `?g=` en la URL).
- Para `fred_api_function`
  1) elija `series_id` (p. ej., `GDP`, esto suele estar al lado del nombre de la serie en FRED entre parentesis) 
  2) Defina `FRED_API_KEY` como variable de entorno.
  3) si es necesario, cambie los otros parámetros opcionales siguiendo lo indicado en la sección "Parámetros detallados" de este documento.

## Como conseguir una API key
- Para conseguir una API key, hay que registrarse en FRED, entrar en la cuenta, ir a la sección "API keys" y pinchar en "Request API key" para obtener una key.
- Si te da pereza y puedes vivir sin los parametros opcionales, usa la funcion `fredgraph_api_function` que no requiere API key.


## Endpoints
- fredgraph CSV: `https://fred.stlouisfed.org/graph/fredgraph.csv?g={graphId}`
- API v1 observaciones: `https://api.stlouisfed.org/fred/series/observations?series_id={id}&api_key=...&file_type=json`
 - Referencia oficial de parámetros: [FRED observations API docs](https://fred.stlouisfed.org/docs/api/fred/series_observations.html)


