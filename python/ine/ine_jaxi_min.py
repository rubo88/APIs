# Descargador mínimo INE JAXIT3 (CSV) — autocontenido (no usa la función)
# ----------------------------------------------------------------------------
# Objetivo
#   Descarga el CSV del INE JAXIT3 con parámetros mínimos y lo guarda
# ----------------------------------------------------------------------------
import os
import requests

# Cambiamos el directorio de trabajo a la carpeta de este archivo
os.chdir(os.path.dirname(os.path.abspath(__file__)))

# Parámetros mínimos
table_id = "67821"  # identificador de la tabla INE (p. ej., "67821")
nocab = "1"         # "1" para evitar cabeceras adicionales

# Construcción de URL y petición
url = f"https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/{table_id}.csv"
params = {"nocab": nocab}
resp = requests.get(url, params=params, headers={"Accept": "text/csv"}, timeout=60)
resp.raise_for_status()

# Guardar contenido en CSV en esta carpeta
with open("ine_jaxi_min.csv", "wb") as f:
    f.write(resp.content)


