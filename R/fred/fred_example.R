# Ejemplos de uso de funciones FRED
library(httr)
library(jsonlite)

#setwd("fred")
source("fred_function.R")

# 1) fredgraph (no API key)
df_graph <- fredgraph_api_function(graphId = "1wmdD")
write.csv(df_graph, "fred_graph_example.csv", row.names = FALSE)

# 2) API v1 (requiere FRED_API_KEY)
 Sys.setenv(FRED_API_KEY = "28ee932ab037f5486dae766aebf0bec3")
df_api <- fred_api_function(series_id = "GDP", observation_start = NULL, observation_end = NULL)
write.csv(df_api, "fred_api_example.csv", row.names = FALSE)

# 2a) API v1 con parametros
df_parameters <- fred_api_function(series_id='CPIAUCSL', observation_start='2015-01-01', units='pc1', frequency='m', aggregation_method='avg', sort_order='desc', limit=5)

write.csv(df_parameters, 'fred_api_example_params.csv', row.names=FALSE)