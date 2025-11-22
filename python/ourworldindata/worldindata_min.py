import pandas as pd
import requests
import os

# Fetch the data.
df = pd.read_csv("https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.csv?v=1&csvType=full&useColumnShortNames=true", storage_options = {'User-Agent': 'Our World In Data data fetch/1.0'})

# Fetch the metadata
metadata = requests.get("https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.metadata.json?v=1&csvType=full&useColumnShortNames=true").json()

# Save the data to CSV
output_path = os.path.join(os.path.dirname(__file__), "labor_productivity.csv")
df.to_csv(output_path, index=False)
print(f"Data saved to {output_path}")