# Guía rápida: Our World in Data (CSV) — `matlab/ourworldindata/worldindata_min.m`

Este documento muestra cómo importar datos directamente desde los gráficos de Our World in Data (OWID) a MATLAB.

## Requisitos
- MATLAB

## Descripción
OWID permite descargar los datos detrás de sus gráficos en formato CSV. El script apunta directamente a la URL de descarga de datos de un gráfico específico y guarda el archivo localmente.

## Ejemplo de uso (`worldindata_min.m`)

```matlab
% Define URLs
dataUrl = "https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.csv?v=1&csvType=full&useColumnShortNames=true";
metadataUrl = "https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.metadata.json?v=1&csvType=full&useColumnShortNames=true";

% Set options with User-Agent
options = weboptions('UserAgent', 'Our World In Data data fetch/1.0');

% Fetch the data
try
    df = webread(dataUrl, options);
catch ME
    error('Failed to fetch data: %s', ME.message);
end

% Save the data to CSV
writetable(df, 'labor_productivity.csv');
```

## Cómo obtener la URL
1. Vaya a un gráfico en [Our World in Data](https://ourworldindata.org/).
2. Haga clic en la pestaña "Download".
3. Copie el enlace del archivo CSV (full data).

## Cómo elegir inputs
1. Navegue por [Our World in Data](https://ourworldindata.org/) hasta encontrar el gráfico deseado.
2. Seleccione la pestaña "Download" bajo el gráfico.
3. Haga clic derecho en el botón de descarga "Full data (CSV)" y seleccione "Copiar dirección del enlace".
4. Pegue esa URL en su script de MATLAB dentro de `webread`.

