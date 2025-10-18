import io
from typing import Optional

import requests
import pandas as pd


def ine_jaxi_api_function(
    table_id: str,
    nocab: str = "1",
    directory: str = "t",
    locale: str = "es",
    variant: str = "csv_bdsc",
) -> pd.DataFrame:
    """
    Descarga un archivo CSV de INE JAXIT3 y retorna un pandas DataFrame.

    Parámetros
    ----------
    table_id : str
        Identificador de la tabla INE (p. ej., "67821").
    nocab : str, optional
        Control de cabecera; "1" evita cabeceras adicionales. Por defecto "1".
    directory : str, optional
        Segmento de directorio. Por defecto "t".
    locale : str, optional
        Idioma del recurso. Por defecto "es".
    variant : str, optional
        Variante del CSV. Por defecto "csv_bdsc".

    Retorna
    -------
    pandas.DataFrame
        CSV parseado como un DataFrame con columnas de texto.
    """

    # URL de la API de INE JAXIT3
    base_url = "https://www.ine.es/jaxiT3/files"
    url = f"{base_url}/{directory}/{locale}/{variant}/{table_id}.csv"

    # Parámetros de la petición
    headers = {"Accept": "text/csv"}
    params = {"nocab": nocab}

    # Hacemos la petición
    resp = requests.get(url, headers=headers, params=params, timeout=60)
    try:
        resp.raise_for_status()
    except requests.HTTPError as exc:
        raise RuntimeError(f"INE JAXIT3 request failed [{resp.status_code}]") from exc

    # Parseamos el CSV con pandas
    text_stream = io.StringIO(resp.content.decode("utf-8-sig"))
    df: pd.DataFrame = pd.read_csv(text_stream, sep=";", dtype=str)
    return df


