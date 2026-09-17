# Supply Chain Demand Forecasting & Inventory Optimization

An end-to-end supply chain analytics and machine learning solution focused on SKU-level weekly demand forecasting, statistical variability analysis, empirical safety stock optimization, replenishment policy design, and executive Power BI dashboard layer preparation using the public Walmart Recruiting - Store Sales Forecasting benchmark dataset.

---

## Results at a Glance

| Metric / Dimension | Benchmark / Output Value | Details & Business Impact |
|---|---|---|
| **Champion Forecast Model** | **Random Forest Regressor** | Outperformed XGBoost ($2,629.71 RMSE; 7.82% WAPE) and Naive YoY Baseline ($3,601.47 RMSE; 10.99% WAPE). Prophet evaluated at store-type aggregate scale ($653,686.86 RMSE, 2.61% WAPE; not directly comparable at SKU level). |
| **Forecast Accuracy (RMSE)** | **$2,586.34** | Evaluated on out-of-time validation split (`2012-05-01` through `2012-10-26`) |
| **Forecast Accuracy (WAPE)** | **7.77%** | Overall Weighted Absolute Percentage Error across 76,903 validation rows |
| **WAPE % Improvement vs. Naive** | **29.24% Reduction** | 29.24% WAPE improvement over Year-Over-Year Naive Seasonal Baseline (10.99% WAPE) |
| **SKU-Locations Analyzed** | **3,161 SKU-locations** | Evaluated across 45 stores and 81 departments |
| **Inventory Status Breakdown** | **67.98% Healthy**<br>**27.65% Understocked**<br>**4.37% Overstocked** | **2,149 SKU-locations Healthy** (`1.0x ROP <= Inv < 1.5x ROP`)<br>**874 SKU-locations Understocked** (`Inv < 1.0x ROP`)<br>**138 SKU-locations Overstocked** (`Inv >= 1.5x ROP`) |
| **Total Excess Inventory Capital** | **₹59.02 Lakh** ($71,111.63 USD) | Total excess inventory tied up across overstocked SKU-locations *(Seeded simulation caveat applies)* |
| **Key Statistical Finding** | **Leptokurtic Error Tail ($z = 1.8691$)** | Residual excess kurtosis (~3.13) requires a **1.14x wider safety stock buffer** vs. standard Gaussian normal ($z = 1.6450$) |

---

## Methodology Note

> [!NOTE]
> **Simulated Inventory Position Caveat**: Current stock-on-hand inventory levels are **SIMULATED** using a calibrated range of $\text{Uniform}(0.8, 1.53)$ relative to Reorder Points (ROP) with a fixed random seed (`np.random.seed(42)`) for 100% reproducibility. This range was selected to model a realistic overstock scenario for a mid-size SKU-location sample (rather than an extreme, unbounded scenario), producing a defensible total excess inventory value of ₹59.02 Lakh ($71.1k USD). Safety stock, ROP, and forecast error statistics are strictly derived from empirical model predictions and actual sales data.

---

## Pipeline Overview

1. **Step 1: SQL Data Warehouse & Star Schema DDL** ([sql/01_schema.sql](sql/01_schema.sql), [sql/02_aggregations.sql](sql/02_aggregations.sql), [src/load_to_db.py](src/load_to_db.py)) — Extracted raw Kaggle CSVs into a DuckDB star schema warehouse (`dim_store`, `dim_date`, `fact_sales`).
2. **Step 2: Exploratory Data Analysis & Outlier Detection** ([notebooks/02_eda.ipynb](notebooks/02_eda.ipynb)) — Verified zero null date joins, analyzed markdown missingness, identified negative return sales, and calculated per-SKU z-scores.
3. **Step 3: Statistical Time-Series Analysis & Kurtosis Check** ([notebooks/03_statistics.ipynb](notebooks/03_statistics.ipynb)) — Performed 52-week seasonal decomposition, ACF/PACF autocorrelation checks, and identified leptokurtic residual excess kurtosis (~3.13).
4. **Step 4: Feature Engineering & Lag Generation** ([notebooks/04_feature_engineering.ipynb](notebooks/04_feature_engineering.ipynb)) — Created 30 temporal, rolling (4-week/12-week mean & std), multi-lag (`lag_1`, `lag_2`, `lag_4`, `lag_51`, `lag_52`), and promo aggregate features.
5. **Step 5: Machine Learning Demand Forecasting Benchmarks** ([notebooks/05_modeling.ipynb](notebooks/05_modeling.ipynb)) — Trained and benchmarked Random Forest, XGBoost, Prophet, and Naive YoY baselines on a strict time-based split at `2012-05-01`.
6. **Step 6: Empirical Safety Stock & Inventory Optimization** ([notebooks/06_inventory_optimization.ipynb](notebooks/06_inventory_optimization.ipynb)) — Derived non-parametric empirical $z$-multipliers, calculated SKU-level safety stock and ROP, and evaluated overstock risk.
7. **Step 7: Power BI Dashboard Data Layer Preparation** ([notebooks/07_dashboard_prep.ipynb](notebooks/07_dashboard_prep.ipynb)) — Exported 4 flat, denormalized CSV tables with APE confidence flags and plain-language SKU stockout alerts to `dashboard/`.

---

## Key Technical Decisions

- **Strict Time-Based Train/Validation Split**: Data before `2012-05-01` (344,667 rows) was used for training, and data from `2012-05-01` onward (76,903 rows) was reserved for validation, preventing random split temporal data leakage.
- **WAPE Metric Selection over MAPE**: Weighted Absolute Percentage Error ($\text{WAPE} = \frac{\sum |y - \hat{y}|}{\sum |y|}$) was chosen as the primary percentage metric because standard MAPE is severely distorted by near-zero and negative weekly sales values.
- **Train-Only Group-Median Feature Imputation**: NaN values in lag/rolling features for Random Forest were imputed using medians calculated strictly from `df_train.groupby(['store_id', 'dept_id'])`, preventing validation data leakage.
- **Empirical (Non-Parametric) Safety Stock Buffer**: Due to heavy-tailed leptokurtic residuals (excess kurtosis ~3.13), empirical 95th-percentile error margins ($z = 1.8691$) were used instead of Gaussian normal assumptions ($z = 1.6450$), expanding safety stock buffers by 1.14x to prevent promotional stockouts.
- **Markdown Collection Gap Handling**: Explicitly flagged the pre-November 2011 collection gap where markdown promotional features were uncollected (set to 0.0 with indicator flags).

---

## Tech Stack

- **Data Processing & Analytics**: Python (`pandas`, `numpy`, `statsmodels`, `scikit-learn`, `xgboost`, `prophet`)
- **Database & SQL Engine**: `DuckDB` (OLAP Star Schema Database)
- **Visualization & BI**: `Power BI Desktop`, `matplotlib`, `seaborn`
- **Execution & Storage**: Jupyter Notebooks (`nbconvert`), `Apache Parquet`, CSV Exports

---

## Directory Structure

```
├── data/
│   ├── raw/
│   │   ├── .gitkeep
│   │   ├── train.csv                      # Raw Kaggle store-dept weekly sales
│   │   ├── features.csv                   # Raw store markdown & economic metrics
│   │   └── stores.csv                     # Raw store type & size metadata
│   ├── processed/
│   │   ├── .gitkeep
│   │   ├── sales_clean.parquet            # Cleaned transactional dataset
│   │   ├── sales_features.parquet         # Feature-engineered Parquet dataset
│   │   ├── rf_validation_predictions.parquet # Validation predictions (76,903 rows)
│   │   ├── inventory_optimization.parquet # SKU policy table (3,161 SKU-locations)
│   │   └── model_comparison_summary.csv   # Final model benchmark comparison table
│   └── warehouse.duckdb                   # Star schema database (dim_store, dim_date, fact_sales)
├── sql/
│   ├── 01_schema.sql                      # DuckDB DDL star schema definition
│   └── 02_aggregations.sql                # Analytical aggregation views
├── src/
│   └── load_to_db.py                      # Database ingestion script
├── notebooks/
│   ├── 02_eda.ipynb                       # Data cleaning & EDA
│   ├── 03_statistics.ipynb                # Seasonality & residual kurtosis analysis
│   ├── 04_feature_engineering.ipynb       # Lag & rolling feature generation
│   ├── 05_modeling.ipynb                  # ML modeling & baseline comparison
│   ├── 06_inventory_optimization.ipynb    # Safety stock & ROP optimization
│   └── 07_dashboard_prep.ipynb            # Power BI flat table export preparation
├── dashboard/
│   ├── README.md                          # Power BI data model & visual guide
│   ├── dashboard_forecast_vs_actual.csv   # Forecast vs actual line chart export
│   ├── dashboard_inventory_health.csv     # Inventory status distribution export
│   ├── dashboard_sku_alerts.csv           # Actionable priority alert table export
│   └── dashboard_summary_kpis.csv         # Top-level KPI card metric export
└── README.md                              # Project documentation
```

---

## How to Reproduce

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Ayusshhhhh01/supply-chain-demand-forecasting.git
   cd supply-chain-demand-forecasting
   ```
2. **Set Up Python Environment**:
   ```bash
   pip install pandas numpy scikit-learn xgboost prophet statsmodels duckdb matplotlib seaborn notebook nbconvert
   ```
3. **Download Benchmark Dataset**:
   - Download `train.csv`, `features.csv`, and `stores.csv` from the [Kaggle Walmart Recruiting - Store Sales Forecasting Competition](https://www.kaggle.com/c/walmart-recruiting-store-sales-forecasting/data).
   - Place the raw files into the `data/raw/` directory.
4. **Execute Pipeline in Sequence**:
   ```bash
   # Load raw data into DuckDB warehouse
   python src/load_to_db.py

   # Run Jupyter Notebooks in sequence via nbconvert
   python -m nbconvert --execute --to notebook --inplace notebooks/02_eda.ipynb
   python -m nbconvert --execute --to notebook --inplace notebooks/03_statistics.ipynb
   python -m nbconvert --execute --to notebook --inplace notebooks/04_feature_engineering.ipynb
   python -m nbconvert --execute --to notebook --inplace notebooks/05_modeling.ipynb
   python -m nbconvert --execute --to notebook --inplace notebooks/06_inventory_optimization.ipynb
   python -m nbconvert --execute --to notebook --inplace notebooks/07_dashboard_prep.ipynb
   ```
5. **Load Dashboard Exports**:
   - Import the 4 exported CSV files from `dashboard/` into **Power BI Desktop** following the data model relationships described in `dashboard/README.md`.

---

## Dataset

This project uses the public **[Walmart Recruiting - Store Sales Forecasting](https://www.kaggle.com/c/walmart-recruiting-store-sales-forecasting)** dataset from Kaggle as a supply chain analytics benchmark. It contains historical sales data for 45 Walmart stores across various departments from February 2010 to October 2012.

---

## Limitations & Assumptions

- **Simulated Stock-on-Hand Positions**: Because the Kaggle dataset lacks real-time warehouse inventory balances, current stock positions were simulated using a calibrated uniform distribution ($\text{Uniform}(0.8, 1.53)$ around ROP with `np.random.seed(42)`).
- **Revenue-Based Valuation**: Due to the absence of wholesale unit cost data, safety stock, ROP, and excess inventory capital are calculated in USD sales revenue terms rather than physical unit counts.
- **Pre-Nov 2011 Promotional Data Gap**: Markdown promotional data was uncollected prior to November 2011; uncollected periods are handled via zero-filling and explicit collection gap indicator variables.
- **Fixed Lead Time Assumption**: Replenishment lead time ($L$) is assumed to be a uniform 2 weeks across all store-department combinations, rather than SKU-specific supplier lead times.
- **Fixed Currency Exchange Rate**: Excess capital tie-up is converted from USD to INR using a fixed benchmark rate of $1\text{ USD} = \text{₹}83.0\text{ INR}$.
