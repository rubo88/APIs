# Ejemplo de uso — Eurostat COMEXT (JSON -> DataFrame -> CSV)
# ----------------------------------------------------------------------------
# 1) Cargar la función
# 2) Ejecutar la consulta con filtros (parámetros repetidos para multiselección)
# 3) Guardar el resultado como CSV
# ----------------------------------------------------------------------------
import os
from comext_function import comext_api_function


def main() -> None:
    # Asegurar rutas relativas coherentes
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Ejecutar la consulta
    df = comext_api_function(
        dataset_id="DS-059341",
        filters={
            "reporter": ["ES"],
            "partner": ["US"],
            "product": ["1509"],
            "flow": ["2"],
            "freq": ["A"],
            "time": ["2019", "2020"],
        },
    )

    # Guardar el resultado
    df.to_csv("comext_example.csv", index=False)


if __name__ == "__main__":
    main()


