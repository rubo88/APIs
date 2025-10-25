# Función mínima para descargar indicadores de REE e·sios (JSON -> data.frame)

library(httr)
library(jsonlite)

# esios_api_function: descarga valores de un indicador con filtros comunes
# - indicator_id: id numérico del indicador (p. ej., 1001, 10211)
# - start_date, end_date: ISO8601 ("YYYY-MM-DDTHH:MM:SSZ")
# - time_agg: "sum"|"avg"
# - time_trunc: "five_minutes"|"ten_minutes"|"fifteen_minutes"|"hour"|"day"|"month"|"year"
# - geo_agg: "sum"|"avg"
# - geo_trunc: "country"|"electric_system"|"autonomous_community"|"province"|"electric_subsystem"|"town"|"drainage_basin"
# - geo_ids: vector opcional de ids geográficos (num/char)
# - locale: "es"|"en"
# - token: por defecto toma Sys.getenv("ESIOS_TOKEN")

esios_api_function <- function(
  indicator_id,
  start_date,
  end_date,
  time_agg = NULL,
  time_trunc = NULL,
  geo_agg = NULL,
  geo_trunc = NULL,
  geo_ids = NULL,
  locale = "es",
  token = Sys.getenv("ESIOS_TOKEN")
) {
  if (missing(indicator_id)) stop("'indicator_id' es obligatorio")
  if (missing(start_date) || missing(end_date)) stop("'start_date' y 'end_date' son obligatorios (ISO8601)")
  if (!nzchar(token)) stop("Defina su token en la variable de entorno ESIOS_TOKEN o páselo en 'token'")

  base_url <- paste0("https://api.esios.ree.es/indicators/", indicator_id)

  # Construcción de parámetros
  q <- list(start_date = start_date, end_date = end_date)
  if (!is.null(time_agg))   q$time_agg <- match.arg(tolower(time_agg), c("sum","avg","average"))
  if (!is.null(time_trunc)) q$time_trunc <- match.arg(tolower(time_trunc), c("five_minutes","ten_minutes","fifteen_minutes","hour","day","month","year"))
  if (!is.null(geo_agg))    q$geo_agg <- match.arg(tolower(geo_agg), c("sum","avg","average"))
  if (!is.null(geo_trunc))  q$geo_trunc <- match.arg(tolower(geo_trunc), c("country","electric_system","autonomous_community","province","electric_subsystem","town","drainage_basin"))
  if (!is.null(geo_ids) && length(geo_ids)) {
    # Repetir parámetro geo_ids[] por cada valor
    for (g in as.character(geo_ids)) q <- c(q, setNames(list(g), "geo_ids[]"))
  }

  hdrs <- httr::add_headers(
    "x-api-key" = token,
    "Accept" = "application/json; application/vnd.esios-api-v1+json",
    "Accept-Language" = locale,
    "Content-Type" = "application/json"
  )

  res <- httr::GET(base_url, query = q, hdrs)
  if (httr::http_error(res)) stop(sprintf("ESIOS request failed [%s]", httr::status_code(res)))

  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  obj <- jsonlite::fromJSON(txt, flatten = TRUE)

  # Normalizar: valores suelen venir en indicator$values
  values_df <- NULL
  if (!is.null(obj$indicator$values)) {
    values_df <- obj$indicator$values
  } else if (!is.null(obj$values)) {
    values_df <- obj$values
  } else {
    stop("Estructura de respuesta inesperada; no se encontró 'indicator.values'.")
  }
  if ("value" %in% names(values_df)) values_df$value <- suppressWarnings(as.numeric(values_df$value))
  return(values_df)
}


