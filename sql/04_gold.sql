-- ============================================================
-- 04_gold.sql
-- Gold Layer -- Validation Results and Analytics
-- Run after silver layer is loaded
-- ============================================================

DROP TABLE IF EXISTS gold_anomaly_log;
DROP TABLE IF EXISTS gold_municipality_scorecard;
DROP TABLE IF EXISTS gold_yoy_comparison;
DROP TABLE IF EXISTS gold_validation_results;


-- ============================================================
-- gold_validation_results
-- Flag each municipality-year-class combination
-- GREEN  = data present, no issues
-- RED    = data missing or invalid
-- MISSING = municipality did not submit FIR
-- ============================================================
CREATE TABLE gold_validation_results (
    validation_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    municipality    TEXT NOT NULL,
    year            INTEGER NOT NULL,
    slc_code        TEXT NOT NULL,
    property_class  TEXT NOT NULL,
    cva             REAL,
    total_tax_levied REAL,
    implied_rate_pct REAL,
    flag_level      TEXT,
    flag_reason     TEXT,
    validated_at    TEXT DEFAULT (datetime('now'))
);

-- Insert submitted municipalities
INSERT INTO gold_validation_results (
    municipality, year, slc_code, property_class,
    cva, total_tax_levied, implied_rate_pct,
    flag_level, flag_reason
)
SELECT
    s.municipality,
    s.year,
    s.slc_code,
    s.property_class,
    s.cva,
    s.total_tax_levied,
    s.implied_rate_pct,
    CASE
        WHEN c.submission_status = 'MISSING'             THEN 'MISSING'
        WHEN s.cva IS NULL OR s.total_tax_levied IS NULL THEN 'RED'
        ELSE 'GREEN'
    END AS flag_level,
    CASE
        WHEN c.submission_status = 'MISSING'
            THEN 'Municipality did not submit FIR by deadline'
        WHEN s.cva IS NULL
            THEN 'CVA data missing -- cannot validate'
        WHEN s.total_tax_levied IS NULL
            THEN 'Tax levy data missing'
        ELSE 'Data present -- no issues detected'
    END AS flag_reason
FROM silver_fir_tax_levy s
LEFT JOIN silver_submission_compliance c
    ON s.municipality = c.municipality
    AND s.year = c.year
WHERE s.slc_code NOT IN ('9170', '9180');

-- Insert Hamilton 2023 as MISSING explicitly
INSERT INTO gold_validation_results (
    municipality, year, slc_code, property_class,
    cva, total_tax_levied, implied_rate_pct,
    flag_level, flag_reason
)
SELECT
    'Hamilton', 2023,
    pc.slc_code, pc.class_name,
    NULL, NULL, NULL,
    'MISSING',
    'Municipality did not submit FIR by deadline'
FROM ref_property_classes pc
WHERE pc.slc_code NOT IN ('9170', '9180');


-- ============================================================
-- gold_yoy_comparison
-- Year over year comparison 2022 vs 2023
-- Flags unusual changes in levy or CVA
-- ============================================================
CREATE TABLE gold_yoy_comparison (
    yoy_id          INTEGER PRIMARY KEY AUTOINCREMENT,
    municipality    TEXT NOT NULL,
    slc_code        TEXT NOT NULL,
    property_class  TEXT NOT NULL,
    cva_2022        REAL,
    cva_2023        REAL,
    cva_change_pct  REAL,
    levy_2022       REAL,
    levy_2023       REAL,
    levy_change_pct REAL,
    flag_level      TEXT,
    flag_reason     TEXT
);

INSERT INTO gold_yoy_comparison (
    municipality, slc_code, property_class,
    cva_2022, cva_2023, cva_change_pct,
    levy_2022, levy_2023, levy_change_pct,
    flag_level, flag_reason
)
SELECT
    s22.municipality,
    s22.slc_code,
    s22.property_class,
    s22.cva                 AS cva_2022,
    s23.cva                 AS cva_2023,
    CASE
        WHEN s22.cva > 0 AND s23.cva IS NOT NULL
        THEN ROUND((s23.cva - s22.cva) / s22.cva * 100, 2)
        ELSE NULL
    END                     AS cva_change_pct,
    s22.total_tax_levied    AS levy_2022,
    s23.total_tax_levied    AS levy_2023,
    CASE
        WHEN s22.total_tax_levied > 0 AND s23.total_tax_levied IS NOT NULL
        THEN ROUND((s23.total_tax_levied - s22.total_tax_levied) / s22.total_tax_levied * 100, 2)
        ELSE NULL
    END                     AS levy_change_pct,
    CASE
        WHEN s23.total_tax_levied IS NULL THEN 'MISSING'
        WHEN s22.total_tax_levied > 0 AND
             ABS((s23.total_tax_levied - s22.total_tax_levied) / s22.total_tax_levied * 100) > 20
            THEN 'RED'
        WHEN s22.total_tax_levied > 0 AND
             ABS((s23.total_tax_levied - s22.total_tax_levied) / s22.total_tax_levied * 100) > 10
            THEN 'YELLOW'
        ELSE 'GREEN'
    END                     AS flag_level,
    CASE
        WHEN s23.total_tax_levied IS NULL
            THEN 'Municipality missing 2023 submission'
        WHEN s22.total_tax_levied > 0 AND
             ABS((s23.total_tax_levied - s22.total_tax_levied) / s22.total_tax_levied * 100) > 20
            THEN 'Levy change exceeds 20% year over year -- requires investigation'
        WHEN s22.total_tax_levied > 0 AND
             ABS((s23.total_tax_levied - s22.total_tax_levied) / s22.total_tax_levied * 100) > 10
            THEN 'Levy change between 10 and 20% -- monitor closely'
        ELSE 'Normal year over year variation'
    END                     AS flag_reason
FROM silver_fir_tax_levy s22
LEFT JOIN silver_fir_tax_levy s23
    ON  s22.municipality = s23.municipality
    AND s22.slc_code     = s23.slc_code
    AND s23.year         = 2023
WHERE s22.year = 2022
AND   s22.slc_code NOT IN ('9170', '9180');


-- ============================================================
-- gold_municipality_scorecard
-- Overall score per municipality per year
-- Submission (40) + Data Quality (40) + YoY Stability (20)
-- ============================================================
CREATE TABLE gold_municipality_scorecard (
    scorecard_id        INTEGER PRIMARY KEY AUTOINCREMENT,
    municipality        TEXT NOT NULL,
    year                INTEGER NOT NULL,
    submission_score    INTEGER,
    data_quality_score  INTEGER,
    yoy_stability_score INTEGER,
    overall_score       INTEGER,
    overall_flag        TEXT,
    scored_at           TEXT DEFAULT (datetime('now'))
);

INSERT INTO gold_municipality_scorecard (
    municipality, year,
    submission_score, data_quality_score,
    yoy_stability_score, overall_score, overall_flag
)
SELECT
    c.municipality,
    c.year,
    CASE WHEN c.is_compliant = 1 THEN 40 ELSE 0 END AS submission_score,
    CASE
        WHEN c.is_compliant = 0 THEN 0
        WHEN (SELECT COUNT(*) FROM gold_validation_results v
              WHERE v.municipality = c.municipality AND v.year = c.year
              AND v.flag_level = 'RED') > 0 THEN 20
        ELSE 40
    END AS data_quality_score,
    CASE
        WHEN c.year = 2022 THEN 20
        WHEN (SELECT COUNT(*) FROM gold_yoy_comparison y
              WHERE y.municipality = c.municipality
              AND y.flag_level = 'RED') > 0 THEN 0
        WHEN (SELECT COUNT(*) FROM gold_yoy_comparison y
              WHERE y.municipality = c.municipality
              AND y.flag_level = 'YELLOW') > 0 THEN 10
        ELSE 20
    END AS yoy_stability_score,
    (CASE WHEN c.is_compliant = 1 THEN 40 ELSE 0 END) +
    (CASE WHEN c.is_compliant = 0 THEN 0
          WHEN (SELECT COUNT(*) FROM gold_validation_results v
                WHERE v.municipality = c.municipality AND v.year = c.year
                AND v.flag_level = 'RED') > 0 THEN 20
          ELSE 40 END) +
    (CASE WHEN c.year = 2022 THEN 20
          WHEN (SELECT COUNT(*) FROM gold_yoy_comparison y
                WHERE y.municipality = c.municipality
                AND y.flag_level = 'RED') > 0 THEN 0
          WHEN (SELECT COUNT(*) FROM gold_yoy_comparison y
                WHERE y.municipality = c.municipality
                AND y.flag_level = 'YELLOW') > 0 THEN 10
          ELSE 20 END) AS overall_score,
    CASE
        WHEN (CASE WHEN c.is_compliant = 1 THEN 40 ELSE 0 END) +
             (CASE WHEN c.is_compliant = 0 THEN 0
                   WHEN (SELECT COUNT(*) FROM gold_validation_results v
                         WHERE v.municipality = c.municipality AND v.year = c.year
                         AND v.flag_level = 'RED') > 0 THEN 20
                   ELSE 40 END) +
             (CASE WHEN c.year = 2022 THEN 20
                   WHEN (SELECT COUNT(*) FROM gold_yoy_comparison y
                         WHERE y.municipality = c.municipality
                         AND y.flag_level = 'RED') > 0 THEN 0
                   WHEN (SELECT COUNT(*) FROM gold_yoy_comparison y
                         WHERE y.municipality = c.municipality
                         AND y.flag_level = 'YELLOW') > 0 THEN 10
                   ELSE 20 END) >= 80 THEN 'GREEN'
        WHEN (CASE WHEN c.is_compliant = 1 THEN 40 ELSE 0 END) +
             (CASE WHEN c.is_compliant = 0 THEN 0
                   WHEN (SELECT COUNT(*) FROM gold_validation_results v
                         WHERE v.municipality = c.municipality AND v.year = c.year
                         AND v.flag_level = 'RED') > 0 THEN 20
                   ELSE 40 END) +
             (CASE WHEN c.year = 2022 THEN 20
                   WHEN (SELECT COUNT(*) FROM gold_yoy_comparison y
                         WHERE y.municipality = c.municipality
                         AND y.flag_level = 'RED') > 0 THEN 0
                   WHEN (SELECT COUNT(*) FROM gold_yoy_comparison y
                         WHERE y.municipality = c.municipality
                         AND y.flag_level = 'YELLOW') > 0 THEN 10
                   ELSE 20 END) >= 50 THEN 'YELLOW'
        ELSE 'RED'
    END AS overall_flag
FROM silver_submission_compliance c;


-- ============================================================
-- gold_anomaly_log
-- Key findings that require investigation
-- Manually populated based on analytical review
-- ============================================================
CREATE TABLE gold_anomaly_log (
    anomaly_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    municipality    TEXT NOT NULL,
    year            INTEGER,
    anomaly_type    TEXT NOT NULL,
    description     TEXT,
    severity        TEXT,
    status          TEXT DEFAULT 'OPEN',
    detected_at     TEXT DEFAULT (datetime('now'))
);

INSERT INTO gold_anomaly_log (municipality, year, anomaly_type, description, severity) VALUES
(
    'Hamilton', 2023,
    'MISSING_SUBMISSION',
    'Hamilton did not submit FIR for 2023 by the May 31 2024 deadline. Last submitted in 2022 with a total levy of $1,208,923,947.',
    'CRITICAL'
),
(
    'Markham', 2023,
    'HIGH_YOY_CHANGE',
    'Markham Large Industrial levy increased 90.1% year over year from $834,702 in 2022 to $1,586,795 in 2023. Requires verification.',
    'HIGH'
),
(
    'London', 2023,
    'HIGH_YOY_CHANGE',
    'London Large Industrial levy increased 48.5% year over year. Multiple property classes showing RED flags.',
    'HIGH'
),
(
    'Mississauga', 2023,
    'NEGATIVE_YOY_CHANGE',
    'Mississauga Managed Forest levy decreased 20.8% year over year. Possible property class reclassification.',
    'MEDIUM'
),
(
    'Windsor', 2023,
    'HIGH_RESIDENTIAL_RATE',
    'Windsor residential implied rate at 1.94% -- highest among all 10 municipalities. Toronto is 0.67%.',
    'MEDIUM'
);


-- Verify
SELECT 'gold_validation_results'    AS table_name, COUNT(*) AS rows FROM gold_validation_results    UNION ALL
SELECT 'gold_yoy_comparison'        AS table_name, COUNT(*) AS rows FROM gold_yoy_comparison        UNION ALL
SELECT 'gold_municipality_scorecard' AS table_name, COUNT(*) AS rows FROM gold_municipality_scorecard UNION ALL
SELECT 'gold_anomaly_log'           AS table_name, COUNT(*) AS rows FROM gold_anomaly_log;