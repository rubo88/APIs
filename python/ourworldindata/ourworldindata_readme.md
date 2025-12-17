# Guía rápida: Our World in Data con Python

Este documento muestra cómo importar datos directamente desde los gráficos de Our World in Data (OWID) a Python usando `pandas`.

## Requisitos
- Paquetes: `pandas`, `requests`

## Codigos ejemplo
- `worldindata_onlylink.py` es un ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `worldindata_min.py` es un ejemplo mínimo para descargar datos de OWID.

## Inputs
- **Obligatorios**
  - `url`: URL directa del archivo CSV proporcionada por OWID para un gráfico específico.

## Cómo elegir inputs
1) Vaya a un gráfico en [Our World in Data](https://ourworldindata.org/).
2) Haga clic en la pestaña "Download".
3) Haga clic derecho en el botón de descarga "Full data (CSV)" y seleccione "Copiar dirección del enlace".
4) Use esa URL en su script de Python.

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
- Un `pandas.DataFrame` con los datos descargados desde OWID.

## Enlaces útiles
- Portal: https://ourworldindata.org/
