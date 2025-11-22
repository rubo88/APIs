% Minimal IMF API downloader (link only). Notice is a xml file, not a csv file.
url = "https://api.imf.org/external/sdmx/3.0/data/dataflow/IMF.STA/QNEA/%2B/ESP%2BFRA.B1GQ.Q.SA.XDC.Q";
options = weboptions('CertificateFilename', ''); % Disable SSL verification
% Reads the XML structure. Requires further parsing to convert to table.
data = webread(url, options); 

