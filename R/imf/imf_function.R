# Función mínima para descargar datos del FMI (SDMX-JSON CompactData -> data.frame)

# Inputs obligatorios:
# - dataset: identificador del dataset SDMX del FMI (p. ej., "IFS")
# - key: clave SDMX con dimensiones concatenadas por '.' (p. ej., "M.ES.PCPI_IX")
#
# Inputs opcionales:
# - startPeriod, endPeriod: filtros de periodo (p. ej., "2018", "2023")
# - base_url: host del servicio SDMX-JSON del FMI
#
# Output:
# - df: data.frame con las columnas de dimensiones de la serie, TIME_PERIOD y OBS_VALUE

imf_api_function <- function(
  dataset,
  key,
  startPeriod = NULL,
  endPeriod = NULL,
  base_url = "https://dataservices.imf.org/REST/SDMX_JSON.svc"
) {
  if (missing(dataset) || !nzchar(dataset)) stop("'dataset' es obligatorio (p. ej., 'IFS')")
  if (missing(key) || !nzchar(key)) stop("'key' es obligatorio (p. ej., 'M.ES.PCPI_IX')")

  url <- paste0(base_url, "/CompactData/", dataset, "/", utils::URLencode(key, reserved = TRUE))
  params <- list()
  if (!is.null(startPeriod)) params$startPeriod <- startPeriod
  if (!is.null(endPeriod)) params$endPeriod <- endPeriod

  res <- httr::GET(url, query = params, httr::accept("application/json"))
  if (httr::http_error(res)) stop(sprintf("IMF request failed [%s]", httr::status_code(res)))

  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  obj <- jsonlite::fromJSON(txt, simplifyVector = FALSE)

  # Navegar estructura SDMX-JSON CompactData
  data_set <- obj$CompactData$DataSet
  if (is.null(data_set)) return(data.frame())
  series_list <- data_set$Series
  if (is.null(series_list)) return(data.frame())

  # Normalizar a lista de series
  is_single_series <- is.list(series_list) && !is.null(series_list$Obs)
  if (is_single_series) series_list <- list(series_list)

  extract_series_df <- function(ser) {
    # Atributos de dimensiones (prefijo '@' en SDMX-JSON)
    nms <- names(ser)
    attr_names <- nms[startsWith(nms, "@")]
    dim_values <- if (length(attr_names)) lapply(attr_names, function(n) ser[[n]]) else list()
    names(dim_values) <- if (length(attr_names)) sub("^@", "", attr_names) else character(0)

    obs <- ser$Obs
    if (is.null(obs)) return(NULL)
    # Normalizar observaciones (puede venir un solo objeto en vez de lista)
    if (is.list(obs) && !is.null(obs[["@TIME_PERIOD"]])) obs <- list(obs)

    make_obs_row <- function(o) {
      tp <- o[["@TIME_PERIOD"]]; val <- o[["@OBS_VALUE"]]
      # Convertir a numerico si posible
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
      # Reciclar dimensiones por tantas filas como observaciones
      dim_df_rep <- dim_df[rep(1, nrow(obs_df)), , drop = FALSE]
      cbind(dim_df_rep, obs_df, stringsAsFactors = FALSE)
    } else {
      obs_df
    }
  }

  rows <- lapply(series_list, extract_series_df)
  rows <- rows[!vapply(rows, is.null, logical(1))]
  if (!length(rows)) return(data.frame())
  df <- do.call(rbind, rows)
  return(df)
}


