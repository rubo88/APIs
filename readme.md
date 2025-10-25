## Cómo descargar datos con APIs (introducción no técnica)

Este repositorio reúne scripts listos para usar que descargan datos económicos de fuentes públicas. El objetivo de este documento es explicar, en términos sencillos, qué es una API, por qué nos interesa usarla y cómo empezar en 10 minutos con los ejemplos incluidos para Python, R y MATLAB.

## ¿Qué es una API y por qué usarla?

- **API**: una forma estándar de pedir datos a un servidor, como si fuera una “ventanilla” automatizada. En lugar de descargar manualmente ficheros desde una web, un script hace la petición y recibe una base de datos completa o una parte de ella filtrada.
- **Ventajas**:
  - **Ahorro de tiempo**: automatiza tareas repetitivas y evita copiar/pegar.
  - **Integración**: la obtención y actualización de datos queda integrada en tu proceso de trabajo.
  - **Actualización**: siempre trae la versión más reciente disponible.
  - **Trazabilidad**: el proceso queda documentado en el script; facilita auditoría y repetición.

## Requisitos previos
- Si utilizas tu **ordenador personal** o el **Portal del Investigador**, puedes empezar ya mismo a usar APIs con los ejemplos que tienes aquí.
- Si quieres usarlos en el **ordenador corporativo**:

  1) Necesitas primero que te instalen **ProxyCap**. Rellena el pdf XXXX y abre una Peticion de Trabajo adjuntando el pdf.
  2) Una vez instalado, tienes que activar ProxyCap. Para ello vete a ....
  3) Recuerda apagar ProxyCap cuando no lo uses.

## ¿Qué incluye este repositorio?

### Estructura por lenguaje
  - `python/`, `R/`, `matlab/` contienen subcarpetas por fuente (p. ej. `oecd/`, `eurostat/`, `fred/`).
  - En cada subcarpeta hay:
    - Un script de función principal (p. ej. `oecd_function.*`).
    - Un ejemplo que hace uso de la función principal (p. ej. `oecd_example.*`).
    - Un ejemplo “mínimo” autocontenido (sin llamar a la función principal) (`*_min.*`).
    - Ficheros CSV de muestra descargados (`*_example.csv`, `*_min.csv`).

- **Documentación especifica**: cada subcarpeta tiene su propio `*_readme.md` con detalles (parámetros, enlaces oficiales, ejemplos).

### Fuentes incluidas
- Las fuentes incluidas en este repositorio y que se pueden usar desde el ordenador corporativo son:
    - **Banco Central Europeo (ECB)**
    - **FRED (Federal Reserve Bank of St. Louis)**
    - **OCDE (OECD)**
    - **Eurostat**
    - **INE**
    - **World Bank**
    - **COMEXT (Eurostat Comercio Exterior)**

- Si necesitas usar **otras fuentes** en el ordenador corporativo, rellenalas en el pdf XXX y envialo para hacer una petición de trabajo.

- El Agente Copilot (o cualquier otra IA) que hemos creado puede ayudarte a **escribir los códigos para otras fuentes y arreglar los errores**. Si no lo consigues, pide ayuda en el foro de Teams.

## Cómo empezar en 5 minutos

1) **Elige lenguaje**: abre la carpeta de tu preferencia (`python/`, `R/`, `matlab/`).

2) **Elige fuente**: entra en la subcarpeta (p. ej. `python/oecd/`, `R/eurostat/`).

3) **Lee la documentación especifica**: echa un vistazo al `*_readme.md` de la fuente para ver los parámetros y ejemplos.

4) **Ejecuta el ejemplo**: los ejemplos generan un CSV en la misma carpeta. Así te aseguras de que todo  está funcionando correctamente.


5) **Adapta el ejemplo**: cambia identificadores de series, países, fechas u otros filtros buscando en la web de la fuente o preguntando al Agente Copilot.

6) **Integralo en tu propio proyecto**

> **Errores**: Si tienes problemas, pregunta al Agente Copilot Ayudante de APIs, que conoce al dedillo el repositorio y te puede ayudar a escribir los códigos y arreglar los errores. También puedes preguntar en el foro de Teams y seguro que alguién te puede ayudar.

> **Claves de API (si aplica)**: Algunas fuentes pueden requerir una clave de acceso. Consulta el `*_readme.md` de esa fuente para obtenerla y configurarla (normalmente como variable de entorno) antes de ejecutar el ejemplo. 

## Preguntas frecuentes (FAQ)

- **No uso ninguno de estos lenguajes, hay algo para usar las APIs directamente en Excel?** Sí, puedes descargar series directamente a tu fichero Excel usando Power Query. Hemos creado ejemplos y una documentación separada para hacerlo. 
- **La fuente que me interesa no está en el repositorio, tiene API?** Depende, consulta en las webs de las fuentes para ver si tienen API y si es así, pide ayuda al Agente Copilot Ayudante de APIs o en el foro de Teams para poder usarla. Desgraciadamente, muchas fuentes (muchos ministerios, Datacomex, etc) no disponen de API. En ese caso, una automatización con python puede ser una opción.

## Soporte
Hay dos formas de obtener ayuda:
- **Agente Copilot Ayudante de APIs**: que conoce al dedillo el repositorio y te puede ayudar a escribir los códigos y arreglar los errores.
- **Foro de Teams**: pide ayuda en el foro de Teams y seguro que alguién te puede ayudar.

---
