# Función mínima para descargar datos de Eurostat (SDMX-CSV 2.0)

# Inputs obligatorios:
# - dataset_identifier: identificador del dataset
# - filters: lista de filtros
#
# Inputs opcionales:
# - agency_identifier: identificador de la agencia
# - dataset_version: versión del dataset
# - compress: compresión
# - format: formato
# - formatVersion: versión del formato
# - lang: idioma
# - labels: etiquetas
#
# Outputs:
# - df: data frame con los datos
#
# Example:
# df <- eurostat_api_function(
#   dataset_identifier = "nama_10_a64",
#   filters = list(geo = c("IT"), na_item = c("B1G"), unit = "CLV20_MEUR", TIME_PERIOD = "ge:1995")
# )

eurostat_api_function <- function(
  dataset_identifier,
  filters,
  agency_identifier = "ESTAT",
  dataset_version = "1.0",
  compress = "false",
  format = "csvdata",
  formatVersion = "2.0",
  lang = "en",
  labels = "name"
) {
  base_url <- "https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow"

  # Construir identificador completo: context/agency/dataset/version
  data_identifier <- paste(agency_identifier, dataset_identifier, dataset_version, sep = "/")
  url <- paste0(base_url, "/", data_identifier, "/")

  # Convertir filtros a parámetros tipo c[dimension]=valor1,valor2
  if (!is.list(filters)) stop("'filters' debe ser una lista nombrada de dimensiones -> valores")
  filters_params <- stats::setNames(
    lapply(filters, function(v) if (length(v) > 1) paste(v, collapse = ",") else v),
    paste0("c[", names(filters), "]")
  )

  common_params <- list(
    compress = compress,
    format = format,
    formatVersion = formatVersion,
    lang = lang,
    labels = labels
  )

  params <- c(filters_params, common_params)

  res <- httr::GET(url, query = params, httr::accept("application/vnd.sdmx.data+csv; version=2.0.0"))
  if (httr::http_error(res)) stop(sprintf("Eurostat request failed [%s]", httr::status_code(res)))

  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  df <- utils::read.csv(text = txt, stringsAsFactors = FALSE)

  return(df)
}
