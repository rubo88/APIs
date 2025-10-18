# Guía rápida: Banco Mundial (JSON → DataFrame) — `python/worldbank/worldbank_function.py`
Este documento explica cómo usar `python/worldbank/worldbank_function.py` para consultar indicadores del Banco Mundial y obtener un `pandas.DataFrame`.

## Requisitos
- Python ≥ 3.8
- Paquetes: `requests`, `pandas`

```bash
pip install requests pandas
```

## Inputs
- **Obligatorios**
  - `iso3`: código(s) de país ISO-3, separados por ';' si son múltiples.
  - `indicator`: código(s) de indicador, separados por ';' si son múltiples.

- **Opcionales**
  - `date`: rango temporal, p. ej., `"2020:2023"`.
  - `per_page`: tamaño de página (alto para evitar paginación).
  - `base_url`: host de la API.

## Output
- Un `pandas.DataFrame` con el array de datos `[1]` de la respuesta JSON.

## Ejemplo de uso
```python
from worldbank_function import worldbank_api_function

df = worldbank_api_function(
    iso3="ESP",
    indicator="NY.GDP.MKTP.KD.ZG",
    date="2000:2023",
)
df.to_csv("worldbank_ejemplo.csv", index=False)
```

## Códigos ejemplo 
- `worldbank_min.py` es un ejemplo mínimo para descargar datos del Banco Mundial sin usar la función `worldbank_api_function`.
- `worldbank_example.py` es un ejemplo de uso de la función `worldbank_api_function`.

## Cómo elegir inputs
1) Elija país(es) `iso3` (estándar ISO 3166-1 alpha-3). Puede listar países: https://api.worldbank.org/v2/country?format=json

2) Elegir indicador (`indicator`)
   - Buscar en la web del World Bank la serie de interés. Seleccionar las variables y pinchar en `Metadata` -> `Series`. Copiar el código de la serie. Puede ser una lista de indicadores separados por `;`.
   - Busque indicadores en: https://api.worldbank.org/v2/indicator?format=json (listado paginado) o en el portal de datos del Banco Mundial.
   - También puede abrir un indicador concreto para ver su nombre/meta: https://api.worldbank.org/v2/indicator/NY.GDP.MKTP.KD.ZG?format=json.

3) Rango temporal 
   - La API soporta `date=YYYY:YYYY` para filtrar. 
   - Si por ejemplo es mensual, sería `date=2012M01:2012M08`

## Sintaxis de la URL de la API (World Bank)
Formato general:
```
https://api.worldbank.org/v2/country/{ISO3}/indicator/{INDICATOR}?format=json&per_page={N}&date={DATE}
```

Ejemplo equivalente:
```
https://api.worldbank.org/v2/country/ESP;FRA/indicator/NY.GDP.MKTP.KD.ZG?format=json&per_page=20000&date=2020:2023
```

## Enlaces útiles
- Indicadores (API): https://datahelpdesk.worldbank.org/knowledgebase/articles/889392-about-the-indicators-api-documentation
- Estructura de llamadas: https://datahelpdesk.worldbank.org/knowledgebase/articles/898581-api-basic-call-structures
- Países (JSON): https://api.worldbank.org/v2/country?format=json
- Indicadores (JSON): https://api.worldbank.org/v2/indicator?format=json

