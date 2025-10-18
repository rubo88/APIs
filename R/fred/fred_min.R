# Descargador mínimo FRED (fredgraph CSV)
#
# Cómo personalizar:
# - Cambie 'graphId' por el identificador del gráfico compartido en FRED
# - Cambie 'out_file' para definir el nombre del archivo de salida (CSV)

library(httr)

# --- Parámetros editables ---
graphId <- "1wmdD"
output_name <- "fred_graph_ejemplo"
out_file <- paste0("data/", output_name, ".csv")

# --- Crear directorio de datos si no existe ---
if (!dir.exists("data")) dir.create("data", recursive = TRUE, showWarnings = FALSE)

# --- Descargar archivo CSV ---
url <- "https://fred.stlouisfed.org/graph/fredgraph.csv"
res <- httr::GET(url, query = list(g = graphId), httr::accept("text/csv"))
if (httr::http_error(res)) stop(sprintf("FRED fredgraph request failed [%s]", httr::status_code(res)))
writeBin(httr::content(res, as = "raw"), out_file)


