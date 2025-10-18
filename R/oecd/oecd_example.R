# Ejemplo de uso de la función oecd_api_function
library(httr)

#setwd("oecd")
source("oecd_function.R")

# Ejemplo de uso
df <- oecd_api_function(
  agency_identifier = "OECD.ECO.MAD",
  dataset_identifier = "DSD_EO@DF_EO",
  data_selection = "FRA+DEU.PDTY.A",
  startPeriod = "1965",
  endPeriod = "2023",
  dimensionAtObservation = "AllDimensions"
)

write.csv(df, "oecd_example.csv", row.names = FALSE)


