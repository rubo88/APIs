% Ejemplo de uso: FRED fredgraph y API v1

cd(pwd);
% fredgraph (sin API key)
T_graph = fredgraph_api_function('1wmdD');

% API v1 (requiere FRED_API_KEY)
setenv('FRED_API_KEY','28ee932ab037f5486dae766aebf0bec3');
T_api = fred_api_function('GDP');

outPath_graph = 'fred_graph_example.csv';
outPath_api = 'fred_api_example.csv';

writetable(T_graph, outPath_graph, 'FileType', 'text');
writetable(T_api,   outPath_api,   'FileType', 'text');


