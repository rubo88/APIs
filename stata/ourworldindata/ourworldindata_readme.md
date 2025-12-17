# Guía rápida: Our World in Data con Stata

Este documento muestra cómo importar datos directamente desde los gráficos de Our World in Data (OWID) a Stata.

## Requisitos
- Stata

## Codigos ejemplo
- `worldindata_min.do` es un ejemplo mínimo para descargar datos de OWID directamente en Stata.

## Inputs
- **Obligatorios**
  - `url`: URL directa del archivo CSV proporcionada por OWID para un gráfico específico.

## Cómo elegir inputs
1) Vaya a un gráfico en [Our World in Data](https://ourworldindata.org/).
2) Haga clic en la pestaña "Download".
3) Haga clic derecho en el botón de descarga "Full data (CSV)" y seleccione "Copiar dirección del enlace".
4) Pegue esa URL en su comando `import delimited "URL", clear`.

## Sintaxis de la API
- **Formato general:**
  ```
  https://ourworldindata.org/grapher/{chart-slug}.csv?v=1&csvType=full&useColumnShortNames=true
  ```

- **Ejemplo:**
  ```
  https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.csv?v=1&csvType=full&useColumnShortNames=true
  ```

## Output
- Un dataset en memoria de Stata con los datos descargados.

## Enlaces útiles
- Portal: https://ourworldindata.org/
