from __future__ import annotations

from imf_function import imf_api_function

# Ejemplo: QNEA PIB trimestral SA XDC para España y Francia, 2020-Q1..2020-Q4
df = imf_api_function(
    dataset_identifier="QNEA",
    data_selection="ESP+FRA.B1GQ.Q.SA.XDC.Q",
    filters={
        "TIME_PERIOD": ["ge:2020-Q1", "le:2020-Q4"],
    },
)

df.to_csv("imf_example.csv", index=False)
