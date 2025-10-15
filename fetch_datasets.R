# Fetch example datasets from OECD, INE (JAXIT3 and WSTempus), World Bank, ECB, and FRED

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

write_binary_response <- function(response, destination_path) {
  if (http_error(response)) {
    stop(sprintf("Request failed [%s] %s", status_code(response), destination_path))
  }
  bin <- content(response, as = "raw")
  con <- file(destination_path, open = "wb")
  on.exit(close(con), add = TRUE)
  writeBin(bin, con)
  invisible(destination_path)
}

fetch_csv <- function(url, destination_path, query = list(), headers = list()) {
  response <- RETRY(
    verb = "GET",
    url = url,
    query = query,
    times = 3,
    pause_min = 1,
    pause_cap = 4,
    terminate_on = c(400, 401, 403, 404),
    httr::accept("text/csv"),
    do.call(httr::add_headers, headers)
  )
  write_binary_response(response, destination_path)
}

fetch_json <- function(url, destination_path, query = list(), headers = list()) {
  response <- RETRY(
    verb = "GET",
    url = url,
    query = query,
    times = 3,
    pause_min = 1,
    pause_cap = 4,
    terminate_on = c(400, 401, 403, 404),
    httr::accept("application/json"),
    do.call(httr::add_headers, headers)
  )
  if (http_error(response)) {
    stop(sprintf("Request failed [%s] %s", status_code(response), destination_path))
  }
  txt <- content(response, as = "text", encoding = "UTF-8")
  writeLines(txt, con = destination_path, useBytes = TRUE)
  invisible(destination_path)
}

save_worldbank_json_as_csv <- function(url, destination_csv_path, query = list()) {
  response <- RETRY(
    verb = "GET",
    url = url,
    query = query,
    times = 3,
    pause_min = 1,
    pause_cap = 4,
    terminate_on = c(400, 401, 403, 404),
    httr::accept("application/json")
  )
  if (http_error(response)) {
    stop(sprintf("World Bank request failed [%s]", status_code(response)))
  }
  wb_json <- content(response, as = "text", encoding = "UTF-8")
  wb_list <- jsonlite::fromJSON(wb_json, flatten = TRUE)
  if (length(wb_list) < 2 || is.null(wb_list[[2]])) {
    stop("Unexpected World Bank response structure; no data array present.")
  }
  data_frame <- wb_list[[2]]
  utils::write.csv(data_frame, destination_csv_path, row.names = FALSE, na = "")
  invisible(destination_csv_path)
}

main <- function() {
  data_dir <- "data"
  create_data_dir(data_dir)

  # 1) OECD SDMX: Economic Outlook - Trade in volume per capita (example)
  # Request CSV via Accept header; remove contentType query parameter
  oecd_url <- "https://sdmx.oecd.org/public/rest/data/OECD.ECO.MAD,DSD_EO_LTB@DF_EO_LTB,/.GDPVTRD_CAP..A"
  oecd_path <- file.path(data_dir, "oecd_eo_gdpvtrd_cap_2026_2030.csv")
  message("Downloading OECD SDMX CSV → ", oecd_path)
  fetch_csv(
    url = oecd_url,
    destination_path = oecd_path,
    query = list(
      startPeriod = "2026",
      endPeriod = "2030",
      dimensionAtObservation = "AllDimensions"
    )
  )

  # 2) INE JAXIT3 CSV (example dataset 67821)
  ine_jaxi_url <- "https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/67821.csv"
  ine_jaxi_path <- file.path(data_dir, "ine_jaxi_67821.csv")
  message("Downloading INE JAXIT3 CSV → ", ine_jaxi_path)
  fetch_csv(
    url = ine_jaxi_url,
    destination_path = ine_jaxi_path,
    query = list(nocab = "1")
  )

  # 3) INE WSTempus JSON: Use available operations to confirm access
  wstempus_ops_url <- "https://servicios.ine.es/wstempus/js/ES/OPERACIONES_DISPONIBLES"
  wstempus_ops_path <- file.path(data_dir, "ine_wstempus_operaciones.json")
  message("Downloading INE WSTempus OPERACIONES_DISPONIBLES JSON → ", wstempus_ops_path)
  fetch_json(
    url = wstempus_ops_url,
    destination_path = wstempus_ops_path
  )

  # 4) World Bank: GDP growth (annual %) for Spain (NY.GDP.MKTP.KD.ZG)
  wb_url <- "https://api.worldbank.org/v2/country/ESP/indicator/NY.GDP.MKTP.KD.ZG"
  wb_path <- file.path(data_dir, "worldbank_ESP_gdp_growth.csv")
  message("Downloading World Bank GDP growth for Spain → ", wb_path)
  save_worldbank_json_as_csv(
    url = wb_url,
    destination_csv_path = wb_path,
    query = list(format = "json", per_page = 20000)
  )

  # 5) ECB Data API: BSI series (dataset BSI, series M.U2.Y.V.M30.X.I.U2.2300.Z01.A)
  ecb_url <- "https://data-api.ecb.europa.eu/service/data/BSI/M.U2.Y.V.M30.X.I.U2.2300.Z01.A"
  ecb_path <- file.path(data_dir, "ecb_bsi_M_U2_Y_V_M30_X_I_U2_2300_Z01_A.csv")
  message("Downloading ECB BSI CSV → ", ecb_path)
  fetch_csv(
    url = ecb_url,
    destination_path = ecb_path,
    query = list(format = "csvdata")
  )

  # 6) FRED: Use fredgraph CSV export for the given graph id
  fred_graph_url <- "https://fred.stlouisfed.org/graph/fredgraph.csv"
  fred_path <- file.path(data_dir, "fred_graph_1wmdD.csv")
  message("Downloading FRED graph CSV → ", fred_path)
  fetch_csv(
    url = fred_graph_url,
    destination_path = fred_path,
    query = list(g = "1wmdD")
  )

  message("All downloads completed. Files saved under: ", normalizePath(data_dir))
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
