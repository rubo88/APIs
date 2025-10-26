import os
import pandas as pd

from imf_function import imf_api_function


def main() -> None:
    # Ensure relative paths are from this folder
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    df = imf_api_function(
        dataset="IFS",
        key="M.ES.PCPI_IX",
        startPeriod="2018",
        endPeriod="2023",
    )

    df.to_csv("imf_example.csv", index=False)


if __name__ == "__main__":
    main()
