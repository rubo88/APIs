import os
# Ejemplo de uso — Banco Mundial (JSON -> DataFrame -> CSV)
# ----------------------------------------------------------------------------
# 1) Cargar la función
# 2) Ejecutar la consulta indicando país(es) e indicador(es)
# 3) Guardar el resultado como CSV
# ----------------------------------------------------------------------------
from worldbank_function import worldbank_api_function


def main() -> None:
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    df = worldbank_api_function(
        iso3="ESP",
        indicator="NY.GDP.MKTP.KD.ZG",
        date="2000:2023",
    )
    df.to_csv("worldbank_example.csv", index=False)


if __name__ == "__main__":
    main()


