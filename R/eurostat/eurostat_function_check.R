# Función mínima para descargar datos de Eurostat (SDMX-CSV 2.0)

# Inputs obligatorios:
# - dataset_identifier: identificador del dataset
# - filters: lista de filtros
#
# Inputs opcionales:
# - agency_identifier: identificador de la agencia
# - dataset_version: versión del dataset
# - compress: compresión
# - format: formato
# - formatVersion: versión del formato
# - lang: idioma
# - labels: etiquetas
#
# Outputs:
# - df: data frame con los datos
#
# Example:
# df <- eurostat_api_function(
#   dataset_identifier = "nama_10_a64",
#   filters = list(geo = c("IT"), na_item = c("B1G"), unit = "CLV20_MEUR", TIME_PERIOD = "ge:1995")
# )

eurostat_api_function_check <- function(
  dataset_identifier,
  filters,
  agency_identifier = "ESTAT",
  dataset_version = "1.0",
  compress = "false",
  format = "csvdata",
  formatVersion = "2.0",
  lang = "en",
  labels = "name",
  toc_path = NULL
) {
  # Endpoints (SDMX 3.0)
  # Eurostat CSV 2.0 data endpoint (works with path including 'dataflow')
  data_endpoint_base <- "https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow"
  # Nota: validación por metadatos deshabilitada en modo local; mantener solo endpoint de datos

  # -----------------------
  # Validaciones de entrada
  # -----------------------
  if (!is.character(dataset_identifier) || length(dataset_identifier) != 1 || nchar(dataset_identifier) == 0) {
    stop("'dataset_identifier' debe ser un string no vacío", call. = FALSE)
  }
  if (!is.list(filters) || is.null(names(filters)) || any(names(filters) == "")) {
    stop("'filters' debe ser una lista NOMBRADA: lista(dimension = valores)", call. = FALSE)
  }
  # Validar tipos de valores de filtros y que no haya NA/NULL
  bad_filter_values <- names(Filter(function(v) {
    is.null(v) || length(v) == 0 || any(is.na(v)) || !(is.character(v) || is.numeric(v) || is.logical(v))
  }, filters))
  if (length(bad_filter_values) > 0) {
    stop(sprintf(
      "Los siguientes filtros tienen valores inválidos: %s. Use vectores de character/numeric/logical sin NA.",
      paste(bad_filter_values, collapse = ", ")
    ), call. = FALSE)
  }

  # -----------------------------------------
  # Verificar existencia del dataset (local TOC solamente)
  # -----------------------------------------
  # Validación local usando ÚNICAMENTE table_of_contents_en.txt (TSV)
  if (is.null(toc_path)) {
    toc_candidates <- c(
      "table_of_contents_en.txt",
      file.path(getwd(), "table_of_contents_en.txt")
    )
    toc_candidates <- unique(toc_candidates)
    for (cand in toc_candidates) {
      if (file.exists(cand)) { toc_path <- cand; break }
    }
  }
  if (is.null(toc_path) || !file.exists(toc_path)) {
    stop("No se encontró 'table_of_contents_en.txt'. Especifique 'toc_path' apuntando a ese archivo.", call. = FALSE)
  }
  # Archivo TSV: columnas incluyen "code"
  toc_df <- try(utils::read.delim(toc_path, sep = "\t", header = TRUE, quote = '"', stringsAsFactors = FALSE, check.names = FALSE), silent = TRUE)
  if (!inherits(toc_df, "try-error") && is.data.frame(toc_df) && "code" %in% names(toc_df)) {
    if (!any(toc_df$code == dataset_identifier, na.rm = TRUE)) {
      stop(sprintf(
        "Dataset no encontrado en table_of_contents_en.txt: id='%s'. Verifique el identificador localmente o actualice el TOC.",
        dataset_identifier
      ), call. = FALSE)
    }
  } else {
    # Fallback simple: búsqueda de la cadena con comillas
    toc_txt <- try(readLines(toc_path, warn = FALSE), silent = TRUE)
    if (!inherits(toc_txt, "try-error") && length(toc_txt) > 0) {
      needle <- paste0('"', dataset_identifier, '"')
      if (!any(grepl(needle, toc_txt, fixed = TRUE))) {
        stop(sprintf(
          "Dataset no encontrado en table_of_contents_en.txt: id='%s'.",
          dataset_identifier
        ), call. = FALSE)
      }
    }
  }

  # No usar validación por metadatos ni DSD cuando se solicita local-only: elegimos versión suministrada
  chosen_version <- dataset_version

  # -----------------------------------------
  # Construcción de la petición de datos (CSV 2.0)
  # Nota: mantenemos el endpoint actual usado en la función original
  # -----------------------------------------
  data_identifier <- paste(agency_identifier, dataset_identifier, chosen_version, sep = "/")
  url <- paste0(data_endpoint_base, "/", data_identifier, "/")

  # Convertir filtros a parámetros tipo c[dimension]=valor1,valor2
  filters_params <- stats::setNames(
    lapply(filters, function(v) if (length(v) > 1) paste(v, collapse = ",") else v),
    paste0("c[", names(filters), "]")
  )

  common_params <- list(
    compress = compress,
    format = format,
    formatVersion = formatVersion,
    lang = lang,
    labels = labels
  )

  params <- c(filters_params, common_params)

  res <- try(httr::GET(url, query = params, httr::accept("application/vnd.sdmx.data+csv; version=2.0.0"), httr::timeout(30)), silent = TRUE)
  if (inherits(res, "try-error") || is.null(res)) {
    stop("No se pudo conectar al endpoint de datos de Eurostat. Revise su conexión.", call. = FALSE)
  }
  if (httr::http_error(res)) {
    status_code <- httr::status_code(res)
    body_txt <- try(httr::content(res, as = "text", encoding = "UTF-8"), silent = TRUE)
    body_snippet <- if (!inherits(body_txt, "try-error") && nzchar(body_txt)) substr(body_txt, 1, 500) else ""

    hint <- switch(as.character(status_code),
      "400" = "Solicitud inválida: verifique nombres de dimensiones y formato de filtros.",
      "404" = "No se encontraron datos: verifique 'dataset_identifier' o que los filtros no sean contradictorios.",
      "406" = "No aceptable: verifique el encabezado Accept (CSV 2.0) o parámetros 'format/formatVersion'.",
      "413" = "Respuesta demasiado grande: refine los filtros para limitar el volumen.",
      NULL
    )

    base_msg <- sprintf("Eurostat devolvió error [HTTP %s]", status_code)
    if (!is.null(hint)) base_msg <- paste(base_msg, "-", hint)
    if (nzchar(body_snippet)) base_msg <- paste0(base_msg, ". Detalle: ", body_snippet)
    stop(base_msg, call. = FALSE)
  }

  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  if (!nzchar(txt)) {
    stop("Respuesta vacía recibida del servicio de datos de Eurostat.", call. = FALSE)
  }
  df <- utils::read.csv(text = txt, stringsAsFactors = FALSE)

  if (nrow(df) == 0) {
    stop(
      "La respuesta no contiene filas. Es probable que los filtros sean demasiado restrictivos o no coincidan con códigos válidos.",
      call. = FALSE
    )
  }

  return(df)
}
