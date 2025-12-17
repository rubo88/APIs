# Guía rápida: FRED con Stata

Este documento explica cómo usar el comando nativo `import fred` en Stata para descargar datos de la Reserva Federal de St. Louis.

## Requisitos
- Stata 15 o superior (para el comando `import fred` nativo).
- Una API Key de FRED (gratuita).

## Codigos ejemplo
- `fred_min.do` es un ejemplo mínimo para descargar datos de FRED usando `import fred`.

## Inputs
- **Obligatorios**
  - `series_id`: identificador de la serie (p. ej., `"GNPCA"`).
  - `api_key`: clave API personal de FRED.

## Cómo elegir inputs
1) Elija el `series_id` (p. ej., `GDP`, `CPIAUCSL`). Esto suele estar al lado del nombre de la serie en FRED entre paréntesis.
2) Use ese ID en el comando `import fred ID`.
3) Para conseguir una API key, hay que registrarse en FRED, entrar en la cuenta, ir a la sección "API keys" y pinchar en "Request API key".

## Sintaxis de la API
- Uso del comando nativo de Stata `import fred`.
  ```stata
  set fredkey TUAPIKEY
  import fred SERIES_ID, clear
  ```

## Output
- Un dataset en memoria de Stata con los datos descargados.

## Enlaces útiles
- Referencia oficial: [FRED observations API docs](https://fred.stlouisfed.org/docs/api/fred/series_observations.html)
- [Documentación de import fred en Stata](https://www.stata.com/manuals/dimportfred.pdf)
