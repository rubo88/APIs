# Descargador mínimo de OECD SDMX (CSV)
#
# Cómo personalizar:
# - Cambie 'data_identifier' para apuntar a {Agencia},{Dataset},{Versión}
# - Cambie 'data_selection' para seleccionar la clave (dimensiones) del dataset
# - Cambie 'params' (startPeriod, endPeriod, dimensionAtObservation)
# - Cambie 'output_name' para definir el nombre del archivo de salida
#
# Sintaxis oficial (OCDE):
# {Host URL}/{Agency identifier},{Dataset identifier},{Dataset version}/{Data selection}?{otros parámetros}

library(httr)

# --- Parámetros editables ---
# Identificadores de dataset
  base_url <- "https://sdmx.oecd.org/public/rest/data" # En principio no hace falta cambiarlo
  agency_identifier <- "OECD.ECO.MAD"
  dataset_identifier <- "DSD_EO@DF_EO"
  dataset_version <- ""
# Construir codigo completo  
  data_identifier <- paste0(agency_identifier, ",", dataset_identifier, ",", dataset_version)
# Rango de fechas y dimensiones
  data_selection <- "FRA+DEU.PDTY.A"
  params <- list(
    startPeriod = "1965",
    endPeriod = "2023",
    dimensionAtObservation = "AllDimensions"
  )
# Nombre del archivo de salida
  output_name <- "oecd_ejemplo"
  out_file <- paste0("data/", output_name, ".csv")

# --- Crear directorio de datos si no existe ---
if (!dir.exists("data")) dir.create("data", recursive = TRUE, showWarnings = FALSE)

# --- Descargar archivo CSV ---
url <- paste0(base_url, "/", data_identifier, "/", data_selection)
res <- httr::GET(url, query = params, httr::accept("text/csv"))
if (httr::http_error(res)) stop(sprintf("OECD request failed [%s]", httr::status_code(res)))
writeBin(httr::content(res, as = "raw"), out_file)


