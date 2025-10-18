% Descargador OECD SDMX CSV — script mínimo
% ----------------------------------------------------------------------------
% Objetivo
%   Construir la URL SDMX de OECD, descargar el CSV, cargarlo como tabla y exportar a CSV.
% Parámetros editables
%   - agency_identifier, dataset_identifier, dataset_version (si aplica)
%   - data_selection: clave SDMX tras la '/'
% Salida
%   - Archivo CSV con los datos del dataset seleccionado
% Pasos
%   1) Construir data_identifier agency,dataset,version
%   2) Leer URL directamente a tabla
%   3) Exportar a CSV

% Parámetros básicos
agency_identifier = 'OECD.ECO.MAD';
dataset_identifier = 'DSD_EO@DF_EO';
dataset_version = '';
data_selection = '...'; % clave SDMX específica

% Construir la URL SDMX
base_url = 'https://sdmx.oecd.org/public/rest/data';
data_identifier = [agency_identifier ',' dataset_identifier ',' dataset_version];
url = sprintf('%s/%s/%s', base_url, data_identifier, data_selection);

% Leer la URL directamente a tabla
T = readtable(url, 'FileType', 'text');

% Exportar la tabla a CSV
writetable(T, 'oecd_min.csv', 'FileType', 'text');


