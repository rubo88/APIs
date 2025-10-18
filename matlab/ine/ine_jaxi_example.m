% Ejemplo mínimo de uso para descargar una tabla de INE JAXI y exportar a CSV

% Cambiar el directorio de trabajo a la carpeta de este archivo
cd(pwd);

% Parámetros de ejemplo (tabla 67821, sin cabeceras adicionales)
tableId = '67821';
nocab = '1';

% Llamar a la función que devuelve una tabla de MATLAB
T = ine_jaxi_function(tableId, nocab);

% Construir ruta de salida
outPath = 'ine_jaxi_example.csv';

% Exportar como CSV con punto y coma como delimitador y UTF-8
writetable(T, outPath, 'Delimiter', ';', 'FileType', 'text');
