# Función mínima para descargar datos del FMI (SDMX 3.0 → SDMX-CSV 1.0)
# Inspirada en eurostat_function.R, usando el flujo de imf_min.R
#
# Inputs obligatorios:
# - dataset_identifier: identificador del dataset (p. ej., "QNEA")
# - data_selection: clave SDMX (orden y códigos según el dataset), p. ej.,
#   "ESP.B1GQ.Q.SA.XDC.Q" o con múltiples países "ESP+FRA.B1GQ.Q.SA.XDC.Q".
#
# Inputs opcionales:
# - agency_identifier: p. ej., "IMF.STA"
# - dataset_version: p. ej., "+" (última versión)
# - filters: lista de filtros SDMX como c[TIME_PERIOD] = "ge:2020-Q1+le:2020-Q4".
#            Páselos como list(TIME_PERIOD = c("ge:2020-Q1","le:2020-Q4"))
#            Se convertirán a query params tipo c[TIME_PERIOD]="ge:...+le:...".
# - accept_csv_version: versión del formato SDMX-CSV (por defecto "1.0.0")
#
# Output:
# - data.frame leído de la respuesta CSV

imf_api_function <- function(
  dataset_identifier,
  data_selection,
  filters = list(),
  agency_identifier = "IMF.STA",
  dataset_version = "+",
  accept_csv_version = "1.0.0"
) {
  base_url <- "https://api.imf.org/external/sdmx/3.0/data/dataflow"

  # Construir ruta completa: {base}/{agency}/{dataset}/{version}/{key}
  # Codificamos cuidadosamente la versión ('+' -> %2B) y la clave
  url <- paste0(
    base_url, "/",
    agency_identifier, "/",
    dataset_identifier, "/",
    utils::URLencode(dataset_version, reserved = TRUE), "/",
    utils::URLencode(data_selection, reserved = TRUE)
  )

  # Construir filtros como c[DIM]=v1+v2 (TIME_PERIOD ge/le, etc.)
  if (!is.list(filters)) stop("'filters' debe ser una lista nombrada de dimensiones -> valores")
  filter_params <- list()
  if (length(filters)) {
    for (nm in names(filters)) {
      vals <- filters[[nm]]
      if (is.null(vals) || length(vals) == 0) next
      # Join con '+' (IMF acepta ge:...+le:... y múltiples valores con '+')
      filter_params[[paste0("c[", nm, "]")]] <- paste(vals, collapse = "+")
    }
  }

  headers <- httr::add_headers(
    `Cache-Control` = "no-cache",
    Accept = paste0("application/vnd.sdmx.data+csv;version=", accept_csv_version)
  )

  res <- httr::GET(url, query = filter_params, headers, httr::config(ssl_verifypeer = 0L, ssl_verifyhost = 0L))
  if (httr::http_error(res)) stop(sprintf("IMF request failed [%s]", httr::status_code(res)))

  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  df <- utils::read.csv(text = txt, stringsAsFactors = FALSE)
  return(df)
}


