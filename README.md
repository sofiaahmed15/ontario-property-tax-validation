# Ontario Property Tax Data Quality & Validation Framework

## Overview

This project explores how a structured data quality and validation framework can be applied to Ontario’s Financial Information Return (FIR) dataset.

The FIR collects municipal financial data from 400+ municipalities, including property tax levies and assessed values across property classes. As the scale and complexity of this data grows, ensuring its completeness, accuracy, and consistency becomes critical for analysis and decision-making.

This project demonstrates a practical approach to validating FIR data using real submissions, focusing on anomaly detection, submission tracking, and prioritization of follow-ups.

---

## Problem Context

Each municipality submits detailed property tax data annually, including:
- Tax levy by property class  
- Current Value Assessment (CVA)  
- Standard Line Code (SLC) breakdowns  

However, the data:
- varies significantly across municipalities  
- requires year-over-year validation  
- can contain gaps or anomalies that are not immediately visible  

Without a structured validation process, identifying these issues requires manual effort.

---

## Approach

Using Schedule 26A data from the FIR portal, I built a lightweight validation pipeline covering 10 Ontario municipalities across 2022 and 2023.

The pipeline follows a **medallion architecture**:

- **Bronze** – Raw data as reported (no transformation)  
- **Silver** – Cleaned and enriched (joins, implied tax rates, compliance flags)  
- **Gold** – Validation outputs (anomalies, scorecards, and severity flags)  

The final output is an **Excel-based validation workbook**, designed to support practical review and follow-up.

![Data Pipeline Architecture](utilis/stitch/design.png)
![Entity Relationship Diagram](utilis/ERD_diagram.png)

---

## Key Features

- **Submission tracking** – identifies missing or incomplete filings  
- **Anomaly detection** – flags unusual year-over-year changes  
- **Implied rate validation** – checks consistency between levy and CVA  
- **Municipality scorecard** – prioritizes follow-up based on risk  
- **Configurable rules** – validation thresholds stored in reference tables (not hardcoded)

---

## Sample Findings

This framework surfaces patterns that require further review:

- **Missing submissions:** One municipality did not appear in the 2023 dataset based on available extracts  
- **Large variance:** Certain property classes showed significant year-over-year changes  
- **Outlier rates:** Some municipalities exhibit higher implied residential tax rates relative to peers  

These findings are not conclusions, but indicators for further validation against source records.

---

## Compliance Summary

| Year | Municipalities | Submitted | Missing | Compliance |
|------|---------------|-----------|---------|------------|
| 2022 | 10 | 10 | 0 | 100% |
| 2023 | 10 | 9 | 1 | 90% |

---

## Municipality Scorecard (2023)

| Municipality | Score | Status |
|---|---|---|
| Toronto | 90 | Green |
| Mississauga | 80 | Green |
| Ottawa | 80 | Green |
| Vaughan | 80 | Green |
| Brampton | 80 | Green |
| Kitchener | 80 | Green |
| Windsor | 80 | Green |
| London | 80 | Green |
| Markham | 80 | Green |
| Hamilton | 0 | Red |

---

## Tech Stack

| Tool | Purpose |
|---|---|
| Python (pandas, openpyxl) | Data extraction and processing |
| SQLite | Local database (medallion architecture) |
| SQL | Data transformation and validation logic |
| DBeaver | Querying and database management |
| Excel | Final validation and reporting layer |

**Note:** SQLite is used for local development. The schema and SQL logic are compatible with SQL Server environments.

---

## Project Structure
ontario-property-tax-validation/
├── README.md
├── docs/
│   ├── erd_schema.png
│   └── pipeline_diagram.png
├── data/
│   ├── raw/
│   │   ├── 2022/          -- FIR Excel files from MMAH portal
│   │   └── 2023/          -- FIR Excel files from MMAH portal
│   ├── processed/
│   │   ├── fir_data_2022.csv
│   │   └── fir_data_2023.csv
│   └── property_tax_validation.db
├── sql/
│   ├── 01_reference_tables.sql
│   ├── 02_bronze.sql
│   ├── 03_silver.sql
│   ├── 04_gold.sql
│   └── 05_views.sql
├── python/
│   ├── extract_fir.py
│   ├── load_bronze_layer_csv_files.py
│   └── make_excel.py
└── excel/
    └── property_tax_validation.xlsx


(See full structure in repository)

---

## Data Source

- Ontario MMAH FIR Portal  
- Schedule 26A – Taxation and Payment-in-Lieu Summary  

**Coverage:**
- 10 municipalities  
- Years: 2022–2023  

---

## Why This Matters

Accurate municipal financial data is essential for:
- policy analysis  
- funding decisions  
- inter-municipal comparisons  

This project shows how a structured validation framework can:
- reduce manual review effort  
- surface potential data quality issues early  
- support more reliable downstream analysis  

---

## Author

**Sofia Ahmed**  
Data Analyst | Mississauga, ON  

- Azure DP-203 Certified  
- Databricks Certified  
- AWS Certified  

[LinkedIn](https://www.linkedin.com/in/sofiaanjum)  
[GitHub](https://github.com/sofiaahmed15)

---

## Running the Project

```bash
git clone https://github.com/sofiaahmed15/ontario-property-tax-validation
cd ontario-property-tax-validation

python3 -m venv venv
source venv/bin/activate
pip install pandas openpyxl

# Add FIR files to data/raw/

python python/extract_fir.py
python python/load_bronze_layer_csv_files.py

# Run SQL scripts (01–05)

python python/make_excel.py
