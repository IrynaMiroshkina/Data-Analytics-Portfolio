# 🗄️ Project Data Layer

This directory is designated for the source datasets used in the analysis. Due to file size limitations on GitHub, the raw `.csv` data files are not tracked in this repository.

## 📥 How to Download the Source Data

To replicate the project analysis, you need to download the official dataset manually:
1. Navigate to the official [Stack Overflow Developer Survey website](https://insights.stackoverflow.com/survey).
2. Download the latest available **Full Raw Data (ZIP)** file.
3. Extract the contents of the downloaded archive.

## 📂 Required Directory Structure

After extracting the files, place them directly into this `data/` folder. Ensure the files are named exactly as shown below for the Jupyter Notebook paths to execute successfully:

```text
data/
├── README.md                      # This directory description file
├── results.csv      # The main survey responses dataset
└── schema.csv      # The metadata schema containing question profiles
