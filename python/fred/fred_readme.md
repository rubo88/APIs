# Guía rápida: FRED (fredgraph y API v1) — `python/fred/fred_function.py`
Este módulo incluye:
- `fredgraph_api_function(graph_id)`: descarga CSV de fredgraph (no requiere API key).
- `fred_api_function(...)`: consulta la API v1 (requiere variable de entorno `FRED_API_KEY`).

## Requisitos
- Python ≥ 3.8
- Paquetes: `requests`, `pandas`

```bash
pip install requests pandas
```

## Ejemplos
```python
from fred_function import fredgraph_api_function, fred_api_function

# 1) fredgraph (CSV)
df_graph = fredgraph_api_function("1wmdD")
df_graph.to_csv("fred_graph_ejemplo.csv", index=False)

# 2) API v1 (JSON)
# export FRED_API_KEY=... antes de ejecutar
df_obs = fred_api_function(series_id="GDPC1", observation_start="2000-01-01")
df_obs.to_csv("fred_api_ejemplo.csv", index=False)
```

## Códigos ejemplo
- `fred_onlylink.py`: ejemplo que descarga y lee el csv directamente del link de la API en una linea.
- `fred_min.py`: ejemplo mínimo para descargar datos de FRED sin usar la función.
- `fred_example.py`: ejemplo de uso de la función `fred_api_function`.


## Notas
- La API v1 admite parámetros como `units`, `frequency`, `aggregation_method`, etc. con validación básica.

## Cómo elegir inputs
- Para `fredgraph_api_function`, obtenga `graph_id` desde el enlace compartido del gráfico (parámetro `?g=` en la URL).
- Para `fred_api_function`:
  1) elija `series_id` (p. ej., `GDP`).
  2) Defina `FRED_API_KEY` como variable de entorno.
  3) Cambie los otros parámetros opcionales según la sección de "Parámetros detallados" de la documentación oficial.

## Enlaces útiles
- Observations API docs: https://fred.stlouisfed.org/docs/api/fred/series_observations.html


