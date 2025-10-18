# Descargador mínimo INE JAXIT3 (CSV)
#
# Cómo personalizar:
# - Cambie 'tableId' por la tabla objetivo. 
# - Mantenga o quite 'nocab=1' según si desea cabeceras sin etiquetas
# - Cambie 'out_file' para definir el nombre del archivo de salida

library(httr)

# --- Parámetros editables ---
tableId <- "67821"      # Ejemplo de ID de tabla (el numero al final de la url en ine.es)
nocab <- "1"            # "1" para evitar cabeceras adicionales
output_name <- "ine_ejemplo"

# --- Crear directorio de datos si no existe ---
out_file <- paste0("data/", output_name, ".csv")
if (!dir.exists("data")) dir.create("data", recursive = TRUE, showWarnings = FALSE)

# --- Descargar archivo CSV ---
url <- paste0("https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/", tableId, ".csv")
res <- httr::GET(url, query = list(nocab = nocab), httr::accept("text/csv"))
if (httr::http_error(res)) stop(sprintf("INE JAXIT3 request failed [%s]", httr::status_code(res)))
writeBin(httr::content(res, as = "raw"), out_file)


