% Define URLs
dataUrl = "https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.csv?v=1&csvType=full&useColumnShortNames=true";
metadataUrl = "https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.metadata.json?v=1&csvType=full&useColumnShortNames=true";

% Set options with User-Agent
options = weboptions('UserAgent', 'Our World In Data data fetch/1.0');

% Fetch the data
try
    df = webread(dataUrl, options);
catch ME
    error('Failed to fetch data: %s', ME.message);
end

% Fetch the metadata
try
    metadata = webread(metadataUrl, options);
catch ME
    error('Failed to fetch metadata: %s', ME.message);
end

% Save the data to CSV in the same folder as the script
% Get the full path of the current script
currentScriptPath = mfilename('fullpath');
[currentDir, ~, ~] = fileparts(currentScriptPath);

% Define output path
outputPath = fullfile(currentDir, 'labor_productivity.csv');

% Write table to CSV
writetable(df, outputPath);

fprintf('Data saved to %s\n', outputPath);

