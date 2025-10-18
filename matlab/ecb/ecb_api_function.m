function T = ecb_api_function(dataset, seriesKey, base_url)
% ECB_API_FUNCTION Descarga una serie del BCE (CSV) y la devuelve como tabla
%   T = ecb_api_function(dataset, seriesKey, base_url)
%   Parámetros:
%     dataset   (char) - identificador del dataset (p. ej., 'BSI')
%     seriesKey (char) - clave completa de la serie (dimensiones separadas por '.')
%     base_url  (char) - host del servicio (por defecto 'https://data-api.ecb.europa.eu/service/data')
%   Devuelve:
%     T (table) - datos descargados como tabla de MATLAB

if nargin < 3 || isempty(base_url)
    base_url = 'https://data-api.ecb.europa.eu/service/data';
end

% Construir URL con formato CSV
url = sprintf('%s/%s/%s?format=csvdata', base_url, dataset, seriesKey);

% Leer directamente la URL como tabla
T = readtable(url, 'FileType', 'text');

end


