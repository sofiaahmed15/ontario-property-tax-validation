-- ============================================================
-- 03_silver.sql
-- Silver Layer -- Cleaned and Enriched Data
-- Run after bronze layer is loaded
-- ============================================================

DROP TABLE IF EXISTS silver_submission_compliance;
DROP TABLE IF EXISTS silver_fir_tax_levy;


-- ============================================================
-- silver_fir_tax_levy
-- Cleaned FIR data joined with reference tables
-- implied_rate_pct calculated here: total_tax / CVA * 100
-- ============================================================
CREATE TABLE silver_fir_tax_levy (
    levy_id             INTEGER PRIMARY KEY AUTOINCREMENT,
    municipality_id     INTEGER,
    municipality        TEXT NOT NULL,
    year                INTEGER NOT NULL,
    slc_code            TEXT NOT NULL,
    property_class      TEXT NOT NULL,
    cva                 REAL,
    total_tax_levied    REAL,
    lt_municipal_tax    REAL,
    ut_municipal_tax    REAL,
    education_tax       REAL,
    implied_rate_pct    REAL,
    FOREIGN KEY (municipality_id) REFERENCES ref_municipalities(municipality_id)
);

INSERT INTO silver_fir_tax_levy (
    municipality_id, municipality, year, slc_code, property_class,
    cva, total_tax_levied, lt_municipal_tax, ut_municipal_tax,
    education_tax, implied_rate_pct
)
SELECT
    m.municipality_id,
    b.municipality,
    b.year,
    b.slc_code,
    b.property_class,
    b.cva,
    b.total_tax_levied,
    b.lt_municipal_tax,
    b.ut_municipal_tax,
    b.education_tax,
    CASE
        WHEN b.cva > 0 AND b.total_tax_levied IS NOT NULL
        THEN ROUND(b.total_tax_levied / b.cva * 100, 6)
        ELSE NULL
    END AS implied_rate_pct
FROM bronze_fir_raw b
LEFT JOIN ref_municipalities m ON b.municipality = m.municipality_name;


-- ============================================================
-- silver_submission_compliance
-- Submission status with is_compliant flag
-- is_compliant: 1 = submitted, 0 = missing
-- ============================================================
CREATE TABLE silver_submission_compliance (
    compliance_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    municipality_id     INTEGER,
    municipality        TEXT NOT NULL,
    year                INTEGER NOT NULL,
    submission_status   TEXT NOT NULL,
    is_compliant        INTEGER,
    FOREIGN KEY (municipality_id) REFERENCES ref_municipalities(municipality_id)
);

INSERT INTO silver_submission_compliance (
    municipality_id, municipality, year, submission_status, is_compliant
)
SELECT DISTINCT
    m.municipality_id,
    b.municipality,
    b.year,
    b.submission_status,
    CASE WHEN b.submission_status = 'SUBMITTED' THEN 1 ELSE 0 END
FROM bronze_submission_status b
LEFT JOIN ref_municipalities m ON b.municipality = m.municipality_name;


-- Verify
SELECT 'silver_fir_tax_levy'         AS table_name, COUNT(*) AS rows FROM silver_fir_tax_levy         UNION ALL
SELECT 'silver_submission_compliance' AS table_name, COUNT(*) AS rows FROM silver_submission_compliance;