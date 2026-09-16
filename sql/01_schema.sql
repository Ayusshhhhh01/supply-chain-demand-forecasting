-- ============================================================================
-- 01_schema.sql
-- Star-Schema Data Warehouse DDL for Supply Chain Demand Forecasting
-- Creates dimensional and fact tables on top of raw tables in DuckDB.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Dimension Table: dim_store
-- Stores physical characteristics and type classification of stores.
-- Primary Key: store_id
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE dim_store AS
SELECT
    CAST(Store AS INTEGER) AS store_id,
    CAST(Type AS VARCHAR) AS type,
    CAST(Size AS INTEGER) AS size
FROM raw_stores;

-- ----------------------------------------------------------------------------
-- 2. Dimension Table: dim_date
-- Stores date breakdown and promotional event indicators.
-- Primary Key: date
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE dim_date AS
SELECT DISTINCT
    CAST(Date AS DATE) AS date,
    CAST(EXTRACT(YEAR FROM CAST(Date AS DATE)) AS INTEGER) AS year,
    CAST(EXTRACT(MONTH FROM CAST(Date AS DATE)) AS INTEGER) AS month,
    CAST(EXTRACT(WEEK FROM CAST(Date AS DATE)) AS INTEGER) AS week,
    CAST(EXTRACT(DAYOFWEEK FROM CAST(Date AS DATE)) AS INTEGER) AS day_of_week,
    CAST(IsHoliday AS BOOLEAN) AS is_promo_event
FROM (
    SELECT Date, IsHoliday FROM raw_features
    UNION
    SELECT Date, IsHoliday FROM raw_sales
) AS combined_dates;

-- ----------------------------------------------------------------------------
-- 3. Fact Table: fact_sales
-- Main transactional fact table containing weekly sales metrics, economic features,
-- and aggregate promotional markdowns.
-- Foreign Keys: store_id -> dim_store(store_id), date -> dim_date(date)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE fact_sales AS
SELECT
    CAST(s.Store AS INTEGER) AS store_id,
    CAST(s.Dept AS INTEGER) AS dept_id,
    CAST(s.Date AS DATE) AS date,
    CAST(s.Weekly_Sales AS DOUBLE) AS weekly_sales,
    CAST(f.Temperature AS DOUBLE) AS temperature,
    CAST(f.Fuel_Price AS DOUBLE) AS fuel_price,
    TRY_CAST(f.CPI AS DOUBLE) AS cpi,
    TRY_CAST(f.Unemployment AS DOUBLE) AS unemployment,
    (
        COALESCE(TRY_CAST(f.MarkDown1 AS DOUBLE), 0.0) +
        COALESCE(TRY_CAST(f.MarkDown2 AS DOUBLE), 0.0) +
        COALESCE(TRY_CAST(f.MarkDown3 AS DOUBLE), 0.0) +
        COALESCE(TRY_CAST(f.MarkDown4 AS DOUBLE), 0.0) +
        COALESCE(TRY_CAST(f.MarkDown5 AS DOUBLE), 0.0)
    ) AS markdown_total
FROM raw_sales s
LEFT JOIN raw_features f
    ON CAST(s.Store AS INTEGER) = CAST(f.Store AS INTEGER)
   AND CAST(s.Date AS DATE) = CAST(f.Date AS DATE);
