-- ============================================================
-- 01_reference_tables.sql
-- Reference / Lookup Tables
-- Run this first before any other script
-- ============================================================

-- Drop if exists -- clean slate
DROP TABLE IF EXISTS ref_validation_rules;
DROP TABLE IF EXISTS ref_fiscal_years;
DROP TABLE IF EXISTS ref_property_classes;
DROP TABLE IF EXISTS ref_municipalities;


-- ============================================================
-- ref_municipalities
-- ============================================================
CREATE TABLE ref_municipalities (
    municipality_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    municipality_name   TEXT NOT NULL UNIQUE,
    tier_type           TEXT,
    region              TEXT
);

INSERT INTO ref_municipalities (municipality_name, tier_type, region) VALUES ('Toronto',     'ST', 'Central Ontario');
INSERT INTO ref_municipalities (municipality_name, tier_type, region) VALUES ('Mississauga', 'LT', 'Central Ontario');
INSERT INTO ref_municipalities (municipality_name, tier_type, region) VALUES ('Ottawa',      'ST', 'Eastern Ontario');
INSERT INTO ref_municipalities (municipality_name, tier_type, region) VALUES ('Vaughan',     'LT', 'Central Ontario');
INSERT INTO ref_municipalities (municipality_name, tier_type, region) VALUES ('Brampton',    'LT', 'Central Ontario');
INSERT INTO ref_municipalities (municipality_name, tier_type, region) VALUES ('Kitchener',   'LT', 'Western Ontario');
INSERT INTO ref_municipalities (municipality_name, tier_type, region) VALUES ('Windsor',     'ST', 'Western Ontario');
INSERT INTO ref_municipalities (municipality_name, tier_type, region) VALUES ('London',      'ST', 'Western Ontario');
INSERT INTO ref_municipalities (municipality_name, tier_type, region) VALUES ('Markham',     'LT', 'Central Ontario');
INSERT INTO ref_municipalities (municipality_name, tier_type, region) VALUES ('Hamilton',    'ST', 'Central Ontario');


-- ============================================================
-- ref_property_classes
-- SLC codes from Ontario FIR documentation
-- ============================================================
CREATE TABLE ref_property_classes (
    class_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    slc_code    TEXT NOT NULL UNIQUE,
    class_name  TEXT NOT NULL
);

INSERT INTO ref_property_classes (slc_code, class_name) VALUES ('0010', 'Residential');
INSERT INTO ref_property_classes (slc_code, class_name) VALUES ('0050', 'Multi-residential');
INSERT INTO ref_property_classes (slc_code, class_name) VALUES ('0110', 'Farmland');
INSERT INTO ref_property_classes (slc_code, class_name) VALUES ('0140', 'Managed Forest');
INSERT INTO ref_property_classes (slc_code, class_name) VALUES ('0210', 'Commercial');
INSERT INTO ref_property_classes (slc_code, class_name) VALUES ('0510', 'Industrial');
INSERT INTO ref_property_classes (slc_code, class_name) VALUES ('0610', 'Large Industrial');
INSERT INTO ref_property_classes (slc_code, class_name) VALUES ('0710', 'Pipelines');
INSERT INTO ref_property_classes (slc_code, class_name) VALUES ('9170', 'Supplementary Taxes');
INSERT INTO ref_property_classes (slc_code, class_name) VALUES ('9180', 'Total Levied by Rate');


-- ============================================================
-- ref_fiscal_years
-- ============================================================
CREATE TABLE ref_fiscal_years (
    tax_year            INTEGER PRIMARY KEY,
    submission_deadline TEXT
);

INSERT INTO ref_fiscal_years (tax_year, submission_deadline) VALUES (2022, '2023-05-31');
INSERT INTO ref_fiscal_years (tax_year, submission_deadline) VALUES (2023, '2024-05-31');


-- ============================================================
-- ref_validation_rules
-- Thresholds are stored here so they can be updated easily
-- without changing any code
-- ============================================================
CREATE TABLE ref_validation_rules (
    rule_id             INTEGER PRIMARY KEY AUTOINCREMENT,
    rule_code           TEXT NOT NULL UNIQUE,
    rule_name           TEXT NOT NULL,
    yellow_threshold    REAL,
    red_threshold       REAL
);

INSERT INTO ref_validation_rules (rule_code, rule_name, yellow_threshold, red_threshold) VALUES ('YOY_LEVY_CHANGE',    'Year over Year Levy Change',    10.0, 20.0);
INSERT INTO ref_validation_rules (rule_code, rule_name, yellow_threshold, red_threshold) VALUES ('YOY_CVA_CHANGE',     'Year over Year CVA Change',      5.0, 15.0);
INSERT INTO ref_validation_rules (rule_code, rule_name, yellow_threshold, red_threshold) VALUES ('MISSING_SUBMISSION', 'Missing FIR Submission',         0.0,  0.0);
INSERT INTO ref_validation_rules (rule_code, rule_name, yellow_threshold, red_threshold) VALUES ('RATE_VARIANCE',      'Implied Rate Variance YoY',      5.0, 10.0);


-- Verify
SELECT 'ref_municipalities'    AS table_name, COUNT(*) AS rows FROM ref_municipalities    UNION ALL
SELECT 'ref_property_classes'  AS table_name, COUNT(*) AS rows FROM ref_property_classes  UNION ALL
SELECT 'ref_fiscal_years'      AS table_name, COUNT(*) AS rows FROM ref_fiscal_years      UNION ALL
SELECT 'ref_validation_rules'  AS table_name, COUNT(*) AS rows FROM ref_validation_rules;