% Ejemplo de uso: FMI SDMX (JSON) -> tabla y CSV

% Parámetros de ejemplo
Dataset = 'IFS';
SeriesKey = 'M.ES.PCPI_IX';
startPeriod = '2018';
endPeriod = '2023';

T = imf_api_function(Dataset, SeriesKey, startPeriod, endPeriod);

outPath = 'imf_example.csv';
writetable(T, outPath, 'FileType', 'text');
