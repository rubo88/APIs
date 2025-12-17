# Guía rápida: INE JAXIT3 con Python

Este documento explica cómo usar la función en `python/ine/ine_jaxi_function.py` para descargar datos desde la API de INE JAXIT3 en formato CSV y obtenerlos como un `pandas.DataFrame` en Python.

## Requisitos
- Paquetes: `requests`, `pandas`

## Codigos ejemplo
- `ine_jaxi_onlylink.py` es un ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `ine_jaxi_min.py` es un ejemplo mínimo que descarga y guarda `ine_jaxi_min.csv`.
- `ine_jaxi_example.py` es un ejemplo de uso de la función `ine_jaxi_api_function`.

## Inputs
- **Obligatorios**
  - `table_id`: identificador de la tabla INE (p. ej., `"67821"`).

- **Opcionales**
  - `nocab`: `"1"` para evitar cabeceras adicionales (opcional).
  - `directory`: segmento de directorio (por defecto `"t"`).
  - `locale`: idioma del recurso (por defecto `"es"`).
  - `variant`: variante del CSV (por defecto `"csv_bdsc"`).

## Cómo elegir inputs
1) Vaya a la página de la tabla en INE y copie el identificador (número al final de la URL).
2) Use ese identificador como `table_id`.
3) Ajuste parámetros opcionales (`nocab`, `locale`, `variant`, `directory`) si es necesario.
4) Si necesita cabeceras compactas para procesamiento, mantenga `nocab = "1"`.

## Sintaxis de la API (INE JAXIT3)
- **Formato general:**
  ```
  https://www.ine.es/jaxiT3/files/{directory}/{locale}/{variant}/{tableId}.csv?nocab={nocab}
  ```
  Donde el Host URL es `https://www.ine.es/jaxiT3/files`.

- **Ejemplo:**
  ```
  https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/67821.csv?nocab=1
  ```

## Output
- Un `pandas.DataFrame` con los datos descargados desde INE JAXIT3.

## Notas
- Si la API devuelve error, verifique que el `table_id` exista y sea accesible.
- El CSV se parsea con `pandas.read_csv(..., sep=';', dtype=str)` (todas las columnas como texto).

## Enlaces útiles
- INE (Banco de datos JAXIT3): https://www.ine.es/
