# Funciones para descargar datos de FRED

# 1) Método fredgraph (no requiere API key) -> CSV directo de un gráfico compartido
fredgraph_api_function <- function(graphId) {
  url <- "https://fred.stlouisfed.org/graph/fredgraph.csv"
  res <- httr::GET(url, query = list(g = graphId), httr::accept("text/csv"))
  if (httr::http_error(res)) stop(sprintf("FRED fredgraph request failed [%s]", httr::status_code(res)))
  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  df <- utils::read.csv(text = txt, stringsAsFactors = FALSE)
  return(df)
}

# 2) Método API v1 (requiere variable de entorno FRED_API_KEY) -> JSON con observaciones
fred_api_function <- function(
  series_id,
  observation_start = NULL,
  observation_end = NULL,
  realtime_start = NULL,
  realtime_end = NULL,
  limit = NULL,
  offset = NULL,
  sort_order = c("asc", "desc"),
  units = NULL,
  frequency = NULL,
  aggregation_method = NULL,
  output_type = NULL,
  vintage_dates = NULL,
  api_key = Sys.getenv("FRED_API_KEY", unset = NA_character_)
) {
  if (is.na(api_key) || api_key == "") stop("Defina la variable de entorno FRED_API_KEY para usar fred_api_function.")

  # Validaciones ligeras según documentación oficial
  if (!is.null(units)) {
    allowed_units <- c("lin", "chg", "ch1", "pch", "pc1", "pca", "cch", "cca", "log")
    if (!units %in% allowed_units) stop(sprintf("Valor de 'units' no válido: %s", units))
  }
  if (!is.null(frequency)) {
    allowed_freq <- c("d","w","bw","m","q","sa","a","wef","weth","wew","wetu","wem","wesu","wesa","bwew","bwem")
    if (!frequency %in% allowed_freq) stop(sprintf("Valor de 'frequency' no válido: %s", frequency))
  }
  if (!is.null(aggregation_method)) {
    allowed_agg <- c("avg","sum","eop")
    if (!aggregation_method %in% allowed_agg) stop(sprintf("Valor de 'aggregation_method' no válido: %s", aggregation_method))
  }
  if (!is.null(output_type)) {
    output_type <- as.integer(output_type)
    if (!output_type %in% c(1L,2L,3L,4L)) stop(sprintf("Valor de 'output_type' no válido: %s", output_type))
  }
  sort_order <- match.arg(sort_order)

  url <- "https://api.stlouisfed.org/fred/series/observations"
  q <- list(
    series_id = series_id,
    api_key = api_key,
    file_type = "json"
  )
  if (!is.null(observation_start)) q$observation_start <- observation_start
  if (!is.null(observation_end)) q$observation_end <- observation_end
  if (!is.null(realtime_start)) q$realtime_start <- realtime_start
  if (!is.null(realtime_end)) q$realtime_end <- realtime_end
  if (!is.null(limit)) q$limit <- limit
  if (!is.null(offset)) q$offset <- offset
  if (!is.null(sort_order)) q$sort_order <- sort_order
  if (!is.null(units)) q$units <- units
  if (!is.null(frequency)) q$frequency <- frequency
  if (!is.null(aggregation_method)) q$aggregation_method <- aggregation_method
  if (!is.null(output_type)) q$output_type <- output_type
  if (!is.null(vintage_dates)) q$vintage_dates <- vintage_dates

  res <- httr::GET(url, query = q, httr::accept("application/json"))
  if (httr::http_error(res)) stop(sprintf("FRED API request failed [%s]", httr::status_code(res)))
  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  obj <- jsonlite::fromJSON(txt, flatten = TRUE)
  if (is.null(obj$observations)) stop("Estructura inesperada de la API de FRED; falta 'observations'.")
  return(obj$observations)
}


