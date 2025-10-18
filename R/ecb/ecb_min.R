# Minimal ECB Data API downloader (CSV)
#
# How to customize:
# - Change dataset (BSI) and seriesKey for the specific series
# - Change out_file to control the output file name

library(httr)

# --- Editable parameters ---
dataset <- "BSI"  # ECB dataset id
seriesKey <- "M.U2.Y.V.M30.X.I.U2.2300.Z01.A"
output_name <- "ecb_ejemplo"
out_file <- paste0("data/ecb_", gsub("[./]", "_", output_name), ".csv")

# --- Crear directorio de datos si no existe ---
if (!dir.exists("data")) dir.create("data", recursive = TRUE, showWarnings = FALSE)

# --- Descargar archivo CSV ---
url <- paste0("https://data-api.ecb.europa.eu/service/data/", dataset, "/", seriesKey)
res <- httr::GET(url, query = list(format = "csvdata"), httr::accept("text/csv"))
if (httr::http_error(res)) stop(sprintf("ECB request failed [%s]", httr::status_code(res)))
writeBin(httr::content(res, as = "raw"), out_file)


