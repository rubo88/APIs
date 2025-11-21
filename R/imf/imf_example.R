# Ejemplo de uso de la función imf_sdmx3_api_function
# Cómo personalizar:
# - Cambiar agency_identifier, dataset_identifier y dataset_version para seleccionar el dataset.
# - Cambiar data_selection para seleccionar las dimensiones del dataset. Buscar los datos en la web de IMF. Pinchar en ver el id de los valores y remplazar en el orden que aparecen las variables.
# - Cambiar filter_date para seleccionar las fechas del dataset.
# - Cambiar params para seleccionar los parámetros de la consulta.
# - Cambiar output_name para definir el nombre del archivo de salida.

setwd("R/imf")
library(httr)

# Asegurar ruta correcta al ejecutar desde la raíz del repo
source("imf_function.R")

# Ejemplo: PIB trimestral SA, precios corrientes (XDC) para España y Francia desde 2020-Q1 a 2020-Q4
df <- imf_api_function(
  dataset_identifier = "QNEA",
  data_selection = "ESP+FRA.B1GQ.Q.SA.XDC.Q",
  filters = list(
    TIME_PERIOD = c("ge:2020-Q1", "le:2020-Q4")
  )
)

utils::write.csv(df, "imf_example.csv", row.names = FALSE)


