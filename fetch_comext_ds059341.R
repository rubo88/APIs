# Fetch Eurostat COMEXT DS-059341 for Spain↔US for a chosen HS product and save as CSV

ensure_package <- function(package_name) {
  if (!requireNamespace(package_name, quietly = TRUE)) {
    install.packages(package_name, repos = "https://cloud.r-project.org")
  }
  invisible(TRUE)
}

required_packages <- c("httr", "jsonlite")
for (pkg in required_packages) ensure_package(pkg)

library(httr)
library(jsonlite)

set_config(user_agent("api-checker/1.0 (+https://example.org)"))

create_data_dir <- function(directory_path) {
  if (!dir.exists(directory_path)) {
    dir.create(directory_path, recursive = TRUE, showWarnings = FALSE)
  }
}

# --- Helpers: parse COMEXT dissemination JSON (SDMX-like) into a tidy data.frame ---
get_stride_vector <- function(sizes) {
  n <- length(sizes)
  strides <- integer(n)
  for (k in seq_len(n)) {
    if (k == n) {
      strides[k] <- 1
    } else {
      strides[k] <- prod(sizes[(k + 1):n])
    }
  }
  strides
}

pos_to_code <- function(index_map, pos) {
  codes <- names(index_map)[which(unname(index_map) == pos)]
  if (length(codes) == 0) return(NA_character_)
  codes[[1]]
}

flatten_comext_dataset <- function(doc) {
  ids <- doc$id
  sizes <- as.integer(unlist(doc$size))
  dims <- doc$dimension
  values_named <- doc$value
  if (is.null(values_named) || length(values_named) == 0) {
    return(data.frame())
  }
  value_keys <- as.integer(names(values_named))
  value_vals <- as.numeric(unlist(values_named, use.names = FALSE))

  strides <- get_stride_vector(sizes)
  n_dims <- length(sizes)

  rows <- vector("list", length(value_keys))

  for (i in seq_along(value_keys)) {
    idx <- value_keys[[i]]
    remaining <- idx
    positions <- integer(n_dims)
    for (k in seq_len(n_dims)) {
      positions[k] <- remaining %/% strides[k]
      remaining <- remaining %% strides[k]
    }

    dim_codes <- list()
    dim_labels <- list()
    for (k in seq_along(ids)) {
      dim_name <- ids[[k]]
      dim_info <- dims[[dim_name]]
      if (is.null(dim_info)) next
      index_map <- unlist(dim_info$category$index)
      label_map <- dim_info$category$label
      code_k <- pos_to_code(index_map, positions[k])
      label_k <- if (!is.null(label_map) && !is.null(code_k)) label_map[[code_k]] else NA_character_
      dim_codes[[dim_name]] <- code_k
      dim_labels[[paste0(dim_name, "_label")]] <- label_k
    }

    rows[[i]] <- c(dim_codes, dim_labels, list(value = value_vals[[i]]))
  }

  all_cols <- unique(unlist(lapply(rows, names)))
  make_row_df <- function(x) {
    y <- stats::setNames(vector("list", length(all_cols)), all_cols)
    for (nm in names(x)) y[[nm]] <- x[[nm]]
    as.data.frame(y, stringsAsFactors = FALSE)
  }
  row_dfs <- lapply(rows, make_row_df)
  df <- do.call(rbind, row_dfs)

  if ("value" %in% names(df)) df$value <- as.numeric(df$value)
  df
}

main <- function() {
  data_dir <- "data"
  create_data_dir(data_dir)

  # Parameters: Spain (ES), United States (US), HS4 1509 (Olive oil), exports, annual, 2020
  api <- "https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/DS-059341"
  out_path <- file.path(data_dir, "comext_ES_US_1509.csv")
  message("Downloading COMEXT DS-059341 (ES→US, HS 1509) → ", out_path)

  resp <- RETRY(
    verb = "GET",
    url = api,
    query = list(
      reporter = "ES",
      partner = "US",
      product = "1509",
      flow = "2",      # 2 = EXPORTS (1 = IMPORTS)
      freq = "A",
      time = "2020"
    ),
    times = 3,
    pause_min = 1,
    pause_cap = 4,
    terminate_on = c(400, 401, 403, 404),
    httr::accept("application/json")
  )
  if (http_error(resp)) {
    stop(sprintf("COMEXT request failed [%s]", status_code(resp)))
  }
  txt <- content(resp, as = "text", encoding = "UTF-8")
  doc <- jsonlite::fromJSON(txt, simplifyVector = FALSE)
  df <- flatten_comext_dataset(doc)
  utils::write.csv(df, out_path, row.names = FALSE, na = "")

  message("Saved: ", normalizePath(out_path))
}

if (identical(environment(), globalenv())) {
  tryCatch(
    expr = main(),
    error = function(e) {
      message("Error: ", conditionMessage(e))
      quit(status = 1)
    }
  )
}
