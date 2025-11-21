# Ejemplo de uso de la función eurostat_api_function
library(httr)

#setwd("R/eurostat")
source("eurostat_function_check.R")

# Ejemplo de uso with check function
df <- eurostat_api_function_check(
  dataset_identifier = "nama_10_a64",
  filters = list(
    geo = c("IT"),
    na_item = c("B1G"),
    unit = "CLV20_MEUR",
    TIME_PERIOD = "ge:1995"
  ),
  toc_path = "table_of_contents_en.txt"
)

# Ejemplo de uso
#df <- eurostat_api_function(
#  dataset_identifier = "nama_10_a64",
#  filters = list(
#    geo = c("IT"),
#    na_item = c("B1G"),
#    unit = "CLV20_MEUR",
#    TIME_PERIOD = "ge:1995"
#  )
#)
#write.csv(df, "eurostat_example.csv", row.names = FALSE)