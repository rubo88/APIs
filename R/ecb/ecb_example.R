# Ejemplo de uso de la función ecb_api_function
library(httr)

#setwd("ecb")
source("ecb_function.R")

# Ejemplo de uso
df <- ecb_api_function(
  dataset = "BSI",
  seriesKey = "M.U2.Y.V.M30.X.I.U2.2300.Z01.A"
)

write.csv(df, "ecb_example.csv", row.names = FALSE)


