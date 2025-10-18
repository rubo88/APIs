% Descargador Eurostat COMEXT (JSON) — script mínimo
% ----------------------------------------------------------------------------
% Objetivo
%   Construir la URL JSON de Comext con filtros, descargar los datos y convertir
%   a tabla de MATLAB para exportar a CSV.
% Parámetros editables
%   - dataset_id: identificador 'DS-...'
%   - filtros: parámetros repetidos (reporter, partner, product, flow, freq, time, ...)
% Salida
%   - Archivo CSV con los registros
% Notas
%   - Este ejemplo simplifica la reconstrucción de dimensiones SDMX; devuelve índice y valor.
% Pasos
%   1) Construir query con parámetros repetidos
%   2) webread JSON y jsondecode
%   3) Extraer doc.value y formar una tabla sencilla

% Identificador del dataset
dataset_id = 'DS-059341';
base = ['https://ec.europa.eu/eurostat/api/comext/dissemination/statistics/1.0/data/' dataset_id];

% Filtros de ejemplo 
qp = {
    'reporter=ES',
    'partner=US',
    'product=1509', 'product=8703',
    'flow=2',
    'freq=A',
    'time=2015','time=2016','time=2017','time=2018','time=2019','time=2020'
};

% Construir la URL
url = [base '?' strjoin(qp, '&')];

% Leer la URL directamente a tabla
txt = webread(url, weboptions('Timeout', 60, 'ContentType', 'text', 'HeaderFields', {'Accept' 'application/json'}));
doc = jsondecode(txt);

% Conversión simplificada (ver nota en function para reconstrucción completa)
vals = doc.value;
if isempty(fieldnames(vals))
    T = table();
else
    keys = fieldnames(vals);
    v = struct2cell(vals);
    v = cellfun(@(x) double(str2double(string(x))), v);
    T = table(str2double(keys), v, 'VariableNames', {'idx','value'});
end

% Exportar la tabla a CSV
writetable(T, 'comext_min.csv', 'FileType', 'text');


