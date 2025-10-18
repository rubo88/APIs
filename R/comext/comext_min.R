# Descargador Eurostat COMEXT (CSV con etiquetas por dimensión)
# ----------------------------------------------------------------------------
# Objetivo
#   Descarga datos del endpoint Comext (Eurostat) en formato JSON y los convierte a un CSV "largo" con columnas
# ----------------------------------------------------------------------------

library(httr)
library(jsonlite)

# Carga utilidades locales
source("comext_utils.R")

# --- Parámetros editables -----------------------------------------------------
# ID del dataset Comext (prefijo DS-)
dataset_id <- "DS-059341"

# Dimensiones (aceptan vectores). Se enviarán como parámetros repetidos.
reporter <- c("ES")
partner  <- c("US")
product  <- c("1509", "8703")
flow     <- c("2")
freq     <- c("A")
time     <- 2015:2020

# Salida
output_name <- "comext_ejemplo"
out_file <- paste0("data/", output_name, ".csv")

# --- Construcción de la query-string ----------------------------------------
add_multi <- function(q, name, values) {
  if (length(values) == 0) return(q)
  for (v in as.character(values)) q <- c(q, setNames(list(v), name))
  q
}

q <- list()
q <- add_multi(q, "reporter", reporter)
q <- add_multi(q, "partner",  partner)
q <- add_multi(q, "product",  product)
q <- add_multi(q, "flow",     flow)
q <- add_multi(q, "freq",     freq)
q <- add_multi(q, "time",     time)

if (!dir.exists("data")) dir.create("data", recursive = TRUE, showWarnings = FALSE)

# --- Construcción de URL y parámetros ----------------------------------------
base <- paste0("https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/", dataset_id)

# --- Petición HTTP y parseo --------------------------------------------------
res <- httr::GET(base, query = q, httr::accept("application/json"))
if (httr::http_error(res)) stop(sprintf("COMEXT request failed [%s]", httr::status_code(res)))

txt <- httr::content(res, as = "text", encoding = "UTF-8")
doc <- jsonlite::fromJSON(txt, simplifyVector = FALSE)

df <- comext_json_to_labeled_df(doc)

utils::write.csv(df, out_file, row.names = FALSE, na = "")


