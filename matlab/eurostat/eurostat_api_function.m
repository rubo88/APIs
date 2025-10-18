function T = eurostat_api_function(dataset_identifier, filters, agency_identifier, dataset_version, compress, format, formatVersion, lang, labels)
% EUROSTAT_API_FUNCTION Descarga SDMX-CSV (Eurostat) y lo devuelve como tabla
%   T = eurostat_api_function(dataset_identifier, filters, ...)
%   Parámetros obligatorios:
%     dataset_identifier (char) - identificador del dataset (p. ej., 'nama_10_a64')
%     filters (struct) - dimensiones -> valores (char/string/cellstr)
%   Parámetros opcionales (por defecto como en R):
%     agency_identifier = 'ESTAT'
%     dataset_version   = '1.0'
%     compress          = 'false'
%     format            = 'csvdata'
%     formatVersion     = '2.0'
%     lang              = 'en'
%     labels            = 'name'
%   Devuelve:
%     T (table) - datos descargados como tabla de MATLAB

if nargin < 3 || isempty(agency_identifier), agency_identifier = 'ESTAT'; end
if nargin < 4 || isempty(dataset_version),   dataset_version = '1.0'; end
if nargin < 5 || isempty(compress),          compress = 'false'; end
if nargin < 6 || isempty(format),            format = 'csvdata'; end
if nargin < 7 || isempty(formatVersion),     formatVersion = '2.0'; end
if nargin < 8 || isempty(lang),              lang = 'en'; end
if nargin < 9 || isempty(labels),            labels = 'name'; end

base_url = 'https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow';

% Identificador completo: context/agency/dataset/version
data_identifier = strjoin({agency_identifier, dataset_identifier, dataset_version}, '/');
url = sprintf('%s/%s/', base_url, data_identifier);

% Preparar parámetros de filtros c[dim]=v1,v2
if ~isstruct(filters)
    error("'filters' debe ser un struct: dimension -> valores");
end

filter_names = fieldnames(filters);
qp = {};
for i = 1:numel(filter_names)
    dim = filter_names{i};
    vals = filters.(dim);
    if ischar(vals) || isstring(vals)
        vals = cellstr(vals);
    elseif isnumeric(vals)
        vals = cellstr(string(vals));
    elseif iscell(vals)
        % ok
    else
        error('Tipo de valor no soportado para la dimensión %s', dim);
    end
    joined = strjoin(vals, ',');
    qp{end+1} = sprintf('c[%s]=%s', dim, joined); %#ok<AGROW>
end

% Parámetros comunes
qp{end+1} = sprintf('compress=%s', compress);
qp{end+1} = sprintf('format=%s', format);
qp{end+1} = sprintf('formatVersion=%s', formatVersion);
qp{end+1} = sprintf('lang=%s', lang);
qp{end+1} = sprintf('labels=%s', labels);

query = strjoin(qp, '&');
urlFull = [url '?' query];

% Leer directamente como tabla
T = readtable(urlFull, 'FileType', 'text');

end


