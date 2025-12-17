# Guía rápida: INE con Stata

Este documento muestra cómo cargar datos del INE (Instituto Nacional de Estadística de España) directamente en Stata.

## Requisitos
- Stata

## Codigos ejemplo
- `ine_min.do` es un ejemplo mínimo para descargar datos del INE directamente en Stata.

## Inputs
- **Obligatorios**
  - `url`: URL directa del archivo CSV de la tabla del INE.

## Cómo elegir inputs
1) Navegue a [INEbase](https://www.ine.es/).
2) Localice la tabla de interés.
3) Busque el botón de descarga y copie el enlace del formato CSV.
4) Asegúrese de que la URL termina en `.csv` o es el enlace de descarga directa.

## Sintaxis de la API (INE)
- **Formato general:**
  ```
  https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/{TABLE_ID}.csv
  ```

- **Ejemplo:**
  ```
  https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/67821.csv
  ```

## Output
- Un dataset en memoria de Stata con los datos descargados.

## Enlaces útiles
- INE (Banco de datos): https://www.ine.es/
