# Guía rápida: INE (API) con el paquete `ineapir`
Esta guía muestra un ejemplo mínimo y funcional, basado en `ineapir_example.R`, para descargar datos desde una tabla de INE usando el paquete `ineapir`.

## Requisitos
- R (≥ 4.0 recomendado)
- Paquete `ineapir` y `remotes` instalados:

```r
install.packages("ineapir")
install.packages("remotes")
```

## Parámetros principales
- **tableId** (obligatorio): identificador numérico de la tabla INE (p. ej., `67824`).
- **unnest** (opcional, por defecto `TRUE` recomendado): desanida el `data.frame` resultante.
- **validate** (opcional, por defecto `TRUE`): si `FALSE`, reduce validaciones y llamadas extra a la API.
- **tip** (opcional): controla fechas y metadatos en salida.
  - `NULL`: sin fechas legibles ni metadatos
  - `"A"`: añade fechas legibles (YYYY/MM/DD)
  - `"M"`: añade metadatos como columnas
  - `"AM"`: fechas legibles y metadatos en columnas
- **metanames / metacodes** (opcional): añade nombres/códigos de metadatos como columnas. Requiere `tip` en `"M"` o `"AM"`.
- **lang** (opcional): idioma (`"ES"` o `"EN"`).
- **filter** (opcional): lista con filtros por id de dimensión y valores permitidos.
- **dateStart / dateEnd** (opcional): rango de fechas en formato `YYYY/MM/DD`.

## Flujo recomendado
1. Buscar la tabla que nos interese en INE. El id de la tabla es el número al final de la URL
2. Definir `tableId` de la tabla que desea descargar.
3. Para saber que filtros queremos aplicar, explorar metadatos para conocer grupos (eg. Tipo de dato, Agregados macroeconómicos, Niveles y tasas) 
   - `get_metadata_table_groups(idTable = tableId)`

y sus valores disponibles (eg: Tipo de dato: Ajustado de estacionalidad o no; Agregados macroeconómicos: PIB, FBCF, etc.; Niveles y tasas:  Dato base, Variación trimestral, Variación anual, etc.).

  - `get_metadata_table_values(idTable = tableId, idGroup = <id del grupo>)` para cada grupo de la tabla.
4. Construir el `filter` con los ids de dimensión y sus valores. Ver ejemplo.
5. Llamar a `get_data_table(...)` con los parámetros deseados.
6. Guardar a CSV si se requiere (opcional).

## Ejemplo completo
```r
# Ejemplo de uso del paquete ineapir
# install.packages("ineapir")
library(ineapir)

# 1) Tabla a descargar
tableId <- 67824

# 2) Parámetros generales
unnest <- TRUE           # Recomendado para evitar estructuras anidadas
validate <- FALSE        # Reduce validaciones/llamadas extra
tip <- "A"              # Fechas legibles, sin metadatos en columnas
metanames <- FALSE
metacodes <- FALSE
lang <- "ES"            # "ES" o "EN"

# 3) Explorar metadatos (ajuste los idGroup según la tabla)
#a) Obtener los grupos de una tabla con su id
get_metadata_table_groups(idTable = tableId)
#b) Obtener los valores de cada una de las variables de interes con su id
get_metadata_table_values(idTable = tableId, idGroup = 141147)
get_metadata_table_values(idTable = tableId, idGroup = 141148)
get_metadata_table_values(idTable = tableId, idGroup = 141149)

# 4) Definir filtros en base a los metadatos explorados
filter <- list(`544` = "283877", `482` = "17134", `480` = c("141", "17132"), `3` = "72")

# 5) Definir fechas (opcional)
dateStart <- "2019/01/01"
dateEnd   <- "2026/01/01"

# 6) Descargar los datos
df <- get_data_table(
  idTable   = tableId,
  unnest    = unnest,
  validate  = validate,
  tip       = tip,
  metanames = metanames,
  metacodes = metacodes,
  lang      = lang,
  filter    = filter,
  dateStart = dateStart,
  dateEnd   = dateEnd
)

# 7) Guardar a CSV
write.csv(df, "ineapir_example.csv", row.names = FALSE)
```

## Notas y consejos
- Si necesita columnas de metadatos en el `data.frame`, utilice `tip = "AM"` o `tip = "M"`, y active `metanames`/`metacodes` según convenga.
- `validate = FALSE` puede acelerar las pruebas iniciales; para entornos productivos valore mantenerlo en `TRUE`.
- Los `idGroup` y los ids dentro de `filter` dependen de cada tabla; obténgalos con las funciones de metadatos mostradas arriba.

## Enlaces útiles
- INE: https://www.ine.es/
- Documentación API INE: https://www.ine.es/dyngs/DAB/en/index.htm?cid=1099
- Repositorio de ineapir: https://github.com/es-ine/ineapir
