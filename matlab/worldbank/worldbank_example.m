% Ejemplo de uso: Banco Mundial JSON -> tabla y CSV


cd(pwd);

% Parámetros de ejemplo
iso3 = 'ESP';
indicator = 'NY.GDP.MKTP.KD.ZG'; % crecimiento del PIB (% anual)
date = '2015:2020';

T = worldbank_api_function(iso3, indicator, date);

outPath = 'worldbank_example.csv';

writetable(T, outPath, 'FileType', 'text');


