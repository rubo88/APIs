# Ejemplo de uso del paquete ineapir
#install.packages("ineapir")
library(ineapir)

# Definir la tabla a descargar
## Tipo tempus
tableId <- 67824

########################################################
# Definir parametros generales
########################################################
## Unnest: TRUE para desanidar el dataframe, se recomienda TRUE para evitar errores
unnest <- TRUE

## Validate: FALSE para evitar validaciones, Por defecto es TRUE, pero se puede poner FALSE para reducir las llamadas a la API
validate <- FALSE

## Tip: 
### =NULL sin fechas legibles ni metadados
### "A" Fechas en formato YYYY/MM/DD sin metadatos
### "M" Metadados como columna en el dataframe
### "AM" Fechas en formato YYYY/MM/DD con metadatos en el dataframe

tip <- "A"

## Extrae metadatos y lo añade como columna para cada variable. Se recomienda TRUE. TIP tiene que ser "AM" o "M" para poder ser TRUE
metanames <- FALSE
metacodes <- FALSE

## Lenguaje
lang= "ES" # "ES" para español, "EN" para inglés

########################################################
# Definir los filtros
########################################################
# Obtener los grupos de una tabla con su id
get_metadata_table_groups(idTable = idTable)

# Obtener los valores de una de una tabla con su id
get_metadata_table_values(idTable = idTable, idGroup = 141147)
get_metadata_table_values(idTable = idTable, idGroup = 141148)
get_metadata_table_values(idTable = idTable, idGroup = 141149)

# En base a las listas de los compandos anteriores elegimos los filtros que nos interesan 

filter <- list(`544`="283877",`482`="17134", `480`=c("141","17132"), `3`="72" )

########################################################
# Definir fechas
########################################################
dateStart <- "2019/01/01"
dateEnd <- "2026/01/01"

########################################################
# Descargar los datos y guardarlos en un archivo CSV
########################################################

df <- get_data_table(idTable = tableId, unnest = unnest, validate = validate, tip = tip, metanames = metanames, metacodes = metacodes, lang = lang, filter = filter, dateStart = dateStart, dateEnd = dateEnd)

write.csv(df, "ineapir_example.csv", row.names = FALSE)




