# Ejemplo de uso de la función comext_api_function
library(httr)
library(jsonlite)

#setwd("comext")
source("comext_function.R")

# Ejemplo de uso
df <- comext_api_function(
  dataset_id = "DS-059341",
  filters = list(
    reporter = c("ES"),
    partner  = c("US"),
    product  = c("1509", "8703"),
    flow     = c("2"),
    freq     = c("A"),
    time     = 2015:2020
  )
)

write.csv(df, "comext_example.csv", row.names = FALSE)


