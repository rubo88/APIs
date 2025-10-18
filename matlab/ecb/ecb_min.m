% Descargador BCE (CSV) — script mínimo
% ----------------------------------------------------------------------------
% Objetivo
%   Descargar una serie del BCE en formato CSV, cargarla como tabla y guardarla a disco.
% Parámetros editables
%   - dataset: identificador del dataset (p. ej., 'BSI')
%   - seriesKey: clave completa de la serie (dimensiones separadas por '.')
%   - outputName: nombre base del archivo de salida
% Salida
%   - Archivo CSV con los datos de la serie
% Pasos
%   1) Construir la URL con ?format=csvdata
%   2) Leer directamente a tabla
%   3) Exportar a CSV

% Parámetros básicos
dataset = 'BSI';
seriesKey = 'M.U2.Y.V.M30.X.I.U2.2300.Z01.A';
outputName = 'ecb_min';

% Construir URL directa en CSV
url = sprintf('https://data-api.ecb.europa.eu/service/data/%s/%s?format=csvdata', dataset, seriesKey);

% Leer a tabla
T = readtable(url, 'FileType', 'text');

% Guardar
writetable(T, [outputName '.csv'], 'FileType', 'text');


