## Descargador mínimo de IMF SDMX 3.0 (CSV)
# Cómo personalizar:
# - Cambiar agency_identifier, dataset_identifier y dataset_version para seleccionar el dataset.
# - Cambiar data_selection para seleccionar las dimensiones del dataset. Buscar los datos en la web de IMF. Pinchar en ver el id de los valores y remplazar en el orden que aparecen las variables.
# - Cambiar filter_date para seleccionar las fechas del dataset.
# - Cambiar params para seleccionar los parámetros de la consulta.
# - Cambiar output_name para definir el nombre del archivo de salida.

library(httr)

#setwd("R/imf")
#Request
#https://api.imf.org/external/sdmx/3.0/data/{context}/{agencyID}/{resourceID}/{version}/{key}[?c][&updatedAfter][&firstNObservations][&lastNObservations][&dimensionAtObservation][&attributes][&measures][&includeHistory][&asOf]

########################################################
# --- Parámetros editables ---
########################################################
# URL base de la API
base_url <- "https://api.imf.org/external/sdmx/3.0/data/dataflow/"

# Identificadores de dataset
agency_identifier <- "IMF.STA"
dataset_identifier <- "QNEA"
dataset_version <- "+"                       # '+' for latest version

# Variables de la consulta (separar por + varios valores o usar '*')
# Use el key para filtrar país(es) y evite c[COUNTRY] si el servidor lo ignora
data_selection <- "ESP+FRA.B1GQ.Q.SA.XDC.Q"      # COUNTRY.INDICATOR.PRICE_TYPE.S_ADJUSTMENT.TYPE_OF_TRANSFORMATION.FREQUENCY

# Filtro de fecha (puede contener múltiples condiciones unidas con '+')
# Ejemplo mensual: ge:2020-01+le:2020-12
# Ejemplo trimestral: ge:2020-Q1+le:2020-Q4
filter_date <- list(
  TIME_PERIOD = c("ge:2020-Q1", "le:2020-Q4"))

# Parametros de la consulta
params <- list(
  dimensionAtObservation = "TIME_PERIOD",  # At the observation level
  attributes = "dsd",                      # Data Structure Definition
  measures = "all",                        # All measures
  includeHistory = "false"                 # No history
)

# Nombre del archivo de salida
output_name <- "imf_min.csv"

########################################################
# -- Construir la URL y query ---
########################################################
# -- Construir la URL ---
full_url <- paste0(
  base_url,
  agency_identifier, "/",
  dataset_identifier, "/",
  utils::URLencode(dataset_version, reserved = TRUE), "/",
  utils::URLencode(data_selection, reserved = TRUE)
)

# -- Construir la query ---
query <- params
if (length(filter_date)) {
  for (nm in names(filter_date)) {
    vals <- filter_date[[nm]]
    if (is.null(vals) || length(vals) == 0) next
    query[[sprintf("c[%s]", nm)]] <- paste(vals, collapse = "+")
  }
}

# -- Construir los headers ---
headers <- httr::add_headers(
  `Cache-Control` = "no-cache",
  Accept = "application/vnd.sdmx.data+csv;version=1.0.0, text/csv"
)

########################################################
# -- Hacer la petición ---
########################################################
res <- httr::GET(full_url, query = query, headers, httr::config(ssl_verifypeer = 0L, ssl_verifyhost = 0L))
httr::stop_for_status(res)

########################################################
# -- Guardar el resultado ---
########################################################
txt <- httr::content(res, as = "text", encoding = "UTF-8")
df <- read.csv(text = txt, stringsAsFactors = FALSE)
utils::write.csv(df, output_name, row.names = FALSE, na = "")



