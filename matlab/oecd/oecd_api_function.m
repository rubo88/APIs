function T = oecd_api_function(agency_identifier, dataset_identifier, data_selection, base_url, dataset_version, startPeriod, endPeriod, dimensionAtObservation)
% OECD_API_FUNCTION Descarga CSV SDMX de OECD y lo devuelve como tabla
%   T = oecd_api_function(agency_identifier, dataset_identifier, data_selection, ...)
%   Parámetros obligatorios:
%     agency_identifier (char) - p. ej., 'OECD.ECO.MAD'
%     dataset_identifier (char) - p. ej., 'DSD_EO@DF_EO'
%     data_selection (char) - clave SDMX tras la '/'
%   Opcionales:
%     base_url (char) - por defecto 'https://sdmx.oecd.org/public/rest/data'
%     dataset_version (char) - por defecto ''
%     startPeriod, endPeriod, dimensionAtObservation - parámetros comunes

if nargin < 4 || isempty(base_url), base_url = 'https://sdmx.oecd.org/public/rest/data'; end
if nargin < 5, dataset_version = ''; end

data_identifier = [agency_identifier ',' dataset_identifier ',' dataset_version];
url = sprintf('%s/%s/%s', base_url, data_identifier, data_selection);

qp = {};
if exist('startPeriod','var') && ~isempty(startPeriod), qp{end+1} = ['startPeriod=' char(string(startPeriod))]; end
if exist('endPeriod','var') && ~isempty(endPeriod), qp{end+1} = ['endPeriod=' char(string(endPeriod))]; end
if exist('dimensionAtObservation','var') && ~isempty(dimensionAtObservation), qp{end+1} = ['dimensionAtObservation=' dimensionAtObservation]; end

urlFull = url;
if ~isempty(qp), urlFull = [url '?' strjoin(qp, '&')]; end

T = readtable(urlFull, 'FileType', 'text');

end


