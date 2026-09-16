"""
src/load_to_db.py
-----------------
Script to read raw Walmart Sales Forecasting dataset CSV files from data/raw
and load them into a local DuckDB database at data/warehouse.duckdb as raw tables.
"""

from pathlib import Path
import duckdb

# Define project directory paths relative to this script
SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent
DATA_RAW_DIR = PROJECT_ROOT / "data" / "raw"
DB_PATH = PROJECT_ROOT / "data" / "warehouse.duckdb"

# Map raw table names to target CSV file paths
RAW_TABLES = {
    "raw_sales": DATA_RAW_DIR / "train.csv",
    "raw_features": DATA_RAW_DIR / "features.csv",
    "raw_stores": DATA_RAW_DIR / "stores.csv",
}


def load_raw_tables(conn: duckdb.DuckDBPyConnection) -> None:
    """Reads train.csv, features.csv, stores.csv from /data/raw and loads into DuckDB."""
    print("=== Loading Raw Data into DuckDB ===")
    missing_files = []

    for table_name, csv_path in RAW_TABLES.items():
        if not csv_path.exists():
            missing_files.append(csv_path.name)
            print(f"[-] File not found: {csv_path}")
            continue

        print(f"[+] Loading '{csv_path.name}' into table '{table_name}'...")
        conn.execute(
            f"CREATE OR REPLACE TABLE {table_name} AS SELECT * FROM read_csv_auto('{csv_path.as_posix()}');"
        )

    if missing_files:
        print(f"\n[!] Missing file(s): {', '.join(missing_files)}")
        print("    Please place the Kaggle CSV files into data/raw/ before running ingestion.")


def print_table_info(conn: duckdb.DuckDBPyConnection) -> None:
    """Prints row count and schema for each raw table after loading."""
    print("\n=== Table Info & Schemas ===")

    for table_name in RAW_TABLES.keys():
        # Check if table exists in DuckDB
        table_exists = conn.execute(
            f"SELECT COUNT(*) FROM information_schema.tables WHERE table_name = '{table_name}';"
        ).fetchone()[0] > 0

        if not table_exists:
            print(f"\nTable '{table_name}': [NOT CREATED - CSV Missing]")
            continue

        row_count = conn.execute(f"SELECT COUNT(*) FROM {table_name};").fetchone()[0]
        print(f"\nTable: {table_name}")
        print(f"Row Count: {row_count:,}")
        print("Schema:")

        schema_rows = conn.execute(f"DESCRIBE {table_name};").fetchall()
        for col_name, col_type, null_ok, key, default, extra in schema_rows:
            print(f"  - {col_name:15s} : {col_type}")


def main():
    # Ensure data directory exists
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)

    print(f"Target Database: {DB_PATH}")
    conn = duckdb.connect(str(DB_PATH))

    try:
        load_raw_tables(conn)
        print_table_info(conn)
    finally:
        conn.close()


if __name__ == "__main__":
    main()
