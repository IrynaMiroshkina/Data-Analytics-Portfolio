# 📊 User Retention & Cohort Analysis using SQL and Google Sheets

## 📌 Project Overview
This project focuses on evaluating user lifecycle dynamics and assessing marketing effectiveness through **Cohort Analysis**. The primary objective is to clean unstructured behavioral data, calculate the **User Retention Rate** matrix, and compare the behavior of distinct user segments to determine acquisition quality.

### Key Objectives:
* **Database Management:** Query and process raw database tables to prepare structured datasets for cohort analysis.
* **Data Cleaning:** Clean and transform inconsistent text-based date formats using advanced SQL techniques.
* **Cohort Calculations:** Calculate user registration cohorts and their active lifespan (month offset).
* **BI & Visualization:** Build interactive cohort tables and data visualizations in Google Sheets.
* **Marketing Analytics:** Analyze Retention Rate across different acquisition channels and compare **Promo Users** vs. **Organic Users**.

---

## 🛠️ Tech Stack & Tools
* **SQL (PostgreSQL):** For data migration, string manipulation, date parsing, and cohort grouping (`CTEs`, `CASE` statements, `JOINs`).
* **DBeaver:** Database client interface.
* **Google Sheets:** For data aggregation, interactive dashboards (`Pivot Tables`, `Dynamic Slicers`, `Conditional Formatting`).

---

## 🗄️ Data Structure & Setup

### Dataset Overview
The analysis is based on two raw tables containing user profiles and post-registration event logs:

#### 1. Table: `cohort_users_raw`
*Contains baseline information about registered users.*

| Field | Description |
| :--- | :--- |
| `user_id` | Unique Identifier for the user (User ID) |
| `full_name` | User's first and last name (Full Name) |
| `email` | User's email address (contains noise: mixed casing, trailing spaces) |
| `country` | User's country of origin |
| `signup_datetime` | Registration date and time stored in inconsistent text formats |
| `signup_source` | Traffic acquisition channel |
| `signup_device` | Device used during registration |
| `promo_signup_flag` | `1` if the user was acquired via a promotion, `0` for organic |

> **Data Note:** The `signup_datetime` field contains mixed text delimiters (`.`, `/`, `-`) and variable year formats (e.g., `25` vs `2025`). The component sequence is consistently ordered as **Day-Month-Year**.

#### 2. Table: `cohort_events_raw`
*Contains user activity logs recorded after registration.*

| Field | Description |
| :--- | :--- |
| `event_id` | Unique Identifier for the event (Event ID) |
| `user_id` | Associated User ID |
| `event_datetime` | Event date and time stored in inconsistent text formats |
| `event_type` | Type of activity (`login`, `view_content`, `purchase`, `registration`, etc.) |
| `revenue` | Transaction amount (where applicable) |

> **Data Note:** The first recorded event for every user is always their `registration`. The raw logs contain technical anomalies, missing values (`NULL`), and test logs (`test_event`) that must be filtered out during preprocessing.

---

## 🚀 Skills Acquired & Demonstrated
* **Cohort & Retention Metrics:** Applying cohort analysis methodology and calculating core user retention metrics.
* **Advanced SQL Querying:** Date parsing, filtering events, table joining, and calculating time offsets.
* **Business Intelligence:** Constructing interactive dashboards with conditional formatting (heatmaps) and dynamic slicers for deep-dive analysis.
* **Data-Driven Insights:** Assessing Acquisition Quality and formulating actionable business conclusions based on segment behavior.

---
### Task 1: Database Management & Cohort Preparation
The first phase of the project required data extraction, text-to-date transformation, and structured aggregation using PostgreSQL in **DBeaver**.

#### Key Implementation Steps:
1. **Data Inspection:** Investigated `cohort_users_raw` and `cohort_events_raw` tables, identifying heavily unformatted text fields for timestamps (inconsistent delimiters like `.`, `/`, `-` and mixed 2-digit/4-digit year formats).
2. **Data Cleansing via CTEs:** Built isolated logical tables using Common Table Expressions (CTEs) to handle string manipulation:
   * Stripped whitespaces and trimmed time components using `TRIM` and `SPLIT_PART`.
   * Standardized delimiters using `REGEXP_REPLACE`.
   * Implemented a robust `CASE` statement combined with Regular Expression pattern matching (`~`) to safely route dates into the appropriate `TO_DATE` format (`DD-MM-YYYY` vs `DD-MM-YY`).
3. **Relational Joins & Offset Calculation:** Combined the datasets using an `INNER JOIN` on `user_id`. Calculated the user lifespan metric (**`month_offset`**) by extracting dates and applying month difference math.
4. **Data Filtering:** Cleaned the final dataset by excluding missing values (`NULL`), user profiles with missing registration dates, and technical anomalies (`test_event`).
---
📊 Business Intelligence & Dashboarding (Google Sheets)

### Task 2: Interactive Cohort Spreadsheet & Insights Development
After extracting and preparing the aggregated dataset via SQL, the data was migrated into **Google Sheets** to build a dynamic, stakeholder-ready business intelligence solution.

#### Key Dashboard Architecture & Implementation Steps:
1. **Data Ingestion:** Imported the generated `.csv` matrix into a dedicated `Data` sheet, establishing a clean source-of-truth layer.
2. **Interactive Pivot Tables:** Designed a dynamic matrix on a fresh `Cohort_tables` sheet:
   * **Rows:** Assigned to user enrollment cohorts (`cohort_month`).
   * **Columns:** Structured around the active lifespan index (`month_offset`).
   * **Values:** Aggregated by unique active users (`users_total`).
3. **Heatmap Visualization:** Applied conditional formatting using a soft color gradient (heatmap). This visually isolates steep drop-offs and highlights strong preservation trends across distinct milestones.
4. **Retention Rate Matrix Formula:** Constructed a secondary dynamic matrix below the absolute volumes to monitor user preservation percentages. Used bounded cell locking to automate calculation relative to Month 0:
   ```text
   =IF(B4="", "", B4/$B4)
---

## 📂 Project Deliverables
* 📂 **[View SQL Script](https://github.com/IrynaMiroshkina/Data-Analytics-Portfolio/commit/4e801879bc70dd528959a101a073a38fc0a69585)** — Production-ready SQL query for data extraction and text-to-date conversion.
* 📊 **[Interactive Google Sheets Dashboard](https://link-to-your-google-sheet](https://docs.google.com/spreadsheets/d/1eO2ks7xQkfUJUv0z-EMAQEUcPJGfhfdFlrdgKU5P6ho/edit?usp=sharing))** — Cohort tables, dynamic slicers, and performance analysis.
