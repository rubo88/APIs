# Descargador mínimo FRED (fredgraph CSV) — autocontenido (no usa la función)
# ----------------------------------------------------------------------------
# Objetivo
#   Descarga el CSV de un gráfico compartido de FRED y lo guarda
# ----------------------------------------------------------------------------
import os
import io
import pandas as pd
import requests


def main() -> None:
    # Cambiar directorio a la carpeta del script para rutas consistentes
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Parámetros mínimos
    graph_id = "1wmdD"
    url = "https://fred.stlouisfed.org/graph/fredgraph.csv"

    # Petición y guardado
    resp = requests.get(url, params={"g": graph_id}, headers={"Accept": "text/csv"}, timeout=120)
    resp.raise_for_status()
    text_stream = io.StringIO(resp.content.decode("utf-8"))
    pd.read_csv(text_stream).to_csv("fred_graph_min.csv", index=False)


if __name__ == "__main__":
    main()


