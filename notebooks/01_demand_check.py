"""Quick checks before building the forecasting model."""

import pandas as pd

DATA_PATH = "data/sales.csv"


df = pd.read_csv(DATA_PATH)

print("shape:", df.shape)
print("\nmissing values:")
print(df.isna().sum().sort_values(ascending=False).head(15))

# Keep the first pass simple: understand the date range and sales distribution.
if "date" in df.columns:
    df["date"] = pd.to_datetime(df["date"], errors="coerce")
    print("\ndate range:", df["date"].min(), "to", df["date"].max())

if "sales" in df.columns:
    print("\nsales summary:")
    print(df["sales"].describe())

# TODO: aggregate to SKU-location-week and inspect seasonality.
