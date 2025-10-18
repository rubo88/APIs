# Importamos la función y las librerías necesarias
from ine_jaxi_function import ine_jaxi_api_function
import os
from pathlib import Path
import pandas as pd

# Cambiamos el directorio de trabajo a la carpeta de este archivo
os.chdir(os.path.dirname(os.path.abspath(__file__)))
# Llamamos a la función (retorna un pandas DataFrame)
df = ine_jaxi_api_function(
    table_id="67821",
    nocab="1",
    )

# Guardamos el DataFrame en un archivo CSV
df.to_csv("ine_jaxi_example.csv", index=False, sep=";", encoding="utf-8")




