% Descargador INE JAXIT3 (CSV) — script mínimo
% ----------------------------------------------------------------------------
% Objetivo
%   Descargar el CSV de una tabla INE, cargarlo en una tabla de MATLAB y exportar a CSV.
% Parámetros editables
%   - tableId: identificador de la tabla INE (p. ej., '67821')
%   - nocab: '1' evita cabeceras adicionales
%   - outputName: nombre base del archivo de salida
% Salida
%   - Archivo CSV con el contenido de la tabla
% Pasos
%   1) Construir URL con parámetros
%   2) Leer directamente a tabla con delimitador ';'
%   3) Exportar a CSV
cd(pwd);
% Parámetros básicos (idénticos al ejemplo en R/ine)
tableId = '67821';        % Identificador de la tabla en INE
nocab = '1';              % '1' evita cabeceras adicionales
outputName = 'ine_jaxi_min'; % Nombre base del archivo de salida

% Ruta de salida del CSV final
outFile = fullfile([outputName '.csv']);

% Construir URL y opciones de descarga
url = sprintf('https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/%s.csv', tableId);
query = sprintf('?nocab=%s', nocab);

% Leer directamente la URL como tabla de MATLAB (delimitador ';')
urlFull = [url query];
T = readtable(urlFull, 'Delimiter', ';', 'FileType', 'text');

% Exportar la tabla a CSV con separador ';'
writetable(T, outFile, 'Delimiter', ';', 'FileType', 'text');
