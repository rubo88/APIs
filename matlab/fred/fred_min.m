% Descargador FRED (fredgraph CSV) — script mínimo
% ----------------------------------------------------------------------------
% Objetivo
%   Descargar el CSV de un gráfico compartido (fredgraph) y guardarlo como CSV tras
%   cargarlo en una tabla de MATLAB.
% Parámetros editables
%   - graphId: identificador del gráfico (parámetro g de la URL)
% Salida
%   - Archivo CSV con la serie del gráfico
% Pasos
%   1) Construir URL fredgraph.csv?g=...
%   2) Leer a tabla y exportar a CSV

% Identificador del gráfico
graphId = '1wmdD';
% Construir la URL
url = sprintf('https://fred.stlouisfed.org/graph/fredgraph.csv?g=%s', graphId);
% Leer la URL directamente a tabla
T = readtable(url, 'FileType', 'text');
% Exportar la tabla a CSV
writetable(T, 'fred_graph_min.csv', 'FileType', 'text');


