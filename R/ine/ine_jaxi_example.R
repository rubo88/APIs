# Ejemplo de uso de la función ine_jaxi_api_function
library(httr)

#setwd("ine")
source("ine_jaxi_function.R")

# Ejemplo de uso
df <- ine_jaxi_api_function(
  tableId = "67821",
  nocab = "1"
)

write.csv(df, "ine_jaxi_example.csv", row.names = FALSE)


