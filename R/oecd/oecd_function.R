# Función mínima para descargar datos de OECD SDMX (CSV)

# Inputs obligatorios:
# - agency_identifier: identificador de la agencia, p. ej. "OECD.ECO.MAD"
# - dataset_identifier: identificador del dataset, p. ej. "DSD_EO@DF_EO"
# - data_selection: clave SDMX (dimensiones) tras la '/'
#
# Inputs opcionales:
# - base_url: host de la API SDMX
# - dataset_version: versión del dataset
# - startPeriod, endPeriod, dimensionAtObservation: parámetros comunes de consulta
#
# Output:
# - df: data.frame con los datos descargados

oecd_api_function <- function(
  agency_identifier,
  dataset_identifier,
  data_selection,
  base_url = "https://sdmx.oecd.org/public/rest/data",
  dataset_version = "",
  startPeriod = NULL,
  endPeriod = NULL,
  dimensionAtObservation = NULL
) {
  data_identifier <- paste0(agency_identifier, ",", dataset_identifier, ",", dataset_version)

  params <- list()
  if (!is.null(startPeriod)) params$startPeriod <- startPeriod
  if (!is.null(endPeriod)) params$endPeriod <- endPeriod
  if (!is.null(dimensionAtObservation)) params$dimensionAtObservation <- dimensionAtObservation

  url <- paste0(base_url, "/", data_identifier, "/", data_selection)
  res <- httr::GET(url, query = params, httr::accept("text/csv"))
  if (httr::http_error(res)) stop(sprintf("OECD request failed [%s]", httr::status_code(res)))

  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  df <- utils::read.csv(text = txt, stringsAsFactors = FALSE)
  return(df)
}


