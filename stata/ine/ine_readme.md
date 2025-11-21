# Guía rápida: INE España (CSV) — `ine/ine_min.do`

Este documento muestra cómo cargar datos del INE (Instituto Nacional de Estadística de España) directamente en Stata.

## Requisitos
- Stata.

## Descripción
El script utiliza la funcionalidad de `import delimited` apuntando a la URL de descarga directa del archivo CSV de una tabla del INE.

## Ejemplo de uso (`ine_min.do`)

```stata
* Descarga directa de una tabla (ej. ID 67821)
import delimited "https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/67821.csv", encoding("utf-8") clear
```

## Cómo obtener la URL
1. Navegue a [INEbase](https://www.ine.es/).
2. Localice la tabla de interés.
3. Busque el botón de descarga y copie el enlace del formato CSV (o PC-Axis si usa herramientas compatibles, pero CSV es directo para `import delimited`).
4. Asegúrese de que la URL termina en `.csv` o es el enlace de descarga directa.

## Cómo elegir inputs
1) Vaya a la página de la tabla en INE y copie el identificador (número al final de la URL, p. ej. `67821`).
2) Construya la URL sustituyendo el ID en: `https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/{ID}.csv`.
3) Si la URL cambia (por ejemplo, variantes de formato), copie directamente el enlace de descarga "CSV" desde la web del INE.
