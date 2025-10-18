# Guía rápida: INE JAXIT3 (CSV) — `ine/ine_jaxi_function.R`
Este documento explica cómo usar la función en `ine/ine_jaxi_function.R` para descargar datos desde la API de INE JAXIT3 en formato CSV y obtenerlos como un data frame en R.

## Requisitos
- R (≥ 4.0 recomendado)
- Paquete `httr` instalado (`install.packages("httr")` si fuera necesario)

## Inputs
- **Obligatorios**
  - `tableId`: identificador de la tabla INE (p. ej., `"67821"`).

- **Opcionales**
  - `nocab`: `"1"` para evitar cabeceras adicionales.
  - `directory`: segmento de directorio (por defecto `"t"`).
  - `locale`: idioma del recurso (por defecto `"es"`).
  - `variant`: variante del CSV (por defecto `"csv_bdsc"`).

## Output
- Un `data.frame` con los datos descargados desde INE JAXIT3.


## Ejemplo de uso
```r
# 1) Cargar la función
source("ine/ine_jaxi_function.R")

# 2) Ejecutar la consulta
df <- ine_jaxi_api_function(
  tableId = "67821",
  nocab = "1"
)

str(df)
```
## Codigos ejemplo 
El código `ine_jaxi_min.R` es un ejemplo mínimo para descargar datos del INE sin usar la función `ine_jaxi_api_function`.
El código `ine_jaxi_example.R` es un ejemplo de uso de la función `ine_jaxi_api_function`.

## Cómo elegir inputs
1) Vaya a la página de la tabla en INE y copie el identificador (número al final de la URL).
2) Use ese identificador como `tableId`.
3) Ajuste parámetros opcionales (`nocab`, `locale`, `variant`, `directory`) si es necesario.
4) Si necesita cabeceras compactas para procesamiento, mantenga `nocab = "1"`.

## Sintaxis de la URL de la API (INE JAXIT3)
Formato general:
```
https://www.ine.es/jaxiT3/files/{directory}/{locale}/{variant}/{tableId}.csv?nocab={nocab}
```
Donde `base_url` es `https://www.ine.es/jaxiT3/files`.

Ejemplo equivalente:
```
https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/67821.csv?nocab=1
```

## Notas
- Si la API devuelve error, verifique que el `tableId` exista y sea accesible.

## Enlaces útiles
- INE (Banco de datos JAXIT3): https://www.ine.es/

