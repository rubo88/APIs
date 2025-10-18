# Función mínima para descargar datos INE JAXIT3 (CSV)

# Inputs obligatorios:
# - tableId: identificador de la tabla INE (p.ej., "67821")
#
# Inputs opcionales:
# - nocab: controla cabecera ("1" evita cabeceras adicionales)
# - directory: segmento de directorio (por defecto "t")
# - locale: idioma (por defecto "es")
# - variant: variante de CSV (por defecto "csv_bdsc")
#
# Output:
# - df: data.frame con los datos descargados

ine_jaxi_api_function <- function(
  tableId,
  nocab = "1",
  directory = "t",
  locale = "es",
  variant = "csv_bdsc"
) {
  base_url <- "https://www.ine.es/jaxiT3/files"
  url <- paste0(base_url, "/", directory, "/", locale, "/", variant, "/", tableId, ".csv")

  res <- httr::GET(url, query = list(nocab = nocab), httr::accept("text/csv"))
  if (httr::http_error(res)) stop(sprintf("INE JAXIT3 request failed [%s]", httr::status_code(res)))

  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  df <- utils::read.csv(text = txt, stringsAsFactors = FALSE, sep = ";")
  return(df)
}


