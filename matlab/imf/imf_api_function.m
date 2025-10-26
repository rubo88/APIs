function T = imf_api_function(dataset_identifier, data_selection, filters, agency_identifier, dataset_version, accept_csv_version, base_url)
% IMF_API_FUNCTION Descarga SDMX-CSV (IMF SDMX 3.0) y devuelve una tabla
%   T = imf_api_function(dataset_identifier, data_selection, filters, ...)
%   Parámetros obligatorios:
%     dataset_identifier (char) - p. ej., 'QNEA'
%     data_selection     (char) - clave SDMX tras la '/'
%   Parámetros opcionales (por defecto similares a R):
%     filters            (struct) - filtros tipo c[DIM] -> valores (cellstr/char)
%                                 Ej.: struct('TIME_PERIOD', {{'ge:2020-Q1','le:2020-Q4'}})
%     agency_identifier  (char)   - por defecto 'IMF.STA'
%     dataset_version    (char)   - por defecto '+' (última versión)
%     accept_csv_version (char)   - por defecto '1.0.0'
%     base_url           (char)   - por defecto 'https://api.imf.org/external/sdmx/3.0/data/dataflow'
%   Devuelve:
%     T (table) - datos descargados como tabla de MATLAB

if nargin < 3 || isempty(filters),            filters = struct(); end
if nargin < 4 || isempty(agency_identifier),  agency_identifier = 'IMF.STA'; end
if nargin < 5 || isempty(dataset_version),    dataset_version = '+'; end
if nargin < 6 || isempty(accept_csv_version), accept_csv_version = '1.0.0'; end
if nargin < 7 || isempty(base_url),           base_url = 'https://api.imf.org/external/sdmx/3.0/data/dataflow'; end

% Construir URL: {base}/{agency}/{dataset}/{version}/{key}
url = sprintf('%s/%s/%s/%s/%s', base_url, agency_identifier, dataset_identifier, urlencode_keep_reserved(dataset_version), urlencode_keep_reserved(data_selection));

% Construir query de filtros c[DIM]=v1+v2
qp = {};
if ~isempty(filters)
    fns = fieldnames(filters);
    for i = 1:numel(fns)
        dim = fns{i};
        vals = filters.(dim);
        if ischar(vals) || isstring(vals); vals = cellstr(vals); end
        if isnumeric(vals); vals = cellstr(string(vals)); end
        joined = strjoin(vals, '+');
        qp{end+1} = sprintf('c[%s]=%s', dim, joined); %#ok<AGROW>
    end
end

urlFull = url;
if ~isempty(qp)
    urlFull = [url '?' strjoin(qp, '&')];
end

% Descargar CSV como texto con cabecera Accept SDMX-CSV
opts = weboptions('Timeout', 60, 'ContentType', 'text', 'HeaderFields', {'Accept' ['application/vnd.sdmx.data+csv;version=' accept_csv_version]});
csvText = webread(urlFull, opts);

% Guardar a temp y cargar como tabla
tmp = [tempname '.csv'];
fid = fopen(tmp, 'w');
fprintf(fid, '%s', csvText);
fclose(fid);
T = readtable(tmp, 'FileType', 'text');
try, delete(tmp); end %#ok<TRYNC>

end

function out = urlencode_keep_reserved(s)
% URLENCODE_KEEP_RESERVED Codifica s preservando caracteres reservados SDMX ('+', '*', ',', ':')
% MATLAB urlencode codifica demasiado; aquí mantenemos algunos símbolos útiles
s = string(s);
% Primero usar urlencode, luego revertir ciertos reservados
out = char(java.net.URLEncoder.encode(char(s), 'UTF-8'));
% Revertir reservados permitidos en el path SDMX
out = strrep(out, '%2B', '+');
out = strrep(out, '%2A', '*');
out = strrep(out, '%2C', ',');
out = strrep(out, '%3A', ':');
end
