# Guía rápida: BCE (ECB Data API, CSV) — `python/ecb/ecb_function.py`
Este documento explica cómo usar `python/ecb/ecb_function.py` para descargar series del BCE en formato CSV y obtener un `pandas.DataFrame`.

## Requisitos
- Python ≥ 3.8
- Paquetes: `requests`, `pandas`

```bash
pip install requests pandas
```

## Inputs
- **Obligatorios**
  - `dataset`: identificador del dataset (p. ej., `"BSI"`).
  - `series_key`: clave completa de la serie (dimensiones separadas por `.`).

- **Opcionales**
  - `base_url`: host de la API (por defecto `https://data-api.ecb.europa.eu/service/data`).

## Output
- Un `pandas.DataFrame` con los datos descargados.

## Ejemplo de uso
```python
from ecb_function import ecb_api_function

df = ecb_api_function(
    dataset="BSI",
    series_key="M.U2.Y.V.M30.X.I.U2.2300.Z01.A",
)

df.to_csv("ecb_ejemplo.csv", index=False)
```

## Notas
- El parámetro `format=csvdata` se añade automáticamente.

## Cómo elegir inputs
1) Abra el dataset en el portal BCE (p. ej., BSI): https://data.ecb.europa.eu/data/datasets/BSI
2) Use los filtros hasta ver la serie concreta; la clave `series_key` aparece en el recuadro de la serie.
3) Cada elemento de `series_key` es una dimensión del dataset; puede cambiar `U2` (Área del euro) por `ES` (España), etc. Pinchando en `view all` se pueden ver todas las dimensiones del dataset y sus códigos. Para conocer qué valores puede tomar una dimensión, vea un dataset concreto con `.../structure`.

## Sintaxis de la URL de la API (BCE)
Formato general:
```
https://data-api.ecb.europa.eu/service/data/{dataset}/{seriesKey}?format=csvdata
```

Ejemplo equivalente:
```
https://data-api.ecb.europa.eu/service/data/BSI/M.U2.Y.V.M30.X.I.U2.2300.Z01.A?format=csvdata
```

## Enlaces útiles
- Portal de datos del BCE (datasets): https://data.ecb.europa.eu/data/datasets/
- Documentación de la API de datos del BCE: https://data.ecb.europa.eu/help/api/overview
- API de datos (servicio): https://data-api.ecb.europa.eu/service/


