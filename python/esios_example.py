import os
from datetime import date
import pandas as pd
import requests


def main() -> None:
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    indicator_id = 1001
    token = os.environ.get("ESIOS_TOKEN", "")
    if not token:
        raise RuntimeError("Debe definir la variable de entorno ESIOS_TOKEN con su token personal de e·sios.")

    today = date.today().strftime("%Y-%m-%d")
    start_date = f"{today}T00:00:00Z"
    end_date = f"{today}T23:59:59Z"

    base_url = f"https://api.esios.ree.es/indicators/{indicator_id}"
    headers = {
        "x-api-key": token,
        "Accept": "application/json",
        "Accept-Language": "es",
        "Content-Type": "application/json",
    }

    resp = requests.get(base_url, params={"start_date": start_date, "end_date": end_date}, headers=headers, timeout=120)
    resp.raise_for_status()
    obj = resp.json()

    values_df = None
    if isinstance(obj, dict):
        if isinstance(obj.get("indicator", {}), dict) and obj["indicator"].get("values") is not None:
            values_df = pd.DataFrame(obj["indicator"]["values"])  # type: ignore[index]
        elif obj.get("values") is not None:
            values_df = pd.DataFrame(obj["values"])  # type: ignore[index]

    if values_df is None:
        raise RuntimeError("Estructura de respuesta inesperada; no se encontró 'indicator.values'.")

    if "value" in values_df.columns:
        values_df["value"] = pd.to_numeric(values_df["value"], errors="coerce")

    values_df.to_csv("esios_example.csv", index=False)


if __name__ == "__main__":
    main()


