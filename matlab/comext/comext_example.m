% Ejemplo de uso: Eurostat COMEXT (JSON) -> tabla y CSV usando la función

cd(pwd);

% Parámetros de ejemplo (idénticos al ejemplo en R)
dataset_id = 'DS-059341';
filters = struct(...
    'reporter', {{'ES'}}, ...
    'partner',  {{'US'}}, ...
    'product',  {{'1509','8703'}}, ...
    'flow',     {{'2'}}, ...
    'freq',     {{'A'}}, ...
    'time',     num2cell(2015:2020) ...
);

% Llamar a la función
T = comext_api_function(dataset_id, filters);

% Carpeta de salida
outPath = 'comext_example.csv';

% Guardar como CSV
writetable(T, outPath, 'FileType', 'text');


