# Descargador mínimo FMI (SDMX-JSON CompactData -> CSV)
#
# Cómo personalizar:
# - Cambie 'dataset' por el identificador del dataset del FMI (p. ej., "IFS")
# - Cambie 'key' por la clave SDMX (p. ej., "M.ES.PCPI_IX")
# - Ajuste 'startPeriod'/'endPeriod' si desea limitar el periodo
# - Cambie 'output_name' para el archivo CSV

library(httr)
library(jsonlite)

# --- Parámetros editables ---
dataset <- "IFS"                 # Dataset SDMX del FMI (International Financial Statistics)
key <- "M.ES.PCPI_IX"           # Frecuencia.País.Indicador (ejemplo IPC España, indice)
startPeriod <- "2018"
endPeriod <- "2023"
output_name <- "imf_ejemplo"
out_file <- paste0("data/", output_name, ".csv")

# --- Crear directorio de datos si no existe ---
if (!dir.exists("data")) dir.create("data", recursive = TRUE, showWarnings = FALSE)

# --- Construcción de URL y descarga ---
base_url <- "https://dataservices.imf.org/REST/SDMX_JSON.svc"
url <- paste0(base_url, "/CompactData/", dataset, "/", utils::URLencode(key, reserved = TRUE))
params <- list(startPeriod = startPeriod, endPeriod = endPeriod)

res <- httr::GET(url, query = params, httr::accept("application/json"))
if (httr::http_error(res)) stop(sprintf("IMF request failed [%s]", httr::status_code(res)))

txt <- httr::content(res, as = "text", encoding = "UTF-8")
obj <- jsonlite::fromJSON(txt, simplifyVector = FALSE)

# Extraer filas (serie -> observaciones)
extract_series_df <- function(ser) {
  nms <- names(ser)
  attr_names <- nms[startsWith(nms, "@")]
  dim_values <- if (length(attr_names)) lapply(attr_names, function(n) ser[[n]]) else list()
  names(dim_values) <- if (length(attr_names)) sub("^@", "", attr_names) else character(0)

  obs <- ser$Obs
  if (is.null(obs)) return(NULL)
  if (is.list(obs) && !is.null(obs[["@TIME_PERIOD"]])) obs <- list(obs)

  make_obs_row <- function(o) {
    tp <- o[["@TIME_PERIOD"]]; val <- o[["@OBS_VALUE"]]
    val_num <- suppressWarnings(as.numeric(val))
    data.frame(
      TIME_PERIOD = if (!is.null(tp)) tp else NA_character_,
      OBS_VALUE = if (!is.na(val_num)) val_num else suppressWarnings(as.numeric(NA)),
      stringsAsFactors = FALSE
    )
  }
  obs_rows <- lapply(obs, make_obs_row)
  obs_df <- do.call(rbind, obs_rows)

  if (length(dim_values)) {
    dim_df <- as.data.frame(dim_values, stringsAsFactors = FALSE)
    dim_df_rep <- dim_df[rep(1, nrow(obs_df)), , drop = FALSE]
    cbind(dim_df_rep, obs_df, stringsAsFactors = FALSE)
  } else {
    obs_df
  }
}

data_set <- obj$CompactData$DataSet
series_list <- if (!is.null(data_set)) data_set$Series else NULL
if (is.null(series_list)) stop("Estructura inesperada; falta 'Series'")
if (is.list(series_list) && !is.null(series_list$Obs)) series_list <- list(series_list)

rows <- lapply(series_list, extract_series_df)
rows <- rows[!vapply(rows, is.null, logical(1))]
if (!length(rows)) stop("Sin filas devueltas por la API del FMI")
df <- do.call(rbind, rows)

utils::write.csv(df, out_file, row.names = FALSE, na = "")


