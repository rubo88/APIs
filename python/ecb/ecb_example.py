# Ejemplo de uso — BCE Data API (CSV)
# ----------------------------------------------------------------------------
# 1) Cargar la función
# 2) Ejecutar la consulta indicando dataset y series_key
# 3) Guardar el resultado como CSV
# ----------------------------------------------------------------------------
import os
from ecb_function import ecb_api_function


def main() -> None:
    # Asegurar rutas relativas coherentes
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Ejecutar la consulta
    df = ecb_api_function(
        dataset="BSI",
        series_key="M.U2.Y.V.M30.X.I.U2.2300.Z01.A",
    )

    # Guardar el resultado
    df.to_csv("ecb_example.csv", index=False)


if __name__ == "__main__":
    main()


