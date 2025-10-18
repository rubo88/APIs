# Función mínima BCE Data API (CSV)

# Inputs obligatorios:
# - dataset: identificador del dataset (p. ej., "BSI")
# - seriesKey: clave completa de la serie (dimensiones concatenadas con '.')
#
# Inputs opcionales:
# - base_url: host del servicio de datos del BCE
#
# Output:
# - df: data.frame con los datos descargados

ecb_api_function <- function(
  dataset,
  seriesKey,
  base_url = "https://data-api.ecb.europa.eu/service/data"
) {
  url <- paste0(base_url, "/", dataset, "/", seriesKey)
  res <- httr::GET(url, query = list(format = "csvdata"), httr::accept("text/csv"))
  if (httr::http_error(res)) stop(sprintf("ECB request failed [%s]", httr::status_code(res)))

  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  df <- utils::read.csv(text = txt, stringsAsFactors = FALSE)
  return(df)
}


