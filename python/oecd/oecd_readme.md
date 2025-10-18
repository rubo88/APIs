# Guía rápida: OCDE SDMX (CSV) — `python/oecd/oecd_function.py`
Este documento explica cómo usar `python/oecd/oecd_function.py` para descargar datos SDMX de la OCDE en CSV y obtener un `pandas.DataFrame`.

## Requisitos
- Python ≥ 3.8
- Paquetes: `requests`, `pandas`

```bash
pip install requests pandas
```

## Inputs
- **Obligatorios**
  - `agency_identifier`, `dataset_identifier`, `data_selection`.

- **Opcionales**
  - `base_url`, `dataset_version`, `startPeriod`, `endPeriod`, `dimensionAtObservation`.

## Output
- Un `pandas.DataFrame` con los datos descargados.

## Ejemplo de uso
```python
from oecd_function import oecd_api_function

df = oecd_api_function(
    agency_identifier="OECD.ECO.MAD",
    dataset_identifier="DSD_EO@DF_EO",
    data_selection="FRA+DEU.PDTY.A",
    startPeriod="1965",
    endPeriod="2023",
    dimensionAtObservation="AllDimensions",
)
df.to_csv("oecd_ejemplo.csv", index=False)
```

## Códigos ejemplo 
- `oecd_min.py` es un ejemplo mínimo para descargar datos de la OCDE sin usar la función `oecd_api_function`.
- `oecd_example.py` es un ejemplo de uso de la función `oecd_api_function`.

## Cómo elegir inputs
1) Buscar el dataset en el explorador OCDE: https://data-explorer.oecd.org/
2) Seleccionar las dimensiones y consultar la sección "Developer API" para obtener `Agency identifier`, `Dataset identifier` y `Dataset version`.
3) Construir `data_selection` con las dimensiones requeridas por el dataset (p. ej., `PAISES.VARIABLE.FRECUENCIA`).
4) Ajustar parámetros opcionales (`startPeriod`, `endPeriod`, `dimensionAtObservation`).

## Sintaxis de la URL de la API (OCDE)
Formato general:
```
{Host URL}/{Agency identifier},{Dataset identifier},{Dataset version}/{Data selection}?{otros parámetros}
```
Donde `base_url` por defecto es `https://sdmx.oecd.org/public/rest/data`.

Ejemplo equivalente:
```
https://sdmx.oecd.org/public/rest/data/OECD.ECO.MAD,DSD_EO@DF_EO, /FRA+DEU.PDTY.A?startPeriod=1965&endPeriod=2023&dimensionAtObservation=AllDimensions
```

## Notas
- Si la API devuelve error, verifique que `agency_identifier`, `dataset_identifier` y `data_selection` sean válidos.
- Revise la documentación del dataset para conocer las dimensiones y códigos disponibles.

## Enlaces útiles
- Explorador OCDE: https://data-explorer.oecd.org/
- Documentación de la API: https://www.oecd.org/en/data/insights/data-explainers/2024/09/api.html

