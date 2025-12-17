## Cómo descargar datos con APIs (introducción no técnica)

Este repositorio reúne scripts listos para usar que descargan datos económicos de fuentes públicas. El objetivo de este documento es explicar, en términos sencillos, qué es una API, por qué nos interesa usarla y cómo empezar en 10 minutos con los ejemplos incluidos para Python, R, MATLAB y Stata.

La versión más reciente de este repositorio está disponible en [https://github.com/rubo88/APIs](https://github.com/rubo88/APIs).
## ¿Qué es una API y por qué usarla?

- **API**: una forma estándar de pedir datos a un servidor, como si fuera una “ventanilla” automatizada. En lugar de descargar manualmente ficheros desde una web, un script hace la petición y recibe una base de datos completa o una parte de ella filtrada.
- **Ventajas**:
  - **Ahorro de tiempo**: automatiza tareas repetitivas y evita copiar/pegar.
  - **Ahorro de espacio**: solo descargas las partes de la base de datos que te interesan.
  - **Integración**: la obtención y actualización de datos queda integrada en tu proceso de trabajo.
  - **Actualización**: siempre trae la versión más reciente disponible.
  - **Trazabilidad**: el proceso queda documentado en el script; facilita auditoría y repetición.

## Requisitos previos
- Si utilizas tu **ordenador personal** o el **Portal del Investigador**, puedes empezar ya mismo a usar APIs con los ejemplos que tienes aquí.
- Si quieres usarlos en el **ordenador corporativo**, necesitas primero que te instalen **ProxyCap**. 

## ¿Qué incluye este repositorio?
Ejemplos sencillos de uso para cuatro lenguajes de programación: Python, R, MATLAB y Stata. Para varias fuentes. En cada lenguaje/fuente hay varios ejemplos de código según el nivel de uso que quieras hacer.

### Estructura por lenguaje
  - `python/`, `R/`, `matlab/`, `stata/` contienen subcarpetas por fuente (p. ej. `oecd/`, `eurostat/`, `fred/`).
  - En cada subcarpeta hay:
    - Un script que descarga y lee el csv directamente del **link de la API en una línea** (p. ej. `ecb_onlylink.*`). **Lo más sencillo** para empezar si no necesitas filtrar los datos.
    - Un script de **función principal** (p. ej. `ecb_function.*`). Si quieres tener **un código más limpio** y modular, llama a la función principal.
    - Un **ejemplo que hace uso de la función principal** (p. ej. `ecb_example.*`). Si quieres ver un ejemplo de uso de la **función principal**.
    - Un **ejemplo “mínimo” autocontenido** (sin llamar a la función principal) (`ecb_min.*`). Si quieres ver un ejemplo de uso con filtros y sin modular el código. Esto es **lo menos recomendable**.
    - Ficheros CSV de muestra descargados (`ecb_example.csv`, `ecb_min.csv`).

- **Documentación específica**: cada subcarpeta tiene su propio `ecb_readme.md` con detalles (parámetros, enlaces oficiales, ejemplos).

### Fuentes incluidas
- Las fuentes incluidas en este repositorio y que se pueden usar desde el ordenador corporativo son:
    - **Banco Central Europeo (ECB)**
    - **FRED (Federal Reserve Bank of St. Louis)**
    - **OCDE (OECD)**
    - **Eurostat**
    - **INE**
    - **World Bank**
    - **COMEXT (Eurostat Comercio Exterior)**
    - **ESIOS (Red Eléctrica de España)**
    - **IMF (Fondo Monetario Internacional)**
    - **Our World in Data**



## Cómo empezar en 5 minutos

1) **Elige lenguaje**: abre la carpeta de tu preferencia (`python/`, `R/`, `matlab/` o `stata/`).

2) **Elige fuente**: entra en la subcarpeta (p. ej. `python/oecd/`, `R/eurostat/`).

3) **Lee la documentación específica**: echa un vistazo al `*_readme.md` de la fuente para ver los parámetros y ejemplos.

4) **Elige el ejemplo**: en cada fuente hay varios ejemplos de código según el nivel de uso que quieras hacer. Lo más sencillo es el ejemplo `*_onlylink` que descarga y lee el csv directamente del link de la API en unas pocas lineas. Para integrar en un proyecto, lo mejor es usar el ejemplo `*_function` que te permite usar la función principal para descargar los datos con opciones de filtros y otros parámetros.

5) **Ejecuta el ejemplo**: los ejemplos generan un CSV en la misma carpeta. Así te aseguras de que todo  está funcionando correctamente.

6) **Adapta el ejemplo**: cambia identificadores de series, países, fechas u otros filtros buscando en la web de la fuente o preguntando al Agente Copilot.

7) **Intégralo en tu propio proyecto**


> **Claves de API (si aplica)**: Algunas fuentes pueden requerir una clave de acceso. Consulta el `*_readme.md` de esa fuente para obtenerla y configurarla (normalmente como variable de entorno) antes de ejecutar el ejemplo. 

## Preguntas frecuentes (FAQ)

- **No uso ninguno de estos lenguajes, ¿hay algo para usar las APIs directamente en Excel?** Sí, puedes descargar series directamente a tu fichero Excel usando Power Query. Estamos creando ejemplos y una documentación separada para hacerlo. 
- **La fuente que me interesa no está en el repositorio, ¿tiene API?** Depende, consulta en las webs de las fuentes para ver si tienen API y si es así, pide ayuda al Agente Copilot Ayudante de APIs o en el foro de Teams para poder usarla. Desgraciadamente, muchas fuentes (muchos ministerios, Datacomex, etc) no disponen de API. En ese caso, una automatización con python puede ser una opción.


---
