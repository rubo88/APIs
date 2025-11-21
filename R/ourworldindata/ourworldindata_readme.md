# Guía rápida: Our World in Data (CSV) — `R/ourworldindata/worldindata_min.R`

Este documento muestra cómo importar datos directamente desde los gráficos de Our World in Data (OWID) a R.

## Requisitos
- R
- jsonlite (opcional, para metadatos)

## Descripción
OWID permite descargar los datos detrás de sus gráficos en formato CSV. El script apunta directamente a la URL de descarga de datos de un gráfico específico y guarda el archivo localmente.

## Ejemplo de uso (`worldindata_min.R`)

```r
library(jsonlite)

# Fetch the data
df <- read.csv("https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.csv?v=1&csvType=full&useColumnShortNames=true")

# Fetch the metadata
metadata <- fromJSON("https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.metadata.json?v=1&csvType=full&useColumnShortNames=true")

# Save the data to CSV
output_path <- "labor_productivity.csv"
write.csv(df, output_path, row.names = FALSE)
print(paste("Data saved to", output_path))
```

## Cómo obtener la URL
1. Vaya a un gráfico en [Our World in Data](https://ourworldindata.org/).
2. Haga clic en la pestaña "Download".
3. Copie el enlace del archivo CSV (full data).

## Cómo elegir inputs
1. Navegue por [Our World in Data](https://ourworldindata.org/) hasta encontrar el gráfico deseado.
2. Seleccione la pestaña "Download" bajo el gráfico.
3. Haga clic derecho en el botón de descarga "Full data (CSV)" y seleccione "Copiar dirección del enlace".
4. Pegue esa URL en su script de R dentro de `read.csv`.

