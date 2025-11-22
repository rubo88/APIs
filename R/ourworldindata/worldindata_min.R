library(jsonlite)
#setwd("R/ourworldindata")
# Fetch the data
df <- read.csv("https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.csv?v=1&csvType=full&useColumnShortNames=true")

# Fetch the metadata
metadata <- fromJSON("https://ourworldindata.org/grapher/labor-productivity-per-hour-pennworldtable.metadata.json?v=1&csvType=full&useColumnShortNames=true")

# Save the data to CSV
output_path <- "labor_productivity.csv"
write.csv(df, output_path, row.names = FALSE)
print(paste("Data saved to", output_path))