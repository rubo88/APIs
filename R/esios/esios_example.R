# Ejemplo de uso de la función esios_api_function
library(httr)
library(jsonlite)

#setwd("R/esios")
source("esios_function.R")

# Ejemplo: precio medio horario final (suma de componentes) id=10211
# Objetivo: promedio nacional por día del último mes

# Clave API
token <- Sys.getenv("ESIOS_TOKEN")

# Fechas ISO8601 (UTC)
end_date_date <- Sys.Date()
start_date_date <- end_date_date - 30
start_date <- paste0(format(start_date_date, "%Y-%m-%d"), "T00:00:00Z")
end_date   <- paste0(format(end_date_date, "%Y-%m-%d"), "T23:59:59Z")

df <- esios_api_function(
  indicator_id = 10211,
  start_date = start_date,
  end_date = end_date,
  time_agg = "avg",
  time_trunc = "day",
  geo_agg = "avg",
  geo_trunc = "country",
  locale = "es"
)

write.csv(df, "esios_example.csv", row.names = FALSE)




