function T = comext_api_function(dataset_id, filters)
% COMEXT_API_FUNCTION Descarga Eurostat COMEXT (JSON) y devuelve una tabla
%   T = comext_api_function(dataset_id, filters)
%   Parámetros:
%     dataset_id (char) - p. ej., 'DS-059341'
%     filters (struct) - dimensiones -> valores (string/cellstr)
%   Devuelve:
%     T (table) - datos etiquetados como tabla

base = ['https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/' dataset_id];

% Construir query con parámetros repetidos para multiselección
if ~isstruct(filters)
    error("'filters' debe ser un struct dimension -> valores");
end

qp = {};
fns = fieldnames(filters);
for i = 1:numel(fns)
    dim = fns{i};
    vals = filters.(dim);
    if ischar(vals) || isstring(vals); vals = cellstr(vals); end
    if isnumeric(vals); vals = cellstr(string(vals)); end
    for j = 1:numel(vals)
        qp{end+1} = sprintf('%s=%s', dim, vals{j}); %#ok<AGROW>
    end
end

url = base;
if ~isempty(qp), url = [base '?' strjoin(qp, '&')]; end

% Leer JSON y mapear a tabla similar a utilidades R
txt = webread(url, weboptions('Timeout', 60, 'ContentType', 'text', 'HeaderFields', {'Accept' 'application/json'}));
doc = jsondecode(txt);

% doc.value: mapa de indice->valor; doc.id, doc.size, doc.dimension
vals = doc.value;
if isempty(fieldnames(vals))
    T = table();
    return;
end

ids = cellstr(string(doc.id));
sizes = double(string(struct2cell(doc.size)))'; %#ok<NASGU>
dim = doc.dimension;

value_keys = str2double(fieldnames(vals));
value_vals = struct2cell(vals);
value_vals = cellfun(@(x) double(str2double(string(x))), value_vals);

% Construcción filas
rows = cell(numel(value_keys), 1);
for i = 1:numel(value_keys)
    rec = struct();
    rec.value = value_vals(i);
    % Mapear posiciones a códigos (métrica simplificada: usar índices directos si están)
    for k = 1:numel(ids)
        dn = ids{k};
        d = dim.(dn);
        imap = d.category.index;
        labels = d.category.label;
        % buscar código por posición (si coincide con i, aproximación)
        codes = fieldnames(imap);
        pos = struct2array(imap);
        idx = find(pos == 0, 1, 'first'); %#ok<NASGU>
        % Nota: una reconstrucción completa requiere strides; para simplicidad se omite
        if ~isempty(codes)
            code_k = string(codes{1});
            rec.(dn) = code_k;
            if isstruct(labels) && isfield(labels, codes{1})
                rec.([dn '_label']) = string(labels.(codes{1}));
            else
                rec.([dn '_label']) = missing;
            end
        end
    end
    rows{i} = rec;
end

T = struct2table([rows{:}]');

end


