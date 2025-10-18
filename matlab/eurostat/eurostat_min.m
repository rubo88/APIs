% Descargador Eurostat SDMX-CSV — script mínimo
% ----------------------------------------------------------------------------
% Objetivo
%   Construir la URL SDMX-CSV de Eurostat, descargar los datos, cargarlos en
%   una tabla de MATLAB y exportar a CSV.
% Parámetros editables
%   - dataset_identifier: identificador del dataset
%   - filters: struct con dimensiones válidas -> valores
% Salida
%   - Archivo CSV con los datos
% Pasos
%   1) Construir el identificador context/agency/dataset/version
%   2) Construir la query de filtros c[DIM]=v1,v2
%   3) Leer a tabla y exportar a CSV

% Id del dataset
dataset_identifier = 'nama_10_a64';
% Filtros de ejemplo
filters = struct('geo', {{'IT'}}, 'na_item', {{'B1G'}}, 'unit', 'CLV20_MEUR', 'TIME_PERIOD', 'ge:1995');

% parametros opcionales
agency_identifier = 'ESTAT';
dataset_version = '1.0';
compress = 'false';
format = 'csvdata';
formatVersion = '2.0';
lang = 'en';
labels = 'name';

% Construir la URL SDMX-CSV
base_url = 'https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow';
data_identifier = [agency_identifier '/' dataset_identifier '/' dataset_version];
url = [base_url '/' data_identifier '/'];

% Construir la query de filtros
qp = {};
fns = fieldnames(filters);
for i = 1:numel(fns)
    dim = fns{i};
    vals = filters.(dim);
    if ischar(vals) || isstring(vals); vals = cellstr(vals); end
    if isnumeric(vals); vals = cellstr(string(vals)); end
    joined = strjoin(vals, ',');
    qp{end+1} = sprintf('c[%s]=%s', dim, joined); %#ok<AGROW>
end
qp{end+1} = ['compress=' compress];
qp{end+1} = ['format=' format];
qp{end+1} = ['formatVersion=' formatVersion];
qp{end+1} = ['lang=' lang];
qp{end+1} = ['labels=' labels];

query = strjoin(qp, '&');
urlFull = [url '?' query];

% Leer la URL directamente a tabla
T = readtable(urlFull, 'FileType', 'text');

% Exportar la tabla a CSV
writetable(T, 'eurostat_min.csv', 'FileType', 'text');


