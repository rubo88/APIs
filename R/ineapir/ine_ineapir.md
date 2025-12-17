# Guía rápida: INE (ineapir) con R

Esta guía muestra un ejemplo mínimo y funcional, basado en `ineapir_example.R`, para descargar datos desde una tabla de INE usando el paquete `ineapir`.

## Requisitos
- Paquete `ineapir` y `remotes` instalados

## Codigos ejemplo
- `ineapir_example.R` (ejemplo completo de uso del paquete).

## Inputs
- **Obligatorios**
  - `tableId`: identificador numérico de la tabla INE (p. ej., `67824`).

- **Opcionales**
  - `unnest` (por defecto `TRUE` recomendado): desanida el `data.frame` resultante.
  - `validate` (por defecto `TRUE`): si `FALSE`, reduce validaciones y llamadas extra a la API.
  - `tip`: controla fechas y metadatos en salida (`"A"`, `"M"`, `"AM"`).
  - `metanames / metacodes`: añade nombres/códigos de metadatos como columnas.
  - `lang`: idioma (`"ES"` o `"EN"`).
  - `filter`: lista con filtros por id de dimensión y valores permitidos.
  - `dateStart / dateEnd`: rango de fechas en formato `YYYY/MM/DD`.

## Cómo elegir inputs
1) Buscar la tabla que nos interese en INE. El id de la tabla es el número al final de la URL.
2) Definir `tableId` de la tabla que desea descargar.
3) Para saber que filtros queremos aplicar, explorar metadatos para conocer grupos y valores disponibles (ver sección de uso del paquete o explorar con `get_metadata_table_groups`).
4) Construir el `filter` con los ids de dimensión y sus valores.

## Sintaxis de la API
- Uso del paquete `ineapir`. Ver funciones: `get_data_table`, `get_metadata_table_groups`, `get_metadata_table_values`.

## Output
- Un `data.frame` con los datos de la tabla INE.

## Notas
- Si necesita columnas de metadatos en el `data.frame`, utilice `tip = "AM"` o `tip = "M"`, y active `metanames`/`metacodes` según convenga.
- `validate = FALSE` puede acelerar las pruebas iniciales.

## Enlaces útiles
- INE: https://www.ine.es/
- Documentación API INE: https://www.ine.es/dyngs/DAB/en/index.htm?cid=1099
- Repositorio de ineapir: https://github.com/es-ine/ineapir
