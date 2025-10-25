# Ejemplo de uso del paquete ineapir
#install.packages("ineapir")
library(ineapir)

# Definir la tabla a descargar

## Tipo tempus

tip <- "AM"

## Funciones para las operacinoes (las bases de datos del INE)
# Obtener las bases de datos disponibles con su Cod_IOE
get_metadata_operations()

# Obtener la periodicidad de las operaciones con su id
get_metadata_periodicity()

# Obtener las publicaciones de una operación con su FK_PubFechaAct
get_metadata_publications(operation = 237)

# Obtener las variables de una operación con su id
get_metadata_variables(operation = 237)

# Obtener los valores de una variable de una operación con su id
get_metadata_values(operation = 237, variable = 3)

# Obtener las tablas de una operación con su id
get_metadata_tables_operation(operation = 237)

## Funciones para las tablas de datos del INE
idTable <- 67824

# Obtener los grupos de una tabla con su id
get_metadata_table_groups(idTable = idTable)

# Obtener los valores de una de una tabla con su id
get_metadata_table_values(idTable = idTable, idGroup = 141148)

# Obtener los metadatos de una tabla con su id
get_metadata_table_varval(idTable = idTable)

# Obtener las series de una tabla con su id
get_metadata_series_table(idTable = idTable)

# Obtener la operacion a la que pertenece una tabla con su id
get_metadata_operation_table(idTable = idTable)

## Funciones para las series de datos del INE

# Obtener los metadatos de una serie con su id
get_metadata_series(codSeries = "CNTR7300")

# Obtener los valores de una serie con su id
get_metadata_series_values(codSeries = "CNTR7300")


# Obtener las series de una operación con su id
get_metadata_series_operation(operation = 30024, det=1, tip=NULL, lang="ES", page=1, validate=TRUE, verbose=FALSE)