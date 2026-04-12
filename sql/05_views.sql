-- ============================================================
-- 05_views.sql
-- Analytical Views
-- Run after all gold tables are loaded
-- ============================================================

DROP VIEW IF EXISTS vw_rate_comparison;
DROP VIEW IF EXISTS vw_submission_compliance;
DROP VIEW IF EXISTS vw_scorecard;
DROP VIEW IF EXISTS vw_yoy_changes;
DROP VIEW IF EXISTS vw_anomaly_flags;
DROP VIEW IF EXISTS vw_validation_summary;


-- ============================================================
-- vw_validation_summary
-- Full validation results in readable format
-- Numbers converted to millions/billions
-- ============================================================
CREATE VIEW vw_validation_summary AS
SELECT
    municipality,
    year,
    property_class,
    ROUND(cva / 1000000000.0, 2)            AS cva_billions,
    ROUND(total_tax_levied / 1000000.0, 2)  AS levy_millions,
    ROUND(implied_rate_pct, 4)              AS implied_rate_pct,
    flag_level,
    flag_reason
FROM gold_validation_results
ORDER BY flag_level DESC, municipality, year;


-- ============================================================
-- vw_anomaly_flags
-- Only RED and MISSING records
-- These are the ones the team needs to act on
-- ============================================================
CREATE VIEW vw_anomaly_flags AS
SELECT
    municipality,
    year,
    property_class,
    ROUND(implied_rate_pct, 4) AS implied_rate_pct,
    flag_level,
    flag_reason
FROM gold_validation_results
WHERE flag_level IN ('RED', 'MISSING')
ORDER BY municipality, year;


-- ============================================================
-- vw_yoy_changes
-- Year over year comparison sorted by largest change first
-- ============================================================
CREATE VIEW vw_yoy_changes AS
SELECT
    municipality,
    property_class,
    ROUND(levy_2022 / 1000000.0, 2)  AS levy_2022_millions,
    ROUND(levy_2023 / 1000000.0, 2)  AS levy_2023_millions,
    levy_change_pct,
    cva_change_pct,
    flag_level,
    flag_reason
FROM gold_yoy_comparison
ORDER BY flag_level DESC, ABS(COALESCE(levy_change_pct, 0)) DESC;


-- ============================================================
-- vw_scorecard
-- Municipality scores ranked best to worst
-- ============================================================
CREATE VIEW vw_scorecard AS
SELECT
    municipality,
    year,
    submission_score,
    data_quality_score,
    yoy_stability_score,
    overall_score,
    overall_flag
FROM gold_municipality_scorecard
ORDER BY year, overall_score DESC;


-- ============================================================
-- vw_submission_compliance
-- Summary of how many municipalities submitted per year
-- ============================================================
CREATE VIEW vw_submission_compliance AS
SELECT
    year,
    COUNT(*)                                        AS total_municipalities,
    SUM(is_compliant)                               AS submitted,
    COUNT(*) - SUM(is_compliant)                    AS missing,
    ROUND(SUM(is_compliant) * 100.0 / COUNT(*), 1)  AS compliance_pct
FROM silver_submission_compliance
GROUP BY year;


-- ============================================================
-- vw_rate_comparison
-- Residential implied rates side by side 2022 vs 2023
-- Useful for spotting outliers across municipalities
-- ============================================================
CREATE VIEW vw_rate_comparison AS
SELECT
    s22.municipality,
    ROUND(s22.implied_rate_pct, 4)                          AS residential_rate_2022,
    ROUND(s23.implied_rate_pct, 4)                          AS residential_rate_2023,
    ROUND(s23.implied_rate_pct - s22.implied_rate_pct, 4)   AS rate_change
FROM silver_fir_tax_levy s22
LEFT JOIN silver_fir_tax_levy s23
    ON  s22.municipality = s23.municipality
    AND s23.year         = 2023
    AND s23.slc_code     = '0010'
WHERE s22.year     = 2022
AND   s22.slc_code = '0010'
ORDER BY s23.implied_rate_pct DESC;


-- Verify all views work
SELECT * FROM vw_submission_compliance;
SELECT * FROM vw_scorecard;
SELECT * FROM vw_rate_comparison;