# Guía rápida: INE JAXIT3 (CSV) — `matlab/ine/ine_jaxi_function.m`
Este documento explica cómo usar la función en `matlab/ine/ine_jaxi_function.m` para descargar datos desde la API de INE JAXIT3 en formato CSV y obtenerlos como una tabla de MATLAB.

## Requisitos
- MATLAB (R2019b o superior recomendado)

## Inputs
- **Obligatorios**
  - `tableId`: identificador de la tabla INE (p. ej., `"67821"`).

- **Opcionales**
  - `nocab`: `"1"` para evitar cabeceras adicionales (por defecto `"1"`).
  - `directory`: segmento de directorio (por defecto `"t"`).
  - `locale`: idioma del recurso (por defecto `"es"`).
  - `variant`: variante del CSV (por defecto `"csv_bdsc"`).

## Output
- Una `table` de MATLAB con los datos descargados desde INE JAXIT3.

## Ejemplo de uso
```matlab
% 1) Añadir ruta si es necesario
addpath('matlab');

% 2) Ejecutar la consulta
T = ine_jaxi_function('67821', '1');

% 3) (Opcional) Exportar a CSV con separador ';'
writetable(T, 'matlab/ine/ine_jaxi_example.csv', 'Delimiter', ';', 'FileType', 'text');
```

## Códigos ejemplo 
- `ine_jaxi_min.m`: ejemplo mínimo para descargar datos del INE y guardarlos en CSV directamente.
- `ine_jaxi_example.m`: ejemplo de uso de la función `ine_jaxi_function` devolviendo una tabla y exportándola a CSV.

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
- La función lee directamente la URL con `readtable` usando `Delimiter = ';'`.
- Si la API devuelve error, verifique que el `tableId` exista y sea accesible.

## Enlaces útiles
- INE (Banco de datos JAXIT3): `https://www.ine.es/`


