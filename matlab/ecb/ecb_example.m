% Ejemplo de uso: descarga una serie del BCE y la guarda como CSV

cd(pwd);
% Parámetros de ejemplo
dataset = 'BSI';
seriesKey = 'M.U2.Y.V.M30.X.I.U2.2300.Z01.A';

% Llamar a la función
T = ecb_api_function(dataset, seriesKey);

% Carpeta de salida
outPath = 'ecb_example.csv';

% Guardar como CSV
writetable(T, outPath, 'FileType', 'text');


