import sqlite3
import pandas as pd


DB_PATH  = "/Users/shahbazshaikh/Sofia_Ahmed/ontario-property-tax-validation/data/property_tax_validation.db"
CSV_2022 = "/Users/shahbazshaikh/Sofia_Ahmed/ontario-property-tax-validation/data/processed/fir_data_2022.csv"
CSV_2023 = "/Users/shahbazshaikh/Sofia_Ahmed/ontario-property-tax-validation/data/processed/fir_data_2023.csv"

conn = sqlite3.connect(DB_PATH)
cur = conn.cursor()

print("Connected to database")
print("Loading bronze layer...")


# ----------------------------------------
# bronze_fir_raw
# Raw FIR data exactly as extracted from Excel files
# No changes -- just load as is
# ----------------------------------------
cur.execute("""
    CREATE TABLE IF NOT EXISTS bronze_fir_raw (
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
    )
""")

# Load 2022 data
df_2022 = pd.read_csv(CSV_2022, dtype={'slc_code': str})
df_2022['source_file'] = 'fir_data_2022.csv'
df_2022.to_sql('bronze_fir_raw', conn, if_exists='append', index=False)
print(f"  bronze_fir_raw -- loaded {len(df_2022)} rows from 2022")

# Load 2023 data
df_2023 = pd.read_csv(CSV_2023, dtype={'slc_code': str})
df_2023['source_file'] = 'fir_data_2023.csv'
df_2023.to_sql('bronze_fir_raw', conn, if_exists='append', index=False)
print(f"  bronze_fir_raw -- loaded {len(df_2023)} rows from 2023")


# ----------------------------------------
# bronze_submission_status
# Which municipalities submitted and which did not
# Hamilton 2023 is MISSING -- this is the main anomaly
# ----------------------------------------
cur.execute("""
    CREATE TABLE IF NOT EXISTS bronze_submission_status (
        status_id           INTEGER PRIMARY KEY AUTOINCREMENT,
        municipality        TEXT NOT NULL,
        year                INTEGER NOT NULL,
        submission_status   TEXT NOT NULL,
        loaded_at           TEXT DEFAULT (datetime('now'))
    )
""")

cur.executemany(
    "INSERT INTO bronze_submission_status (municipality, year, submission_status) VALUES (?,?,?)",
    [
        # 2022 -- all 10 submitted
        ("Toronto",     2022, "SUBMITTED"),
        ("Mississauga", 2022, "SUBMITTED"),
        ("Ottawa",      2022, "SUBMITTED"),
        ("Vaughan",     2022, "SUBMITTED"),
        ("Brampton",    2022, "SUBMITTED"),
        ("Kitchener",   2022, "SUBMITTED"),
        ("Windsor",     2022, "SUBMITTED"),
        ("London",      2022, "SUBMITTED"),
        ("Markham",     2022, "SUBMITTED"),
        ("Hamilton",    2022, "SUBMITTED"),

        # 2023 -- Hamilton did not submit
        ("Toronto",     2023, "SUBMITTED"),
        ("Mississauga", 2023, "SUBMITTED"),
        ("Ottawa",      2023, "SUBMITTED"),
        ("Vaughan",     2023, "SUBMITTED"),
        ("Brampton",    2023, "SUBMITTED"),
        ("Kitchener",   2023, "SUBMITTED"),
        ("Windsor",     2023, "SUBMITTED"),
        ("London",      2023, "SUBMITTED"),
        ("Markham",     2023, "SUBMITTED"),
        ("Hamilton",    2023, "MISSING"),
    ]
)
print("  bronze_submission_status -- loaded 20 rows")


conn.commit()
conn.close()

print("\nBronze layer complete")
print("Open DBeaver -- check bronze_fir_raw and bronze_submission_status")