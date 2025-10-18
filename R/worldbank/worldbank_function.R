# Función mínima para descargar datos del Banco Mundial (JSON -> data.frame)

# Inputs obligatorios:
# - iso3: código(s) de país ISO-3, separados por ';' si son múltiples
# - indicator: código(s) de indicador, separados por ';' si son múltiples
#
# Inputs opcionales:
# - date: rango temporal, p. ej., "2020:2023"
# - per_page: tamaño de página (use un valor alto para evitar paginación)
# - base_url: host de la API del Banco Mundial
#
# Output:
# - df: data.frame con los datos del elemento [2] de la respuesta JSON

worldbank_api_function <- function(
  iso3,
  indicator,
  date = NULL,
  per_page = 20000,
  base_url = "https://api.worldbank.org/v2"
) {
  path <- paste0("/country/", iso3, "/indicator/", indicator)
  url <- paste0(base_url, path)
  q <- list(format = "json", per_page = per_page)
  if (!is.null(date)) q$date <- date

  res <- httr::GET(url, query = q, httr::accept("application/json"))
  if (httr::http_error(res)) stop(sprintf("World Bank request failed [%s]", httr::status_code(res)))

  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  obj <- jsonlite::fromJSON(txt, flatten = TRUE)
  if (length(obj) < 2 || is.null(obj[[2]])) stop("Unexpected World Bank response structure; no data array present.")
  return(obj[[2]])
}


