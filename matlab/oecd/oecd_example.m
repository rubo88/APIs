% Ejemplo de uso: OECD SDMX CSV -> tabla y CSV

cd(pwd);

% Parámetros de ejemplo (rellenar según dataset/selección reales)
agency_identifier = 'OECD.ECO.MAD';
dataset_identifier = 'DSD_EO@DF_EO';
data_selection = '...'; % clave SDMX específica

T = oecd_api_function(agency_identifier, dataset_identifier, data_selection);


outPath = 'oecd_example.csv';

writetable(T, outPath, 'FileType', 'text');


