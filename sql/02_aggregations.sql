-- ============================================================================
-- 02_aggregations.sql
-- Analytical Aggregation Views for Supply Chain Demand Forecasting
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. View: sku_monthly_sales
-- Aggregates monthly total sales, average weekly sales, and transaction count
-- at the SKU level (Store + Department level).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW sku_monthly_sales AS
SELECT
    f.store_id,
    f.dept_id,
    d.year,
    d.month,
    SUM(f.weekly_sales) AS total_weekly_sales,
    AVG(f.weekly_sales) AS avg_weekly_sales,
    COUNT(*) AS row_count
FROM fact_sales f
JOIN dim_date d ON f.date = d.date
GROUP BY
    f.store_id,
    f.dept_id,
    d.year,
    d.month;

-- ----------------------------------------------------------------------------
-- 2. View: location_monthly_sales
-- Aggregates monthly total sales and active department counts by store location.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW location_monthly_sales AS
SELECT
    f.store_id,
    d.year,
    d.month,
    SUM(f.weekly_sales) AS total_weekly_sales,
    COUNT(DISTINCT f.dept_id) AS active_depts_count
FROM fact_sales f
JOIN dim_date d ON f.date = d.date
GROUP BY
    f.store_id,
    d.year,
    d.month;

-- ----------------------------------------------------------------------------
-- 3. View: category_seasonality
-- Exposes seasonality and promotional event impacts across all stores and departments,
-- calculating average weekly sales and average total promotional markdowns by month.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW category_seasonality AS
SELECT
    d.month,
    d.is_promo_event,
    AVG(f.weekly_sales) AS avg_weekly_sales,
    AVG(f.markdown_total) AS avg_markdown_total
FROM fact_sales f
JOIN dim_date d ON f.date = d.date
GROUP BY
    d.month,
    d.is_promo_event;
