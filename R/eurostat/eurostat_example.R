# Ejemplo de uso de la función eurostat_api_function
library(httr)

#setwd("eurostat")
source("eurostat_function.R")

# Ejemplo de uso
df <- eurostat_api_function(
  dataset_identifier = "nama_10_a64",
  filters = list(
    geo = c("IT"),
    na_item = c("B1G"),
    unit = "CLV20_MEUR",
    TIME_PERIOD = "ge:1995"
  )
)

write.csv(df, "eurostat_example.csv", row.names = FALSE)