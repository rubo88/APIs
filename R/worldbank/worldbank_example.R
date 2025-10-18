# Ejemplo de uso de la función worldbank_api_function
library(httr)
library(jsonlite)

#setwd("worldbank")
source("worldbank_function.R")

# Ejemplo de uso
df <- worldbank_api_function(
  iso3 = "ESP;FRA",
  indicator = "NY.GDP.MKTP.KD.ZG",
  date = "2020:2023",
  per_page = 20000
)

write.csv(df, "worldbank_example.csv", row.names = FALSE)


