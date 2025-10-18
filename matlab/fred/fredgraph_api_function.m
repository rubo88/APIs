function T = fredgraph_api_function(graphId)
% FREDGRAPH_API_FUNCTION Descarga CSV de fredgraph y devuelve tabla
%   T = fredgraph_api_function(graphId)
%   Parámetros:
%     graphId (char) - identificador del gráfico compartido en FRED
%   Devuelve:
%     T (table) - datos del CSV de fredgraph

url = sprintf('https://fred.stlouisfed.org/graph/fredgraph.csv?g=%s', graphId);
T = readtable(url, 'FileType', 'text');

end
