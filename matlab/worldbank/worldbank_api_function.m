function T = worldbank_api_function(iso3, indicator, date, per_page, base_url)
% WORLDBANK_API_FUNCTION Descarga datos del Banco Mundial (JSON) y devuelve tabla
%   T = worldbank_api_function(iso3, indicator, date, per_page, base_url)
%   Parámetros:
%     iso3 (char) - código(s) ISO-3; múltiples separados por ';'
%     indicator (char) - código(s) de indicador; múltiples separados por ';'
%     date (char, opcional) - rango temporal, p. ej. '2020:2023'
%     per_page (num, opcional) - tamaño de página (por defecto 20000)
%     base_url (char, opcional) - por defecto 'https://api.worldbank.org/v2'
%   Devuelve:
%     T (table) - datos del elemento [2] de la respuesta JSON

if nargin < 4 || isempty(per_page), per_page = 20000; end
if nargin < 5 || isempty(base_url), base_url = 'https://api.worldbank.org/v2'; end

path = ['/country/' iso3 '/indicator/' indicator];
q = sprintf('?format=json&per_page=%d', per_page);
if exist('date','var') && ~isempty(date)
    q = [q '&date=' date];
end
url = [base_url path q];

% Leer JSON como texto y decodificar
txt = webread(url, weboptions('Timeout', 60, 'ContentType', 'text'));
obj = jsondecode(txt);
if numel(obj) < 2 || isempty(obj{2})
    error('Respuesta inesperada del Banco Mundial; no hay datos en el índice 2.');
end

% Convertir a tabla
S = obj{2};
T = struct2table(S);

end


