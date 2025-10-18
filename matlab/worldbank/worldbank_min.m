% Descargador Banco Mundial (JSON) — script mínimo
% ----------------------------------------------------------------------------
% Objetivo
%   Construir la URL JSON del Banco Mundial, descargar los datos, convertirlos
%   a tabla de MATLAB y exportar a CSV.
% Parámetros editables
%   - iso3: país(es) ISO-3; indicator: indicador(es)
%   - date: rango temporal 'YYYY:YYYY'
% Salida
%   - Archivo CSV con los registros
% Pasos
%   1) Construir URL con format=json&per_page=...
%   2) webread + jsondecode
%   3) struct2table y exportar a CSV

% Parámetros básicos
iso3 = 'ESP';
indicator = 'NY.GDP.MKTP.KD.ZG';
date = '2015:2020';

% Construir la URL JSON del Banco Mundial
base_url = 'https://api.worldbank.org/v2';
path = ['/country/' iso3 '/indicator/' indicator];
url = [base_url path '?format=json&per_page=20000&date=' date];

% Leer la URL directamente a tabla
txt = webread(url, weboptions('Timeout', 60, 'ContentType', 'text'));
obj = jsondecode(txt);
S = obj{2};

% Convertir a tabla
T = struct2table(S);

% Exportar la tabla a CSV
writetable(T, 'worldbank_min.csv', 'FileType', 'text');


