# 📊 Developer Ecosystem & Compensation Analysis (Stack Overflow Survey EDA)

## 📌 Project Overview
This project delivers a comprehensive **Exploratory Data Analysis (EDA)** of the global Stack Overflow Developer Survey dataset. The primary objective is to investigate the developer ecosystem by analyzing core industry metrics, including technology popularity (Python adoption), workplace dynamics (remote work trends), educational paths, and global compensation models. 

The project showcases advanced data manipulation, handling of missing values, string parsing for multi-answer categorical variables, and descriptive statistical modeling using **Pandas**.

---

## 🛠️ Tech Stack & Tools
* **Language:** Python
* **Libraries:** Pandas, NumPy
* **Environment:** Google Colab

---

## 🚀 Key Objectives & Implementation Steps

### 1. Data Ingestion & Data Quality Audit
* Loaded and audited the primary multi-row survey dataset (`survey_results_public.csv`) alongside its metadata structure schema (`survey_results_schema.csv`).
* Implemented set intersection logic to evaluate data completeness and identify the exact subset of respondents who provided answers across all schema-defined question profiles (`qname`).

### 2. Descriptive Statistics & Central Tendency
* Analyzed the global distribution of developer professional experience (`WorkExp`).
* Computed statistical benchmarks—**Mean**, **Median**, and **Mode**—while handling missing inputs to establish a clean profile of respondent experience levels.

### 3. Structural Segmentation & Text Parsing
* **Remote Work Trends:** Isolated and aggregated target segments based on operational workplace models to quantify the footprint of remote employment globally.
* **Technology Adoption (Python Popularity):** Developed string-matching filters to extract Python users from multi-selection text fields, computing percentage distributions across the entire dataset and within specific age groups.
* **Education Pathways:** Quantified the impact of modern alternative learning methods by extracting and isolating developers who utilized online courses to learn programming.

### 4. Geographic Compensation Modeling
* Filtered the global developer matrix to isolate Python developers.
* Executed multi-field group-by operations (`groupby`) to map annualized salaries (`ConvertedCompYearly`) across different nations, calculating both mean and median benchmarks to neutralize outlier distortion.

### 5. Advanced Filtering & Quantile Analytics *(Optional Tasks)*
* Formulated descending sorting algorithms to extract education profiles among the top 5 highest-earning global respondents.
* Leveraged quantile metrics to isolate the high-income threshold (**75th percentile** of global compensation) and performed multi-conditional filtering to identify top-performing industries for remote workers.

---

## 📂 Project Structure Inside Repository

```text
├── README.md                      # Detailed project summary and overview
├── developer_survey_analysis.ipynb # Fully executed Google Colab with code and outputs
├── script_solution.py             # Raw Python script containing standalone analytical code
└── data/                          # Folder for survey data 
