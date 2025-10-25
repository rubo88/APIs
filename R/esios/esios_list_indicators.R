# Listado de indicadores ESIOS (JSON -> CSV)

library(httr)
library(jsonlite)

# --- Parámetros ---
output_name <- "esios_indicators"
out_file <- paste0( output_name, ".csv")

# Requiere token en variable de entorno ESIOS_TOKEN
Sys.setenv(ESIOS_TOKEN = "c9957840f6e4bbdc76f4958cd33676cc1f97665758a55b21ea006a5fbbd660b3")
token <- Sys.getenv("ESIOS_TOKEN")
if (!nzchar(token)) stop("Defina su token en la variable de entorno ESIOS_TOKEN")

# --- Llamada a API: listado de indicadores ---
base_url <- "https://api.esios.ree.es/indicators"
hdrs <- httr::add_headers(
  "x-api-key" = token,
  "Accept" = "application/json",
  "Accept-Language" = "es",
  "Content-Type" = "application/json"
)

res <- httr::GET(base_url, query = list(locale = "es"), hdrs)
if (httr::http_error(res)) stop(sprintf("ESIOS request failed [%s]", httr::status_code(res)))

txt <- httr::content(res, as = "text", encoding = "UTF-8")
obj <- jsonlite::fromJSON(txt, flatten = TRUE)

indicators_df <- NULL
if (!is.null(obj$indicators)) {
  indicators_df <- obj$indicators
} else if (!is.null(obj$data$indicators)) {
  indicators_df <- obj$data$indicators
} else {
  stop("Estructura de respuesta inesperada; no se encontró 'indicators'.")
}

utils::write.csv(indicators_df, out_file, row.names = FALSE, na = "")


