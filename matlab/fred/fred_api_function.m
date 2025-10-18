
function T = fred_api_function(series_id, varargin)
    % FRED_API_FUNCTION Descarga observaciones de la API v1 de FRED (JSON) a tabla
    %   T = fred_api_function(series_id, 'Name', Value, ...)
    %   Parámetros obligatorios:
    %     series_id (char)
    %   Parámetros Nombre-Valor (opcionales):
    %     'observation_start','observation_end','realtime_start','realtime_end',
    %     'limit','offset','sort_order','units','frequency','aggregation_method',
    %     'output_type','vintage_dates','api_key'
    
    p = inputParser;
    addRequired(p, 'series_id', @(x)ischar(x) || isstring(x));
    addParameter(p, 'observation_start', []);
    addParameter(p, 'observation_end', []);
    addParameter(p, 'realtime_start', []);
    addParameter(p, 'realtime_end', []);
    addParameter(p, 'limit', []);
    addParameter(p, 'offset', []);
    addParameter(p, 'sort_order', []);
    addParameter(p, 'units', []);
    addParameter(p, 'frequency', []);
    addParameter(p, 'aggregation_method', []);
    addParameter(p, 'output_type', []);
    addParameter(p, 'vintage_dates', []);
    addParameter(p, 'api_key', getenv('FRED_API_KEY'));
    parse(p, series_id, varargin{:});
    pp = p.Results;
    
    url = 'https://api.stlouisfed.org/fred/series/observations';
    q = struct('series_id', char(pp.series_id), 'api_key', char(pp.api_key), 'file_type', 'json');
    fn = fieldnames(pp);
    for i = 1:numel(fn)
        k = fn{i};
        if any(strcmp(k, {'series_id','api_key'})), continue; end
        v = pp.(k);
        if ~isempty(v)
            q.(k) = v;
        end
    end
    
    % Construir querystring
    qp = {};
    qf = fieldnames(q);
    for i = 1:numel(qf)
        qp{end+1} = sprintf('%s=%s', qf{i}, string(q.(qf{i}))); %#ok<AGROW>
    end
    urlFull = [url '?' strjoin(qp, '&')];
    
    txt = webread(urlFull, weboptions('Timeout', 60, 'ContentType', 'text'));
    obj = jsondecode(txt);
    if ~isfield(obj, 'observations')
        error('Estructura inesperada de la API de FRED; falta observations');
    end
    T = struct2table(obj.observations);
    
    end
    
    
    