function T = imf_api_function(dataset, key, startPeriod, endPeriod, base_url)
% IMF_API_FUNCTION Descarga datos del FMI (SDMX-JSON CompactData) como tabla
%   T = imf_api_function(dataset, key, startPeriod, endPeriod, base_url)
%   Parámetros:
%     dataset (char)    - identificador del dataset (p. ej., 'IFS')
%     key (char)        - clave SDMX, p. ej., 'M.ES.PCPI_IX'
%     startPeriod (char, opcional)
%     endPeriod   (char, opcional)
%     base_url (char, opcional) - por defecto 'https://dataservices.imf.org/REST/SDMX_JSON.svc'
%   Devuelve:
%     T (table) - tabla con columnas de dimensiones (si existen), TIME_PERIOD y OBS_VALUE

if nargin < 5 || isempty(base_url), base_url = 'https://dataservices.imf.org/REST/SDMX_JSON.svc'; end
if nargin < 3, startPeriod = []; end
if nargin < 4, endPeriod = []; end
if nargin < 1 || isempty(dataset), error('''dataset'' es obligatorio (p. ej., ''IFS'')'); end
if nargin < 2 || isempty(key),     error('''key'' es obligatorio (p. ej., ''M.ES.PCPI_IX'')'); end

% Construcción de URL y query
key_enc = matlab.net.PercentEncoder.encode(string(key));
url = sprintf('%s/CompactData/%s/%s', base_url, dataset, key_enc);

% Construir opciones de webread con query
params = {};
if ~isempty(startPeriod), params(end+1:end+2) = {'startPeriod', startPeriod}; end %#ok<AGROW>
if ~isempty(endPeriod),   params(end+1:end+2) = {'endPeriod',   endPeriod};   end %#ok<AGROW>

opts = weboptions('Timeout', 120, 'ContentType', 'json');

% Realizar la petición; webread con 'json' devuelve struct / cell
obj = webread(url, params{:}, opts);

% Navegar SDMX CompactData
if ~isfield(obj, 'CompactData') || ~isfield(obj.CompactData, 'DataSet')
    T = table();
    return;
end
DS = obj.CompactData.DataSet;
if ~isfield(DS, 'Series')
    T = table();
    return;
end
Series = DS.Series;

% Normalizar a celda de series
if isstruct(Series) && isfield(Series, 'Obs')
    Series = {Series};
elseif ~iscell(Series)
    % casos no esperados
    Series = {}; 
end

rows = {};
for i = 1:numel(Series)
    ser = Series{i};
    if ~isstruct(ser), continue; end
    % Extraer atributos de dimensiones (prefijo '@')
    nms = fieldnames(ser);
    is_attr = startsWith(nms, '@');
    attr_names = nms(is_attr);
    dim_values = struct();
    for j = 1:numel(attr_names)
        n = attr_names{j};
        dim_values.(erase(n, '@')) = ser.(n);
    end

    % Observaciones
    if ~isfield(ser, 'Obs') || isempty(ser.Obs), continue; end
    obs = ser.Obs;
    % Normalizar: puede ser struct (una sola obs) o cell/struct array
    if isstruct(obs) && isfield(obs, '@TIME_PERIOD')
        obs = {obs};
    elseif isstruct(obs) && numel(obs) > 1
        obs = squeeze(num2cell(obs));
    end

    TIME_PERIOD = strings(0,1);
    OBS_VALUE = nan(0,1);
    for k = 1:numel(obs)
        o = obs{k};
        tp = ""; val = NaN;
        if isfield(o, '@TIME_PERIOD'), tp = string(o.("@TIME_PERIOD")); end
        if isfield(o, '@OBS_VALUE')
            v = o.("@OBS_VALUE");
            try
                val = str2double(string(v));
            catch
                val = NaN;
            end
        end
        TIME_PERIOD(end+1,1) = tp; %#ok<AGROW>
        OBS_VALUE(end+1,1) = val; %#ok<AGROW>
    end

    obsT = table(TIME_PERIOD, OBS_VALUE);

    if ~isempty(fieldnames(dim_values))
        % Crear tabla de dimensiones y replicar por número de observaciones
        dimT = struct2table(dim_values);
        dimT = repmat(dimT, height(obsT), 1);
        rows{end+1} = [dimT obsT]; %#ok<AGROW>
    else
        rows{end+1} = obsT; %#ok<AGROW>
    end
end

if isempty(rows)
    T = table();
else
    T = rows{1};
    for i = 2:numel(rows)
        T = [T; rows{i}]; %#ok<AGROW>
    end
end

end
