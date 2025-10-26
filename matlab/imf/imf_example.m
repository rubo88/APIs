% Ejemplo de uso: IMF SDMX-CSV -> tabla y CSV

cd(pwd);
%cd('matlab/imf')
% Parámetros de ejemplo (coinciden con R/imf/imf_example.R)
dataset_identifier = 'QNEA';
% Múltiples países en la clave SDMX con '+'
data_selection = 'ESP+FRA.B1GQ.Q.SA.XDC.Q';
filters = struct('TIME_PERIOD', {{'ge:2020-Q1','le:2020-Q4'}});

% Llamar a la función
T = imf_api_function(dataset_identifier, data_selection, filters);

% Carpeta de salida
outPath = 'imf_example.csv';

% Guardar como CSV
writetable(T, outPath, 'FileType', 'text');
