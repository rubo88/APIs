# Guía rápida: FMI SDMX (CSV) — `imf/imf_min.do`

Este documento explica cómo usar el script `imf/imf_min.do` para descargar datos del FMI (servicio SDMX 3.0) directamente en Stata.

## Requisitos
- Stata (con capacidad de conexión a internet y comando `import delimited`).
- Conexión a internet activa.

## Descripción
El script utiliza una URL de la API SDMX 3.0 del FMI. Aunque la API soporta varios formatos, Stata puede importar directamente si la respuesta es interpretable como texto delimitado o si se construye la URL correcta.

Nota: En el ejemplo mínimo se usa una consulta directa. Para consultas más complejas, verifique la documentación de la API del FMI.

## Ejemplo de uso (`imf_min.do`)

```stata
* Descarga directa de datos (Ejemplo: PIB trimestral de España y Francia)
import delimited "https://api.imf.org/external/sdmx/3.0/data/dataflow/IMF.STA/QNEA/%2B/ESP%2BFRA.B1GQ.Q.SA.XDC.Q", clear
```

## Personalización
Para descargar otros datos, modifique la URL siguiendo la estructura de la API SDMX del FMI:
`https://api.imf.org/external/sdmx/3.0/data/dataflow/{AgencyID}/{FlowID}/{Version}/{Key}`

## Cómo elegir inputs
1) Localice el dataset y el indicador en el portal del FMI o en la documentación de SDMX.
2) Construya la `Key` con las dimensiones requeridas por el dataset. En IFS suele ser `Frecuencia.País.Indicador` (p. ej., `M.ES.PCPI_IX`).
3) La estructura de la URL es `.../data/dataflow/{AgencyID}/{FlowID}/{Version}/{Key}`.
   - `AgencyID`: Identificador de la agencia (ej. `IMF.STA`).
   - `FlowID`: Identificador del flujo de datos (ej. `QNEA`, `IFS`).
   - `Version`: Versión del flujo (o `+` para la última).
   - `Key`: Clave SDMX construida.

## Enlaces útiles
- [FMI Data Services Knowledge Base](https://datahelp.imf.org/knowledgebase/articles/1966093-how-to-use-the-api)
