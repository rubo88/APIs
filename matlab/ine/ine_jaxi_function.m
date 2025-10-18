function T = ine_jaxi_function(tableId, nocab, directory, locale, variant)
% INE_JAXI_FUNCTION Descarga un CSV de INE JAXIT3 y devuelve una tabla
%   T = ine_jaxi_function(tableId, nocab, directory, locale, variant)
%   Parámetros:
%     tableId  (char) - identificador de la tabla INE, p.ej. '67821'
%     nocab    (char) - '1' para evitar cabeceras adicionales (por defecto '1')
%     directory(char) - directorio base (por defecto 't')
%     locale   (char) - idioma (por defecto 'es')
%     variant  (char) - variante del formato (por defecto 'csv_bdsc')
%   Devuelve:
%     T (table) - datos descargados como tabla de MATLAB

if nargin < 2 || isempty(nocab), nocab = '1'; end
if nargin < 3 || isempty(directory), directory = 't'; end
if nargin < 4 || isempty(locale), locale = 'es'; end
if nargin < 5 || isempty(variant), variant = 'csv_bdsc'; end

% Construir URL del recurso CSV
baseUrl = 'https://www.ine.es/jaxiT3/files';
url = sprintf('%s/%s/%s/%s/%s.csv', baseUrl, directory, locale, variant, tableId);
query = sprintf('?nocab=%s', nocab);

% Leer directamente la URL como tabla (delimitador ';')
% Nota: readtable admite URLs; se concatena la query ?nocab=...
urlFull = [url query];
T = readtable(urlFull, 'Delimiter', ';', 'FileType', 'text', 'TextType', 'string');

end
