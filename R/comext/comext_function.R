# Función para descargar y etiquetar datos de Eurostat COMEXT (JSON -> data.frame)

# Inputs obligatorios:
# - dataset_id: id del dataset Comext (p. ej., "DS-059341")
# - filters: lista nombrada (dimension -> valores). Los nombres deben ser las
#            dimensiones válidas del dataset (p. ej., reporter, partner, product,
#            flow, freq, time, indicators, etc.). Los valores pueden ser string o
#            vector de strings. Para multiselección se envían parámetros repetidos.
#
# Output:
# - df: data.frame con códigos por dimensión, etiquetas *_label y la columna numeric 'value'

comext_api_function <- function(
  dataset_id,
  filters
) {
  base <- paste0("https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/", dataset_id)

  if (missing(filters) || is.null(filters)) stop("'filters' debe ser una lista nombrada dimension -> valores")
  if (!is.list(filters) || is.null(names(filters)) || any(names(filters) == "")) {
    stop("'filters' debe ser una lista NOMBRADA: names(filters) son las dimensiones")
  }

  # Construye query string con parámetros repetidos para multiselección
  q <- list()
  for (dim_name in names(filters)) {
    values <- filters[[dim_name]]
    if (is.null(values)) next
    values <- as.character(values)
    for (v in values) {
      q <- c(q, setNames(list(v), dim_name))
    }
  }

  res <- httr::GET(base, query = q, httr::accept("application/json"))
  if (httr::http_error(res)) stop(sprintf("COMEXT request failed [%s]", httr::status_code(res)))

  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  doc <- jsonlite::fromJSON(txt, simplifyVector = FALSE)

  # utilidades locales (o usar scripts/comext_utils.R según la organización)
  if (!exists("comext_json_to_labeled_df")) source("comext_utils.R")
  df <- comext_json_to_labeled_df(doc)
  return(df)
}


