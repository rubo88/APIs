# Ejemplo de uso — OCDE SDMX (CSV)
# ----------------------------------------------------------------------------
# 1) Cargar la función
# 2) Ejecutar la consulta indicando agencia, dataset y selección
# 3) Guardar el resultado como CSV
# ----------------------------------------------------------------------------
import os
from oecd_function import oecd_api_function


def main() -> None:
    # Asegurar rutas relativas coherentes
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Ejecutar la consulta
    df = oecd_api_function(
        agency_identifier="OECD.ECO.MAD",
        dataset_identifier="DSD_EO@DF_EO",
        data_selection="FRA+DEU.PDTY.A",
        startPeriod="1965",
        endPeriod="2023",
        dimensionAtObservation="AllDimensions",
    )

    # Guardar el resultado
    df.to_csv("oecd_example.csv", index=False)


if __name__ == "__main__":
    main()


