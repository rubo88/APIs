# Guía rápida: Eurostat COMEXT (JSON → DataFrame) — `python/comext/comext_function.py`
Este documento explica cómo usar la función en `python/comext/comext_function.py` para descargar datos desde el endpoint Eurostat COMEXT en JSON y convertirlos a un `pandas.DataFrame` etiquetado.

## Requisitos
- Python (≥ 3.8 recomendado)
- Paquetes: `requests`, `pandas`

```bash
pip install requests pandas
```

## Inputs
- **Obligatorios**
  - `dataset_id`: id del dataset Comext (p. ej., `"DS-059341"`).
  - `filters`: diccionario nombrado dimensión -> lista de valores. Para multiselección se envían parámetros repetidos.

## Output
- Un `pandas.DataFrame` con códigos por dimensión, columnas de etiquetas `*_label` y la columna numérica `value`.

## Ejemplo de uso
```python
from comext_function import comext_api_function

df = comext_api_function(
    dataset_id="DS-059341",
    filters={
        "reporter": ["ES"],
        "partner": ["US"],
        "product": ["1509"],
        "flow": ["2"],
        "freq": ["A"],
        "time": ["2015", "2016"],
    }
)

df.to_csv("comext_ejemplo.csv", index=False)
```

## Códigos ejemplo
- `comext_min.py`: ejemplo mínimo que descarga y guarda `comext_min.csv`.

## Sintaxis de la API (COMEXT)
```
https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/{dataset_id}?{dim}={val}&{dim}={val}...
```

## Notas
- Si la API devuelve error, verifique el `dataset_id` y las dimensiones en la documentación de Comext.

## Cómo elegir inputs
1) Identifique el dataset en la guía de Comext y el portal de Eurostat.
2) Consulte la estructura del dataset en la guía Comext para conocer las dimensiones válidas y sus valores.
3) Ajuste `filters` con nombres de dimensiones válidos. Para múltiples valores use listas (enviamos parámetros repetidos).

## Función auxiliar para convertir JSON a DataFrame
La función `comext_json_to_labeled_df` convierte el JSON en un DataFrame con columnas por dimensión (códigos y `*_label`) y la columna `value` (numérica cuando procede).

## Enlaces útiles
- Guía de Comext: https://ec.europa.eu/eurostat/web/user-guides/data-browser/api-data-access/api-getting-started/comext-database
- Portal Eurostat: https://ec.europa.eu/eurostat/


