# Descargador mínimo REE e·sios (JSON -> CSV)
#
# Cómo personalizar:
# - Defina el ID del indicador en 'indicator_id' (por defecto: precio spot OMIE)
# - Cambie 'output_name' para definir el nombre del archivo de salida (CSV)
# - Exporte su token personal en la variable de entorno ESIOS_TOKEN
#
# Referencia API:
# - Documentación general: https://www.esios.ree.es/es/pagina/api
# - Endpoints v2: https://api.esios.ree.es/

library(httr)
library(jsonlite)

# --- Parámetros editables ---
# Indicador de precio diario/horario del mercado (por defecto, mercado spot)
indicator_id <- 1001
output_name <- "esios_precio_hoy"
out_file <- paste0("data/", output_name, ".csv")

# Token personal desde variable de entorno
token <- Sys.getenv("ESIOS_TOKEN", unset = "")
if (token == "") {
  stop("Debe definir la variable de entorno ESIOS_TOKEN con su token personal de e·sios.")
}

# --- Crear directorio de datos si no existe ---
if (!dir.exists("data")) dir.create("data", recursive = TRUE, showWarnings = FALSE)

# --- Fechas: hoy UTC ---
today <- Sys.Date()
start_date <- paste0(format(today, "%Y-%m-%d"), "T00:00:00Z")
end_date   <- paste0(format(today, "%Y-%m-%d"), "T23:59:59Z")

# --- Descargar JSON ---
base_url <- paste0("https://api.esios.ree.es/indicators/", indicator_id)
hdrs <- httr::add_headers(
  "x-api-key" = token,
  "Accept" = "application/json",
  "Accept-Language" = "es",
  "Content-Type" = "application/json"
)

res <- httr::GET(base_url, query = list(start_date = start_date, end_date = end_date), hdrs)
if (httr::http_error(res)) stop(sprintf("ESIOS request failed [%s]", httr::status_code(res)))

txt <- httr::content(res, as = "text", encoding = "UTF-8")
obj <- jsonlite::fromJSON(txt, flatten = TRUE)

# La estructura típica es obj$indicator$values
values_df <- NULL
if (!is.null(obj$indicator$values)) {
  values_df <- obj$indicator$values
} else if (!is.null(obj$values)) {
  values_df <- obj$values
} else {
  stop("Estructura de respuesta inesperada; no se encontró 'indicator.values'.")
}

# Coaccionar 'value' a numérico si existe
if ("value" %in% names(values_df)) values_df$value <- suppressWarnings(as.numeric(values_df$value))

utils::write.csv(values_df, out_file, row.names = FALSE, na = "")


