# Guía rápida: Our World in Data (CSV) — `ourworldindata/worldindata_min.do`

Este documento muestra cómo importar datos directamente desde los gráficos de Our World in Data (OWID) a Stata.

## Requisitos
- Stata.

## Descripción
OWID permite descargar los datos detrás de sus gráficos en formato CSV. El script apunta directamente a la URL de descarga de datos de un gráfico específico.

## Ejemplo de uso (`worldindata_min.do`)

```stata
* Importar datos de productividad laboral
import delimited "https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.csv?v=1&csvType=full&useColumnShortNames=true", encoding("utf-8") clear
```

## Cómo obtener la URL
1. Vaya a un gráfico en [Our World in Data](https://ourworldindata.org/).
2. Haga clic en la pestaña "Download".
3. Copie el enlace del archivo CSV (full data).

## Cómo elegir inputs
1) Navegue por [Our World in Data](https://ourworldindata.org/) hasta encontrar el gráfico deseado.
2) Seleccione la pestaña "Download" bajo el gráfico.
3) Haga clic derecho en el botón de descarga "Full data (CSV)" y seleccione "Copiar dirección del enlace".
4) Pegue esa URL en su comando `import delimited "URL", clear`.

