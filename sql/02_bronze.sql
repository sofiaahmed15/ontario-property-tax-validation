-- ============================================================
-- 02_bronze.sql
-- Bronze Layer -- Raw Data
-- Note: bronze_fir_raw is loaded via Python script
-- Only bronze_submission_status is manually inserted here
-- ============================================================

DROP TABLE IF EXISTS bronze_submission_status;
DROP TABLE IF EXISTS bronze_fir_raw;


-- ============================================================
-- bronze_fir_raw
-- Raw FIR data extracted from Excel files
-- Loaded via Python script: python/load_bronze_layer_csv_files.py
-- ============================================================
CREATE TABLE bronze_fir_raw (
    raw_id              INTEGER PRIMARY KEY AUTOINCREMENT,
    municipality        TEXT NOT NULL,
    year                INTEGER NOT NULL,
    slc_code            TEXT,
    property_class      TEXT,
    cva                 REAL,
    total_tax_levied    REAL,
    lt_municipal_tax    REAL,
    ut_municipal_tax    REAL,
    education_tax       REAL,
    source_file         TEXT,
    loaded_at           TEXT DEFAULT (datetime('now'))
);


-- ============================================================
-- bronze_submission_status
-- Which municipalities submitted FIR and which did not
-- Hamilton 2023 is MISSING -- key anomaly in this dataset
-- ============================================================
CREATE TABLE bronze_submission_status (
    status_id           INTEGER PRIMARY KEY AUTOINCREMENT,
    municipality        TEXT NOT NULL,
    year                INTEGER NOT NULL,
    submission_status   TEXT NOT NULL,
    loaded_at           TEXT DEFAULT (datetime('now'))
);

-- 2022 -- all 10 municipalities submitted
INSERT INTO bronze_submission_status (municipality, year, submission_status) VALUES ('Toronto',     2022, 'SUBMITTED');
INSERT INTO bronze_submission_status (municipality, year, submission_status) VALUES ('Mississauga', 2022, 'SUBMITTED');
INSERT INTO bronze_submission_status (municipality, year, submission_status) VALUES ('Ottawa',      2022, 'SUBMITTED');
INSERT INTO bronze_submission_status (municipality, year, submission_status) VALUES ('Vaughan',     2022, 'SUBMITTED');
INSERT INTO bronze_submission_status (municipality, year, submission_status) VALUES ('Brampton',    2022, 'SUBMITTED');
INSERT INTO bronze_submission_status (municipality, year, submission_status) VALUES ('Kitchener',   2022, 'SUBMITTED');
INSERT INTO bronze_submission_status (municipality, year, submission_status) VALUES ('Windsor',     2022, 'SUBMITTED');
INSERT INTO bronze_submission_status (municipality, year, submission_status) VALUES ('London',      2022, 'SUBMITTED');
INSERT INTO bronze_submission_status (municipality, year, submission_status) VALUES ('Markham',     2022, 'SUBMITTED');
INSERT INTO bronze_submission_status (municipality, year, submission_status) VALUES ('Hamilton',    2022, 'SUBMITTED');

-- 2023 -- Hamilton did not submit FIR by May 31 2024 deadline
INSERT INTO bronze_submission_status (municipality, year, submission_status) VALUES ('Toronto',     2023, 'SUBMITTED');
INSERT INTO bronze_submission_status (municipality, year, submission_status) VALUES ('Mississauga', 2023, 'SUBMITTED');
INSERT INTO bronze_submission_status (municipality, year, submission_status) VALUES ('Ottawa',      2023, 'SUBMITTED');
INSERT INTO bronze_submission_status (municipality, year, submission_status) VALUES ('Vaughan',     2023, 'SUBMITTED');
INSERT INTO bronze_submission_status (municipality, year, submission_status) VALUES ('Brampton',    2023, 'SUBMITTED');
INSERT INTO bronze_submission_status (municipality, year, submission_status) VALUES ('Kitchener',   2023, 'SUBMITTED');
INSERT INTO bronze_submission_status (municipality, year, submission_status) VALUES ('Windsor',     2023, 'SUBMITTED');
INSERT INTO bronze_submission_status (municipality, year, submission_status) VALUES ('London',      2023, 'SUBMITTED');
INSERT INTO bronze_submission_status (municipality, year, submission_status) VALUES ('Markham',     2023, 'SUBMITTED');
INSERT INTO bronze_submission_status (municipality, year, submission_status) VALUES ('Hamilton',    2023, 'MISSING');


-- Verify
SELECT 'bronze_fir_raw'            AS table_name, COUNT(*) AS rows FROM bronze_fir_raw          UNION ALL
SELECT 'bronze_submission_status'  AS table_name, COUNT(*) AS rows FROM bronze_submission_status;