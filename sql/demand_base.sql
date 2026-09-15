-- Base aggregation for the forecasting layer.
-- Final column names will be adjusted after the dataset is loaded.

SELECT
    sku,
    location,
    DATE_TRUNC('week', sale_date) AS week,
    SUM(quantity) AS units_sold
FROM sales
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3;

-- Next: add rolling demand, lead-time and variability features.
