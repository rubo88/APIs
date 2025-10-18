# Ejemplo de uso — Eurostat SDMX 3.0 (CSV)
# ----------------------------------------------------------------------------
# 1) Cargar la función
# 2) Ejecutar la consulta con filtros (c[dim] en R -> dict en Python)
# 3) Guardar el resultado como CSV
# ----------------------------------------------------------------------------
import os
from eurostat_function import eurostat_api_function


def main() -> None:
    # Asegurar rutas relativas coherentes
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Ejecutar la consulta
    df = eurostat_api_function(
        dataset_identifier="nama_10_a64",
        filters={
            "geo": ["IT"],
            "na_item": ["B1G"],
            "unit": "CLV20_MEUR",
            "TIME_PERIOD": "ge:1995",
        },
    )

    # Guardar el resultado
    df.to_csv("eurostat_example.csv", index=False)


if __name__ == "__main__":
    main()


