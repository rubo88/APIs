% Ejemplo de uso: Eurostat SDMX-CSV a tabla y CSV

cd(pwd);
% Parámetros de ejemplo
dataset_identifier = 'nama_10_a64';
filters = struct('geo', {{'IT'}}, 'na_item', {{'B1G'}}, 'unit', 'CLV20_MEUR', 'TIME_PERIOD', 'ge:1995');

% Llamar a la función
T = eurostat_api_function(dataset_identifier, filters);

% Carpeta de salida
outPath = 'eurostat_example.csv';

% Guardar como CSV
writetable(T, outPath, 'FileType', 'text');


