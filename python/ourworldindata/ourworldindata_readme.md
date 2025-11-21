# Guía rápida: Our World in Data (CSV) — `python/ourworldindata/worldindata_min.py`

Este documento muestra cómo importar datos directamente desde los gráficos de Our World in Data (OWID) a Python usando `pandas`.

## Requisitos
- Python
- pandas
- requests

## Descripción
OWID permite descargar los datos detrás de sus gráficos en formato CSV. El script apunta directamente a la URL de descarga de datos de un gráfico específico y guarda el archivo localmente.

## Ejemplo de uso (`worldindata_min.py`)

```python
import pandas as pd
import requests
import os

# Fetch the data.
df = pd.read_csv("https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.csv?v=1&csvType=full&useColumnShortNames=true", storage_options = {'User-Agent': 'Our World In Data data fetch/1.0'})

# Fetch the metadata
metadata = requests.get("https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.metadata.json?v=1&csvType=full&useColumnShortNames=true").json()

# Save the data to CSV
output_path = os.path.join(os.path.dirname(__file__), "labor_productivity.csv")
df.to_csv(output_path, index=False)
print(f"Data saved to {output_path}")
```

## Cómo obtener la URL
1. Vaya a un gráfico en [Our World in Data](https://ourworldindata.org/).
2. Haga clic en la pestaña "Download".
3. Copie el enlace del archivo CSV (full data).

## Cómo elegir inputs
1. Navegue por [Our World in Data](https://ourworldindata.org/) hasta encontrar el gráfico deseado.
2. Seleccione la pestaña "Download" bajo el gráfico.
3. Haga clic derecho en el botón de descarga "Full data (CSV)" y seleccione "Copiar dirección del enlace".
4. Pegue esa URL en su script de Python dentro de `pd.read_csv`.

