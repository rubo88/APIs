# Ejemplo de uso de la función imf_api_function
library(httr)
library(jsonlite)

# setwd("imf")
source("imf_function.R")

# Ejemplo de uso: IPC (PCPI_IX) mensual para España desde 2018
df <- imf_api_function(
  dataset = "IFS",
  key = "M.ES.PCPI_IX",
  startPeriod = "2018",
  endPeriod = "2023"
)

write.csv(df, "imf_example.csv", row.names = FALSE)




