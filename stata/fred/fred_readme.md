# Guía rápida: FRED (St. Louis Fed) — `fred/fred_min.do`

Este documento explica cómo usar el comando nativo `import fred` en Stata para descargar datos de la Reserva Federal de St. Louis.

## Requisitos
- Stata 15 o superior (para el comando `import fred` nativo).
- Una API Key de FRED (gratuita).

## Configuración inicial
Antes de descargar datos, debe configurar su API Key. Puede obtener una en [fred.stlouisfed.org/api/api_key.html](https://fred.stlouisfed.org/docs/api/api_key.html).

## Ejemplo de uso (`fred_min.do`)

```stata
* Establecer la clave API (Reemplace TUAPIKEY con su clave real)
set fredkey TUAPIKEY

* Importar series (ej. GNPCA: Real Gross National Product)
import fred GNPCA, clear
```

## Notas
- Si usa una versión antigua de Stata, necesitará usar `freduse` (comando de la comunidad, `ssc install freduse`) o métodos alternativos.
- El comando `import fred` permite opciones avanzadas como rangos de fechas (`datestart()`, `dateend()`) y agregaciones.

## Cómo elegir inputs
1) Elija el `series_id` (p. ej., `GDP`, `CPIAUCSL`). Esto suele estar al lado del nombre de la serie en FRED entre paréntesis.
2) Use ese ID en el comando `import fred ID`.
3) Para conseguir una API key, hay que registrarse en FRED, entrar en la cuenta, ir a la sección "API keys" y pinchar en "Request API key".

## Enlaces útiles
- [Documentación de import fred en Stata](https://www.stata.com/manuals/dimportfred.pdf)
