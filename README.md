# Supply Chain Demand Forecasting & Inventory Optimization

An end-to-end supply chain analytics project focused on SKU-level demand forecasting, demand variability, safety stock calculation, replenishment policy optimization, and inventory risk evaluation using the Walmart Recruiting - Store Sales Forecasting dataset.

## Completed Milestones
- [x] **Data Ingestion & SQL Warehouse**: Extracted raw Kaggle CSVs (`train.csv`, `features.csv`, `stores.csv`) into a DuckDB star schema warehouse (`dim_store`, `dim_date`, `fact_sales`).
- [x] **Data Cleaning & Exploratory Data Analysis (`notebooks/02_eda.ipynb`)**: Verified zero null date matches, analyzed missing markdown gaps, identified negative sales (returns), and calculated per-SKU z-scores.
- [x] **Statistical Analysis & Seasonality (`notebooks/03_statistics.ipynb`)**: Classical seasonal decomposition (52-week seasonality), ACF/PACF autocorrelation analysis, residual kurtosis (~3.13 excess kurtosis / leptokurtic distribution), and safety stock implications.
- [x] **Feature Engineering (`notebooks/04_feature_engineering.ipynb`)**: Engineered 30 features including temporal calendar encodings, multi-lag sales (`lag_1`, `lag_2`, `lag_4`, `lag_51`, `lag_52`), rolling statistics (4-week & 12-week mean/std), Markdown aggregates, and promo flags.
- [x] **Model Benchmarking & Forecast Evaluation (`notebooks/05_modeling.ipynb`)**:
  - Implemented strict time-based split at `2012-05-01` (344,667 train rows, 76,903 validation rows).
  - Benchmarked **Random Forest**, **XGBoost**, and **Prophet**.
  - Evaluated using **RMSE** and **WAPE (Weighted Absolute Percentage Error)**, achieving **29.24% WAPE reduction** over a naive seasonal baseline.
  - Champion Model: **Random Forest** achieved **$2,586.34 RMSE** and **7.77% WAPE** overall.
- [x] **Inventory Optimization Layer (`notebooks/06_inventory_optimization.ipynb`)**:
  - Incorporated leptokurtic residual distribution (excess kurtosis ~3.13) to calculate empirical $z$-multipliers (**1.8691** vs 1.6450 parametric, requiring a **1.14x wider safety stock buffer**).
  - Calculated SKU-location demand variability ($\sigma_{\text{demand}}$), lead time requirements ($L=2$ weeks), Safety Stock, and Reorder Points (ROP).
  - Segmented 3,161 SKU-locations into **Understocked** (37.71%), **Healthy** (30.84%), and **Overstocked** (31.45%).
  - Evaluated total excess inventory capital tie-up (**₹438.79 Crore** / **$52.87M USD**) and exported data to `data/processed/inventory_optimization.parquet`.

## Planned Stack
- Python (pandas, numpy, scikit-learn, xgboost, prophet, statsmodels)
- SQL (DuckDB)
- Power BI / Dashboarding

## Directory Structure
```
├── data/
│   ├── raw/
│   └── processed/
├── sql/
│   ├── 01_schema.sql
│   └── 02_aggregations.sql
├── src/
│   └── load_to_db.py
├── notebooks/
│   ├── 02_eda.ipynb
│   ├── 03_statistics.ipynb
│   ├── 04_feature_engineering.ipynb
│   ├── 05_modeling.ipynb
│   └── 06_inventory_optimization.ipynb
├── dashboard/
└── README.md
```

