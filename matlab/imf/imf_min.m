% Descargador mínimo IMF SDMX-CSV — script mínimo
% ----------------------------------------------------------------------------
% Objetivo
%   Construir la URL SDMX 3.0 del FMI (CSV), descargar los datos, cargarlos en
%   una tabla de MATLAB y exportar a CSV.
% Parámetros editables
%   - agency_identifier, dataset_identifier, dataset_version
%   - data_selection: clave SDMX tras la '/'
%   - filtros c[DIM] como struct -> lista de valores unidos con '+'
% Salida
%   - Archivo CSV con los datos
% Pasos
%   1) Construir {base}/{agency}/{dataset}/{version}/{key}
%   2) Añadir filtros c[DIM] en query
%   3) Leer como texto (Accept SDMX-CSV) y exportar a CSV

cd(pwd);

% Parámetros básicos (análogos a R/imf/imf_min.R)
base_url = 'https://api.imf.org/external/sdmx/3.0/data/dataflow';
agency_identifier = 'IMF.STA';
dataset_identifier = 'QNEA';
dataset_version = '+'; % última versión

% Clave SDMX (múltiples países con '+')
data_selection = 'ESP+FRA.B1GQ.Q.SA.XDC.Q';

% Filtros (TIME_PERIOD entre 2020-Q1 y 2020-Q4)
filters = struct('TIME_PERIOD', {{'ge:2020-Q1','le:2020-Q4'}});

% Construcción de URL
url = sprintf('%s/%s/%s/%s/%s', base_url, agency_identifier, dataset_identifier, urlencode_keep_reserved(dataset_version), urlencode_keep_reserved(data_selection));

% Construir query de filtros
qp = {};
fns = fieldnames(filters);
for i = 1:numel(fns)
    dim = fns{i};
    vals = filters.(dim);
    if ischar(vals) || isstring(vals); vals = cellstr(vals); end
    if isnumeric(vals); vals = cellstr(string(vals)); end
    qp{end+1} = sprintf('c[%s]=%s', dim, strjoin(vals, '+')); %#ok<AGROW>
end

urlFull = url;
if ~isempty(qp)
    urlFull = [url '?' strjoin(qp, '&')];
end

% Leer CSV como texto con cabecera Accept SDMX-CSV
opts = weboptions('Timeout', 60, 'ContentType', 'text', 'HeaderFields', {'Accept' 'application/vnd.sdmx.data+csv;version=1.0.0'});
csvText = webread(urlFull, opts);

% Guardar a archivo CSV mínimo
outFile = 'imf_min.csv';
fid = fopen(outFile, 'w'); fprintf(fid, '%s', csvText); fclose(fid);

function out = urlencode_keep_reserved(s)
% URLENCODE_KEEP_RESERVED Codifica s preservando '+' '*' ',' ':'
s = string(s);
out = char(java.net.URLEncoder.encode(char(s), 'UTF-8'));
out = strrep(out, '%2B', '+');
out = strrep(out, '%2A', '*');
out = strrep(out, '%2C', ',');
out = strrep(out, '%3A', ':');
end
