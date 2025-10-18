# Descargador mínimo de Eurostat (CSV)
#
# Cómo personalizar:
# - Cambiar dataset_identifier por el codigo de la serie de interés.
# - Cambiar filters para seleccionar las dimensiones de la serie de interés. Si no queremos filtrar, no incluimos la variable en la lista.

library(httr)

# --- Parámetros editables ---
# Identificadores de dataset
  base_url <- "https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow" # Endpoint SDMX 3.0 de Eurostat
  agency_identifier <- "ESTAT"
  dataset_identifier <- "nama_10_a64"
  dataset_version <- "1.0"

# Filtros (modificar libremente)
  filters <- list(
    geo = c("ES", "FR"),
    na_item = c("B1G", "P1"),
    unit = "CLV20_MEUR",
    TIME_PERIOD = "ge:1995"
  )

# Parámetros comunes de salida (SDMX-CSV 2.0)
  common_params <- list(
    compress = "false",
    format = "csvdata",
    formatVersion = "2.0",
    lang = "en",
    labels = "name"
  )

# Nombre del archivo de salida
  output_name <- "eurostat_ejemplo"
  out_file <- paste0("data/", output_name, ".csv")


# -- Construir la URL ---
# Construir ruta completa (context/agency/dataset/version)
  data_identifier <- paste(agency_identifier, dataset_identifier, dataset_version, sep = "/")
  url <- paste0(base_url, "/", data_identifier, "/")
# Convertir filtros a parámetros tipo c[...]=
  filters_params <- setNames(
    lapply(filters, function(v) if (length(v) > 1) paste(v, collapse = ",") else v),
    paste0("c[", names(filters), "]")
  )
  params <- c(filters_params, common_params)

# --- Crear directorio de datos si no existe ---
if (!dir.exists("data")) dir.create("data", recursive = TRUE, showWarnings = FALSE)

# --- Descargar archivo CSV and store in a data frame---
res <- httr::GET(url, query = params, httr::accept("application/vnd.sdmx.data+csv; version=2.0.0"))
if (httr::http_error(res)) stop(sprintf("Eurostat request failed [%s]", httr::status_code(res)))
txt <- httr::content(res, as = "text", encoding = "UTF-8")
df <- read.csv(text = txt, stringsAsFactors = FALSE)
utils::write.csv(df, out_file, row.names = FALSE, na = "")
