import os
# Ejemplo de uso — FRED (fredgraph y API v1)
# ----------------------------------------------------------------------------
# 1) Descargar CSV de fredgraph (no requiere API key)
# 2) (Opcional) Consultar API v1 con FRED_API_KEY
# ----------------------------------------------------------------------------
from fred_function import fredgraph_api_function, fred_api_function


def main() -> None:
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Ejemplo fredgraph
    df_graph = fredgraph_api_function("1wmdD")
    df_graph.to_csv("fred_graph_example.csv", index=False)

    # Ejemplo API v1 (requiere FRED_API_KEY)
    os.environ["FRED_API_KEY"] = "28ee932ab037f5486dae766aebf0bec3"
    df_api = fred_api_function(series_id="GDPC1", observation_start="2000-01-01")
    df_api.to_csv("fred_api_example.csv", index=False)


if __name__ == "__main__":
    main()


